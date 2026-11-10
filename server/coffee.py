import math
from datetime import datetime
from typing import NamedTuple


class InvalidData(ValueError):
    pass


def field(data, key, *, default=None, minimum=1, maximum=4000):
    value = data.get(key, default)
    if not isinstance(value, str):
        raise InvalidData(f"{key} must be text")
    value = value.strip()
    if not minimum <= len(value) <= maximum:
        raise InvalidData(f"{key} has an invalid length")
    return value


def number(data, key, minimum):
    value = data.get(key)
    if type(value) not in (int, float) or not minimum <= value <= 1_000_000:
        raise InvalidData(f"{key} is out of range")
    return value


def product_values(data, _db, _user):
    category = field(data, "category")
    if category not in ("Кофе", "Чай", "Десерты"):
        raise InvalidData("Unknown category")
    price = number(data, "price", 0)
    if price <= 0 or not math.isfinite(price):
        raise InvalidData("price must be positive")
    return {
        "name": field(data, "name", minimum=2, maximum=120),
        "price": price,
        "category": category,
        "imageUrl": field(data, "imageUrl", default="", minimum=0, maximum=500),
        "description": field(data, "description"),
    }


def order_values(data, _db, _user):
    phone = field(data, "phone", maximum=40)
    if sum(character.isdecimal() for character in phone) < 8:
        raise InvalidData("Invalid phone number")
    return {
        "items": field(data, "items"),
        "total": number(data, "total", 0),
        "status": field(data, "status", default="Принят", maximum=60),
        "createdAt": datetime.now().strftime("%d.%m.%Y · %H:%M"),
        "customerName": field(data, "customerName", minimum=2, maximum=120),
        "phone": phone,
    }


def loyalty_values(data, db, user):
    points = data.get("points")
    if type(points) is not int or not 0 < abs(points) <= 1_000_000:
        raise InvalidData("Invalid points")
    order_id = data.get("orderId")
    if order_id is not None and (
        type(order_id) is not int
        or not 0 < order_id < 2**63
        or not db.execute(
            "SELECT id FROM orders WHERE id = ? AND user_id = ?", (order_id, user)
        ).fetchone()
    ):
        raise InvalidData("Unknown order")
    return {
        "orderId": order_id,
        "points": points,
        "description": field(data, "description", maximum=300),
        "earnedAt": datetime.now().strftime("%d.%m.%Y"),
    }


def seed_menu(db, user):
    items = [
        ("Cappuccino", 48, "Кофе", "Эспрессо с молоком и молочной пеной."),
        ("Caramel Latte", 55, "Кофе", "Латте с карамельным сиропом."),
        ("Espresso", 32, "Кофе", "Крепкий кофе из свежемолотых зёрен."),
        ("Americano", 38, "Кофе", "Эспрессо с горячей водой."),
        ("Green Tea", 35, "Чай", "Зелёный чай с мягким вкусом."),
        ("Matcha Latte", 58, "Чай", "Японская матча с молоком."),
        ("New York Cheesecake", 62, "Десерты", "Чизкейк на хрустящей основе."),
        ("Chocolate Croissant", 42, "Десерты", "Круассан с шоколадной начинкой."),
    ]
    db.executemany(
        """INSERT INTO products (user_id, name, price, category, description, imageUrl)
           VALUES (?, ?, ?, ?, ?, '')""",
        [(user, *item) for item in items],
    )


class Collection(NamedTuple):
    table: str
    search_fields: tuple[str, ...]
    values: object


COFFEE_COLLECTIONS = {
    "products": Collection("products", ("name", "description", "category"), product_values),
    "orders": Collection("orders", ("items", "status"), order_values),
    "loyalty-points": Collection("loyalty_points", ("description",), loyalty_values),
}
