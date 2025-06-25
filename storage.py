"""Simple SQLite storage for cached vCenter data and delta updates."""
import json
import sqlite3
from pathlib import Path
from typing import List, Dict, Any

DB_PATH = Path(__file__).with_name("vcache.db")


def get_conn():
    conn = sqlite3.connect(DB_PATH)
    conn.execute(
        """CREATE TABLE IF NOT EXISTS snapshot (
            entity_type TEXT NOT NULL,
            key TEXT NOT NULL,
            data TEXT NOT NULL,
            PRIMARY KEY(entity_type, key)
        )"""
    )
    return conn


def bulk_upsert(entity_type: str, items: List[Dict[str, Any]], key_field: str = "name"):
    conn = get_conn()
    cur = conn.cursor()
    for item in items:
        key_val = str(item.get(key_field))
        cur.execute(
            "INSERT OR REPLACE INTO snapshot(entity_type,key,data) VALUES(?,?,?)",
            (entity_type, key_val, json.dumps(item)),
        )
    conn.commit()
    conn.close()


def read_all(entity_type: str) -> List[Dict[str, Any]]:
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SELECT data FROM snapshot WHERE entity_type=?", (entity_type,))
    rows = [json.loads(r[0]) for r in cur.fetchall()]
    conn.close()
    return rows
