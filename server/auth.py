import base64
import binascii
import hashlib
import hmac
import json
import os
import secrets
import time


SECRET = os.environ.get("JWT_SECRET", "coffee-club-lab-secret").encode()


def encode(data):
    return base64.urlsafe_b64encode(data).rstrip(b"=")


def decode(data):
    return base64.urlsafe_b64decode(data + b"=" * (-len(data) % 4))


def issue_token(user_id):
    header = encode(b'{"alg":"HS256","typ":"JWT"}')
    payload = encode(json.dumps({"sub": str(user_id), "exp": int(time.time()) + 86400}).encode())
    message = header + b"." + payload
    signature = encode(hmac.digest(SECRET, message, "sha256"))
    return (message + b"." + signature).decode()


def read_token(header):
    if not header.startswith("Bearer "):
        return None
    try:
        part1, part2, signature = header[7:].encode("ascii").split(b".")
        expected = encode(hmac.digest(SECRET, part1 + b"." + part2, "sha256"))
        if not hmac.compare_digest(signature, expected):
            return None
        payload = json.loads(decode(part2))
        return int(payload["sub"]) if payload["exp"] > time.time() else None
    except (ValueError, KeyError, TypeError, binascii.Error):
        return None


def password_hash(password, salt=None):
    if salt is None:
        salt = secrets.token_hex(16)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode(), bytes.fromhex(salt), 310_000)
    return salt + ":" + digest.hex()


def verify_password(password, stored):
    salt = stored.split(":", 1)[0]
    return hmac.compare_digest(password_hash(password, salt), stored)
