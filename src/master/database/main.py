
import sqlite3
from pathlib import Path

# Project root: ~/vasco
ROOT = Path(__file__).resolve().parent.parent.parent

SCHEMA_PATH = ROOT / "master" / "database" / "schema.sql"
DB_PATH = ROOT / "data" / "vasco.db"


def get_connection():
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)

    connection = sqlite3.connect(DB_PATH)
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA foreign_keys = ON")

    return connection


def init_db():
    schema = SCHEMA_PATH.read_text(encoding="utf-8")

    with get_connection() as connection:
        connection.executescript(schema)

    print(f"Database initialized: {DB_PATH}")


if __name__ == "__main__":
    init_db()
