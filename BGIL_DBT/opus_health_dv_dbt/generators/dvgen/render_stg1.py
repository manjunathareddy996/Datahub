"""Render Stg1 models and the Health sources file (Requirements 3.2-3.8).

``render_stg1`` turns one ``stg1`` artifact into
``models/staging/health/stg_health__<stem>.sql``: a single ``source`` CTE over
``{{ source(SOURCE, TABLE) }}`` that casts every column, with no joins,
derived columns or hashing. Columns are sorted by name; the table's watermark
column comes last and is never selected twice.

Casts:

- text, untyped and key columns: ``nullif(trim(to_varchar("COL")), '')``
- number columns: ``"COL"::number``
- timestamp columns and the watermark: ``"COL"::timestamp_ntz``

The source column is always referenced quoted, in upper case. The output
alias is the lower-case name when that is a plain, non-reserved identifier
(Snowflake stores it upper case). Otherwise the alias is the quoted upper-case
name (``"FROM"``, ``"2D_ECHO"``), which names the same stored column. Use
``column_alias`` to get the alias a downstream model must reference.

``render_sources_yml`` renders ``models/staging/health/_health__sources.yml``
from a ``{source_name: (database_var, schema_var)}`` mapping and the Stg1
table list.

Artifact contract (``kind="stg1"``), ``data`` keys:
``table``, ``stem``, ``source``, ``columns`` (each ``name``, ``kind``,
``type_origin``, ``is_key``), ``watermark``, ``watermark_evidence``.

All functions are pure and deterministic. Output uses ``\\n`` line endings and
ends with one newline. This module is project-agnostic and is copied
byte-for-byte into the sibling Health_Project (Requirement 10.3).
"""
from __future__ import annotations

import re
from collections.abc import Iterable, Mapping
from typing import Any

from .emit import generated_header
from .model import COLUMN_KINDS, TYPE_ORIGINS, WATERMARK_EVIDENCE

__all__ = [
    "RenderStg1Error",
    "RESERVED_WORDS",
    "column_alias",
    "column_ref",
    "cast_expression",
    "render_stg1",
    "render_sources_yml",
]

RENDERER = "render_stg1"

DEFAULT_INDEX_LABEL = "inputs/00_tables_index.DELTA3.json"
DEFAULT_LEGACY_LABEL = "legacy staging SQL"

# Snowflake reserved keywords, plus words that appear as MAXIMUS column names
# and are reserved or keyword-like in other SQL dialects (BODY, SUBJECT).
# Quoting one of these in upper case names the same column as leaving it
# unquoted, so over-quoting is harmless.
RESERVED_WORDS = frozenset("""
ACCOUNT ALL ALTER AND ANY AS BETWEEN BODY BY CASE CAST CHECK COLUMN CONNECT
CONNECTION CONSTRAINT CREATE CROSS CURRENT CURRENT_DATE CURRENT_TIME
CURRENT_TIMESTAMP CURRENT_USER DATABASE DELETE DISTINCT DROP ELSE EXISTS FALSE
FOLLOWING FOR FROM FULL GRANT GROUP GSCLUSTER HAVING ILIKE IN INCREMENT INNER
INSERT INTERSECT INTO IS ISSUE JOIN LATERAL LEFT LIKE LOCALTIME LOCALTIMESTAMP
MINUS NATURAL NOT NULL OF ON OR ORDER ORGANIZATION QUALIFY REGEXP REVOKE RIGHT
RLIKE ROW ROWS SAMPLE SCHEMA SELECT SET SOME START SUBJECT TABLE TABLESAMPLE
THEN TO TRIGGER TRUE TRY_CAST UNION UNIQUE UPDATE USING VALUES VIEW WHEN
WHENEVER WHERE WINDOW WITH
""".split())

_PLAIN_IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
_YAML_NAME = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


class RenderStg1Error(ValueError):
    """A stg1 artifact or sources input is malformed."""


# --------------------------------------------------------------------------
# Column helpers
# --------------------------------------------------------------------------

def _clean(name: Any, what: str) -> str:
    if not isinstance(name, str) or not name.strip():
        raise RenderStg1Error(f"{what} is empty")
    return name.strip().strip('"').strip().upper()


def _quote(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def column_ref(name: str) -> str:
    """Quoted upper-case source reference: ``claim_id`` -> ``"CLAIM_ID"``."""
    return _quote(_clean(name, "column name"))


def column_alias(name: str) -> str:
    """Output alias: lower case if plain and not reserved, else quoted upper."""
    upper = _clean(name, "column name")
    if _PLAIN_IDENT.match(upper) and upper not in RESERVED_WORDS:
        return upper.lower()
    return _quote(upper)


def cast_expression(name: str, kind: str, is_key: bool = False) -> str:
    """Cast of one source column, without the alias."""
    if kind not in COLUMN_KINDS:
        raise RenderStg1Error(f"column {name!r}: unknown kind {kind!r}")
    ref = column_ref(name)
    if is_key or kind == "text":
        return f"nullif(trim(to_varchar({ref})), '')"
    if kind == "number":
        return f"{ref}::number"
    return f"{ref}::timestamp_ntz"


# --------------------------------------------------------------------------
# Stg1 model
# --------------------------------------------------------------------------

def _data(artifact: Any) -> Mapping[str, Any]:
    data = getattr(artifact, "data", artifact)
    if not isinstance(data, Mapping):
        raise RenderStg1Error("stg1 artifact data must be a mapping")
    kind = getattr(artifact, "kind", "stg1")
    if kind != "stg1":
        raise RenderStg1Error(f"render_stg1 got artifact kind {kind!r}")
    for key in ("table", "source", "columns", "watermark", "watermark_evidence"):
        if key not in data:
            raise RenderStg1Error(f"stg1 artifact data lacks {key!r}")
    return data


def _columns(table: str, raw: Iterable[Mapping[str, Any]]):
    out: dict[str, tuple[str, str, bool]] = {}
    for col in raw:
        name = _clean(col.get("name"), f"{table} column name")
        kind = col.get("kind")
        origin = col.get("type_origin")
        if kind not in COLUMN_KINDS:
            raise RenderStg1Error(f"{table}.{name}: unknown kind {kind!r}")
        if origin not in TYPE_ORIGINS:
            raise RenderStg1Error(
                f"{table}.{name}: unknown type_origin {origin!r}")
        if name in out:
            raise RenderStg1Error(f"{table}: duplicate column {name}")
        out[name] = (kind, origin, bool(col.get("is_key", False)))
    return out


def _plural(n: int, word: str) -> str:
    return f"{n} {word}" if n == 1 else f"{n} {word}s"


def render_stg1(artifact: Any, *, project: str | None = None,
                index_label: str = DEFAULT_INDEX_LABEL,
                legacy_label: str = DEFAULT_LEGACY_LABEL) -> str:
    """Render one Stg1 model from a ``stg1`` artifact (or its data mapping)."""
    data = _data(artifact)
    table = _clean(data["table"], "table")
    source = data["source"]
    if not isinstance(source, str) or not _YAML_NAME.match(source):
        raise RenderStg1Error(f"{table}: invalid source name {source!r}")
    watermark = _clean(data["watermark"], f"{table} watermark")
    evidence = data["watermark_evidence"]
    if evidence not in WATERMARK_EVIDENCE:
        raise RenderStg1Error(
            f"{table}: unknown watermark_evidence {evidence!r}")
    cols = _columns(table, data["columns"])

    counts = {o: 0 for o in TYPE_ORIGINS}
    for _, origin, _ in cols.values():
        counts[origin] += 1

    lob = "Health LOB" if not project else f"Health LOB, {project}"
    header = [
        generated_header(RENDERER),
        f"-- Staging model for source table {table} ({lob}).",
        "-- Casting: text -> nullif(trim(to_varchar(col)), ''); number -> ::number;",
        "--          date/timestamp -> ::timestamp_ntz. Key columns -> trimmed varchar.",
        f"-- Types are Derived_Facts read from {index_label} "
        f"({_plural(counts['index'], 'col')})",
        f"-- and {legacy_label} ({_plural(counts['legacy'], 'col')}); "
        f"{_plural(counts['untyped'], 'column')} untyped (cast as varchar).",
    ]
    if evidence == "catalogue_no":
        header.append(
            f"-- WATERMARK RISK: catalogue lists no {watermark} for this table.")

    selects = []
    for name in sorted(cols):
        if name == watermark:
            continue
        kind, _, is_key = cols[name]
        selects.append(
            f"    {cast_expression(name, kind, is_key)} as {column_alias(name)}")
    selects.append(
        f"    {cast_expression(watermark, 'timestamp')} "
        f"as {column_alias(watermark)}")

    lines = header + [
        "with source as (",
        "    select",
        ",\n".join(selects),
        f"    from {{{{ source('{source}', '{table}') }}}}",
        ")",
        "select * from source",
    ]
    return "\n".join(lines) + "\n"


# --------------------------------------------------------------------------
# Sources file
# --------------------------------------------------------------------------

def render_sources_yml(sources: Mapping[str, tuple[str, str]],
                       tables: Iterable[str]) -> str:
    """Render ``_health__sources.yml``.

    ``sources`` maps each source name to its ``(database_var, schema_var)``.
    Every source lists the same tables, upper-cased, de-duplicated and sorted.
    """
    if not sources:
        raise RenderStg1Error("no sources given")
    names = sorted({_clean(t, "table") for t in tables})
    if not names:
        raise RenderStg1Error("no tables given")
    for t in names:
        if not _PLAIN_IDENT.match(t):
            raise RenderStg1Error(f"table name {t!r} is not a plain identifier")
    lines = [generated_header(RENDERER, marker="#"), "version: 2", "",
             "sources:"]
    for i, src in enumerate(sorted(sources)):
        pair = sources[src]
        if not _YAML_NAME.match(src or ""):
            raise RenderStg1Error(f"invalid source name {src!r}")
        if not isinstance(pair, (tuple, list)) or len(pair) != 2:
            raise RenderStg1Error(
                f"source {src!r}: expected (database_var, schema_var)")
        db_var, schema_var = pair
        for var in (db_var, schema_var):
            if not isinstance(var, str) or not _YAML_NAME.match(var):
                raise RenderStg1Error(f"source {src!r}: invalid var {var!r}")
        if i:
            lines.append("")
        lines += [
            f"  - name: {src}",
            f"    database: \"{{{{ var('{db_var}') }}}}\"",
            f"    schema: \"{{{{ var('{schema_var}') }}}}\"",
            "    tables:",
        ]
        lines += [f"      - name: {t}" for t in names]
    return "\n".join(lines) + "\n"
