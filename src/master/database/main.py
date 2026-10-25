import sqlite3
from pathlib import Path

# Project root: ~/vasco
ROOT = Path(__file__).resolve().parent.parent.parent

SCHEMA_PATH = ROOT / "master" / "database" / "schema.sql"
DB_PATH = ROOT / "data" / "vasco.db"

URLS = set()


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


def load_urls():
    pendingCount = (
        get_connection()
        .execute(
            "SELECT COUNT(*) FROM urls WHERE status IN ('pending' , 'queued' , 'failed' , 'skipped') "
        )
        .fetchone()
    )

    if pendingCount[0] >= 10_000:
        urls = (
            get_connection()
            .execute(
                "SELECT url FROM urls WHERE status IN ('pending' , 'queued' , 'failed' , 'skipped') "
            )
            .fetchall()
        )

        # We're extending the global list as to allow workers to get a url to be processed
        URLS.update(urls)

    else:

        with open(Path(__file__).resolve().parent.parent / "seeds.txt") as seedFile:

            for line in seedFile:
                URLS.add(line.strip())


if __name__ == "__main__":
    init_db()
