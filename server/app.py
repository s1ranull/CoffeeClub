import json
import os
import re
import sqlite3
from contextlib import closing
from datetime import datetime, timezone
from email import policy
from email.parser import BytesParser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlsplit

from auth import issue_token, password_hash, read_token, verify_password
from coffee import COFFEE_COLLECTIONS, Collection, InvalidData, field, seed_menu


ROOT = Path(__file__).resolve().parent
DATABASE = Path(os.environ.get("DB_PATH", ROOT / "app.db"))
MAX_FILE = 5 * 1024 * 1024


def note_values(data, _db, _user):
    return {
        "title": field(data, "title", maximum=200),
        "content": field(data, "content", default="", minimum=0),
        "updatedAt": datetime.now(timezone.utc).isoformat(),
    }


COLLECTIONS = {"notes": Collection("notes", ("title", "content"), note_values),
               **COFFEE_COLLECTIONS}


class ApiError(Exception):
    def __init__(self, status, code, message):
        self.status, self.code, self.message = status, code, message


def unauthorized():
    return ApiError(401, "UNAUTHORIZED", "Authentication required")


def not_found():
    return ApiError(404, "NOT_FOUND", "Resource not found")


def connect():
    db = sqlite3.connect(DATABASE)
    db.row_factory = sqlite3.Row
    db.execute("PRAGMA foreign_keys = ON")
    db.create_function("casefold", 1, str.casefold, deterministic=True)
    return db


def public(row):
    return {key: value for key, value in dict(row).items() if key != "user_id"} | (
        {"userId": row["user_id"]} if "user_id" in row.keys() else {}
    )


class Handler(BaseHTTPRequestHandler):
    def send(self, status, payload=None, *, raw=None, headers=None):
        self.send_response(status)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Authorization, Content-Type")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        if raw is None:
            raw = b"" if payload is None else json.dumps(payload, ensure_ascii=False).encode()
            if payload is not None:
                self.send_header("Content-Type", "application/json; charset=utf-8")
        for key, value in (headers or {}).items():
            self.send_header(key, value)
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        if raw:
            self.wfile.write(raw)

    def body(self, limit):
        length = int(self.headers.get("Content-Length", "0"))
        if not 0 < length <= limit:
            raise InvalidData("Invalid body size")
        return self.rfile.read(length)

    def json_body(self):
        data = json.loads(self.body(64 * 1024))
        if not isinstance(data, dict):
            raise InvalidData("Expected a JSON object")
        return data

    def auth(self, db, action):
        data = self.json_body()
        email = field(data, "email", maximum=254).lower()
        password = data.get("password")
        if not isinstance(password, str) or not 6 <= len(password) <= 256:
            raise InvalidData("Invalid password length")
        if not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", email):
            raise InvalidData("Invalid email")
        if action == "register":
            name = field(data, "name", maximum=120)
            try:
                user_id = db.execute(
                    "INSERT INTO users (email, name, password_hash) VALUES (?, ?, ?)",
                    (email, name, password_hash(password)),
                ).lastrowid
            except sqlite3.IntegrityError as exc:
                raise ApiError(409, "EMAIL_TAKEN", "Email is already registered") from exc
            seed_menu(db, user_id)
        else:
            row = db.execute("SELECT * FROM users WHERE email = ?", (email,)).fetchone()
            if row is None or not verify_password(password, row["password_hash"]):
                raise unauthorized()
            user_id, name = row["id"], row["name"]
        return (201 if action == "register" else 200), {
            "token": issue_token(user_id),
            "user": {"id": user_id, "name": name, "email": email},
        }

    def collection(self, db, route, resource, user, record_id, query):
        table = resource.table
        scope = "user_id = ?"
        method = self.command
        if record_id is None and method == "GET":
            page = int(query.get("page", ["1"])[0])
            limit = int(query.get("limit", ["20"])[0])
            if not 1 <= page <= 2**31 or not 1 <= limit <= 100:
                raise InvalidData("Invalid page or limit")
            params = [user]
            search = query.get("search", [""])[0].strip().casefold()
            if search:
                fields = " OR ".join(
                    f"instr(casefold({field_name}), ?) > 0"
                    for field_name in resource.search_fields
                )
                scope += f" AND ({fields})"
                params.extend([search] * len(resource.search_fields))
            if route == "products" and query.get("category"):
                scope += " AND category = ?"
                params.append(query["category"][0])
            total = db.execute(f"SELECT count(*) FROM {table} WHERE {scope}", params).fetchone()[0]
            rows = db.execute(
                f"SELECT * FROM {table} WHERE {scope} ORDER BY id DESC LIMIT ? OFFSET ?",
                (*params, limit, (page - 1) * limit),
            )
            return 200, {"items": [public(row) for row in rows], "page": page,
                         "limit": limit, "total": total}

        if record_id is None and method == "POST":
            values = resource.values(self.json_body(), db, user)
            if route == "notes":
                values["createdAt"] = values["updatedAt"]
            columns = ", ".join(values)
            marks = ", ".join("?" for _ in values)
            record_id = db.execute(
                f"INSERT INTO {table} (user_id, {columns}) VALUES (?, {marks})",
                (user, *values.values()),
            ).lastrowid
            status = 201
        elif record_id is not None and method in ("GET", "PUT", "DELETE"):
            old = db.execute(
                f"SELECT * FROM {table} WHERE id = ? AND {scope}", (record_id, user)
            ).fetchone()
            if old is None:
                raise not_found()
            if method == "GET":
                return 200, public(old)
            if method == "DELETE":
                db.execute(f"DELETE FROM {table} WHERE id = ? AND {scope}", (record_id, user))
                return 204, None
            values = resource.values(self.json_body(), db, user)
            for key in ("createdAt", "earnedAt"):
                if key in values:
                    values[key] = old[key]
            updates = ", ".join(f"{key} = ?" for key in values)
            db.execute(f"UPDATE {table} SET {updates} WHERE id = ? AND {scope}",
                       (*values.values(), record_id, user))
            status = 200
        else:
            raise not_found()
        return status, public(db.execute(
            f"SELECT * FROM {table} WHERE id = ? AND {scope}", (record_id, user)
        ).fetchone())

    def upload(self, db, user):
        content_type = self.headers.get("Content-Type", "")
        if not content_type.lower().startswith("multipart/form-data;"):
            raise InvalidData("Expected multipart/form-data")
        body = self.body(MAX_FILE + 65536)
        message = BytesParser(policy=policy.default).parsebytes(
            b"Content-Type: " + content_type.encode() + b"\r\n\r\n" + body
        )
        if message.defects:
            raise InvalidData("Invalid multipart body")
        for part in message.iter_parts():
            if part.get_param("name", header="content-disposition") != "file":
                continue
            data = part.get_payload(decode=True)
            filename = part.get_filename()
            if not filename or not data or len(data) > MAX_FILE:
                break
            filename = filename.replace("\\", "/").rsplit("/", 1)[-1]
            mime = part.get_content_type()
            record_id = db.execute(
                "INSERT INTO files (user_id, filename, mimeType, data) VALUES (?, ?, ?, ?)",
                (user, filename, mime, data),
            ).lastrowid
            return 201, {"id": record_id, "filename": filename, "mimeType": mime,
                         "size": len(data), "url": f"/files/{record_id}"}
        raise InvalidData("Expected a file of up to 5 MB")

    def dispatch(self, db):
        url = urlsplit(self.path)
        parts = url.path.strip("/").split("/")
        if parts == ["health"] and self.command == "GET":
            return 200, {"status": "ok"}
        if parts in (["auth", "login"], ["auth", "register"]) and self.command == "POST":
            return self.auth(db, parts[1])
        route = parts[0]
        if route not in COLLECTIONS and route != "files":
            raise not_found()
        record_id = None
        if len(parts) > 1:
            if len(parts) != 2 or not re.fullmatch(r"[0-9]{1,19}", parts[1]):
                raise not_found()
            record_id = int(parts[1])
            if record_id >= 2**63:
                raise not_found()
        if route == "files" and record_id is not None and self.command == "GET":
            row = db.execute("SELECT data, mimeType FROM files WHERE id = ?", (record_id,)).fetchone()
            if row is None:
                raise not_found()
            return 200, None, {"raw": row["data"], "headers": {
                "Content-Type": row["mimeType"], "Content-Disposition": "attachment",
                "Content-Security-Policy": "default-src 'none'; sandbox",
                "X-Content-Type-Options": "nosniff",
            }}
        user = read_token(self.headers.get("Authorization", ""))
        if user is None or not db.execute("SELECT id FROM users WHERE id = ?", (user,)).fetchone():
            raise unauthorized()
        if route == "files":
            if record_id is None and self.command == "POST":
                return self.upload(db, user)
            raise not_found()
        return self.collection(db, route, COLLECTIONS[route], user, record_id, parse_qs(url.query))

    def handle_api(self):
        try:
            with closing(connect()) as db, db:
                db.execute("BEGIN IMMEDIATE" if self.command != "GET" else "BEGIN")
                status, payload, *extra = self.dispatch(db)
        except (ValueError, UnicodeError) as exc:
            self.send(400, {"error": {"code": "VALIDATION_ERROR", "message": str(exc)}})
        except ApiError as exc:
            self.send(exc.status, {"error": {"code": exc.code, "message": exc.message}})
        except sqlite3.Error as exc:
            self.log_error("%s", exc)
            self.send(500, {"error": {"code": "INTERNAL_ERROR", "message": "Database error"}})
        else:
            self.send(status, payload, **(extra[0] if extra else {}))

    do_GET = do_POST = do_PUT = do_DELETE = handle_api

    def do_OPTIONS(self):
        self.send(204)


if __name__ == "__main__":
    with closing(connect()) as db:
        db.executescript((ROOT / "schema.sql").read_text(encoding="utf-8"))
    port = int(os.environ.get("PORT", "8080"))
    with ThreadingHTTPServer(("0.0.0.0", port), Handler) as server:
        print(f"CoffeeClub API: http://localhost:{port}", flush=True)
        server.serve_forever()
