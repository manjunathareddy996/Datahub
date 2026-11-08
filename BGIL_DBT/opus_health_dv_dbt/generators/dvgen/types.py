"""Column type sources for the Stg1 casts (Requirements 3.7, 3.8).

Two sources give a column kind (``text``, ``number`` or ``timestamp``):

- ``index_types`` reads ``inputs/00_tables_index.DELTA3.json``.
- ``legacy_types`` parses the legacy staging SQL kept in the Legacy_Archive
  (``legacy_v3/models/staging/*.sql``).

``resolve_type`` picks the kind for one column: the tables index first, then
the legacy SQL, then ``('text', 'untyped')``. Untyped columns are cast as
trimmed varchar and listed in the LOB_README.

Legacy cast forms:

- ``cast(COL as varchar)`` gives no type. A legacy build that casts every
  column to varchar by policy (OPUS builder decision BD3) carries no type
  information, so the cast is not evidence of a text column.
- ``COL::varchar`` gives ``text``, ``COL::number`` gives ``number`` and
  ``COL::timestamp_ntz`` (or ``::date``, ``::timestamp``) gives
  ``timestamp``. A ``cast(COL as number)`` style cast to a non-varchar type
  is typed the same way.

Each legacy file must read from exactly one ``{{ source('<src>', '<TABLE>') }}``;
its columns are keyed under that physical table name. Table and column names
are upper-cased; double-quoted identifiers lose their quotes. Files are read
in sorted order and every returned mapping has sorted keys, so the result
does not depend on file-system order. Conflicting kinds for one column raise
``TypesError``, as does an unknown type name.

This module is project-agnostic and is copied byte-for-byte into the sibling
Health_Project (Requirement 10.3).
"""
from __future__ import annotations

import json
import re
from collections.abc import Mapping
from pathlib import Path

from .model import COLUMN_KINDS, TYPE_ORIGINS

UNTYPED = ("text", "untyped")

# Base type name (upper case, no length or precision) -> column kind.
_KIND_BY_TYPE = {
    "NUMBER": "number",
    "NUMERIC": "number",
    "DECIMAL": "number",
    "INT": "number",
    "INTEGER": "number",
    "BIGINT": "number",
    "SMALLINT": "number",
    "FLOAT": "number",
    "DOUBLE": "number",
    "TEXT": "text",
    "VARCHAR": "text",
    "VARCHAR2": "text",
    "NVARCHAR2": "text",
    "CHAR": "text",
    "STRING": "text",
    "DATE": "timestamp",
    "TIMESTAMP": "timestamp",
    "TIMESTAMP_NTZ": "timestamp",
    "DATETIME": "timestamp",
}

# The types the tables index is allowed to carry (design Q9).
_INDEX_TYPES = frozenset(
    {"NUMBER", "TEXT", "VARCHAR2", "CHAR", "DATE", "TIMESTAMP_NTZ"})

assert set(_KIND_BY_TYPE.values()) <= COLUMN_KINDS
assert UNTYPED[0] in COLUMN_KINDS and UNTYPED[1] in TYPE_ORIGINS
assert {"index", "legacy"} <= TYPE_ORIGINS


class TypesError(ValueError):
    """A type source is malformed, ambiguous or uses an unknown type."""


def _base_type(raw: str) -> str:
    """'VARCHAR2(100) not null,' -> 'VARCHAR2'; 'number(5)' -> 'NUMBER'."""
    match = re.match(r"\s*([A-Za-z_][A-Za-z0-9_]*)", raw or "")
    return match.group(1).upper() if match else ""


def _kind(type_name: str, where: str) -> str:
    base = _base_type(type_name)
    kind = _KIND_BY_TYPE.get(base)
    if kind is None:
        raise TypesError(f"{where}: unknown type {type_name!r}")
    return kind


def _put(out: dict[str, dict[str, str]], table: str, column: str, kind: str,
         where: str) -> None:
    cols = out.setdefault(table, {})
    prior = cols.get(column)
    if prior is not None and prior != kind:
        raise TypesError(
            f"{where}: {table}.{column} typed both {prior!r} and {kind!r}")
    cols[column] = kind


def _sorted(out: dict[str, dict[str, str]]) -> dict[str, dict[str, str]]:
    return {t: {c: out[t][c] for c in sorted(out[t])} for t in sorted(out)}


# --------------------------------------------------------------------------
# Legacy staging SQL
# --------------------------------------------------------------------------

_IDENT = r'(?:"[^"]+"|[A-Za-z_][A-Za-z0-9_$]*)'
_QUALIFIED = rf"{_IDENT}(?:\s*\.\s*{_IDENT})*"
_TYPE = r"[A-Za-z_][A-Za-z0-9_]*(?:\s*\(\s*\d+(?:\s*,\s*\d+)?\s*\))?"

_CAST_RE = re.compile(
    rf"\bcast\s*\(\s*(?P<col>{_QUALIFIED})\s+as\s+(?P<type>{_TYPE})\s*\)",
    re.IGNORECASE)
_DCOLON_RE = re.compile(
    rf"(?P<col>{_QUALIFIED})\s*::\s*(?P<type>{_TYPE})", re.IGNORECASE)
_SOURCE_RE = re.compile(
    r"\bsource\s*\(\s*['\"]([^'\"]+)['\"]\s*,\s*['\"]([^'\"]+)['\"]\s*\)")
_BLOCK_COMMENT_RE = re.compile(r"/\*.*?\*/", re.DOTALL)
_JINJA_COMMENT_RE = re.compile(r"\{#.*?#\}", re.DOTALL)
_LINE_COMMENT_RE = re.compile(r"--[^\n]*")


def _strip_comments(sql: str) -> str:
    sql = _JINJA_COMMENT_RE.sub(" ", sql)
    sql = _BLOCK_COMMENT_RE.sub(" ", sql)
    return _LINE_COMMENT_RE.sub(" ", sql)


def _column_name(qualified: str) -> str:
    """'t."2D_ECHO"' -> '2D_ECHO'; 'claim_id' -> 'CLAIM_ID'."""
    last = re.split(r"\s*\.\s*", qualified.strip())[-1]
    return last.strip('"').strip().upper()


def parse_legacy_sql(sql: str, where: str = "<sql>") -> tuple[str, dict[str, str]]:
    """Parse one legacy staging model. Return (TABLE, {COLUMN: kind})."""
    body = _strip_comments(sql)
    sources = _SOURCE_RE.findall(body)
    tables = sorted({name.strip().upper() for _, name in sources})
    if len(tables) != 1:
        raise TypesError(
            f"{where}: expected one source() table, found {tables or 'none'}")
    table = tables[0]
    found: dict[str, dict[str, str]] = {}
    found[table] = {}
    for match in _DCOLON_RE.finditer(body):
        _put(found, table, _column_name(match.group("col")),
             _kind(match.group("type"), where), where)
    for match in _CAST_RE.finditer(body):
        if _base_type(match.group("type")) == "VARCHAR":
            continue  # cast(X as varchar) carries no type information
        _put(found, table, _column_name(match.group("col")),
             _kind(match.group("type"), where), where)
    return table, found[table]


def legacy_types(staging_dir: Path) -> dict[str, dict[str, str]]:
    """Parse legacy stg SQL. 'cast(COL as varchar)' yields no type (OPUS BD3).
    'COL::number' yields 'number'. Returns {TABLE: {COLUMN: kind}}."""
    staging_dir = Path(staging_dir)
    if not staging_dir.is_dir():
        raise TypesError(f"legacy staging directory not found: {staging_dir}")
    out: dict[str, dict[str, str]] = {}
    for path in sorted(staging_dir.glob("*.sql"), key=lambda p: p.name):
        where = path.name
        table, cols = parse_legacy_sql(path.read_text(encoding="utf-8"), where)
        out.setdefault(table, {})
        for column in sorted(cols):
            _put(out, table, column, cols[column], where)
    return _sorted(out)


# --------------------------------------------------------------------------
# Tables index
# --------------------------------------------------------------------------

def index_types(index_json: Path) -> dict[str, dict[str, str]]:
    """00_tables_index.DELTA3.json -> {TABLE: {COLUMN: kind}}.
    NUMBER->number; TEXT/VARCHAR2/CHAR->text; DATE/TIMESTAMP_NTZ->timestamp."""
    index_json = Path(index_json)
    try:
        body = json.loads(index_json.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise TypesError(f"{index_json.name}: not valid JSON: {exc}") from None
    tables = body.get("tables") if isinstance(body, dict) else None
    if not isinstance(tables, list):
        raise TypesError(f"{index_json.name}: missing 'tables' list")
    out: dict[str, dict[str, str]] = {}
    for t_pos, table in enumerate(tables):
        where = f"{index_json.name}: tables[{t_pos}]"
        name = (table or {}).get("table_name") if isinstance(table, dict) else None
        if not isinstance(name, str) or not name.strip():
            raise TypesError(f"{where}: missing table_name")
        tname = name.strip().upper()
        out.setdefault(tname, {})
        for c_pos, col in enumerate(table.get("columns") or []):
            cwhere = f"{where}.columns[{c_pos}]"
            cname = col.get("name_normalized") or col.get("name")
            if not isinstance(cname, str) or not cname.strip():
                raise TypesError(f"{cwhere}: missing column name")
            raw = col.get("data_type") or col.get("data_type_raw") or ""
            base = _base_type(raw)
            if base not in _INDEX_TYPES:
                raise TypesError(f"{cwhere}: unknown type {raw!r}")
            _put(out, tname, cname.strip().upper(), _KIND_BY_TYPE[base],
                 cwhere)
    return _sorted(out)


# --------------------------------------------------------------------------
# Resolution
# --------------------------------------------------------------------------

def resolve_type(table: str, column: str,
                 index: Mapping[str, Mapping[str, str]],
                 legacy: Mapping[str, Mapping[str, str]]) -> tuple[str, str]:
    """Return (kind, origin). Precedence: index, then legacy, then
    ('text', 'untyped'). 'untyped' columns are listed in the README."""
    t = table.strip().upper()
    c = column.strip().strip('"').upper()
    kind = (index.get(t) or {}).get(c)
    if kind is not None:
        return kind, "index"
    kind = (legacy.get(t) or {}).get(c)
    if kind is not None:
        return kind, "legacy"
    return UNTYPED
