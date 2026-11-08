"""Unit tests for dvgen.types (Requirements 3.7, 3.8)."""
from __future__ import annotations

import json
from pathlib import Path

import pytest

from dvgen.model import COLUMN_KINDS, TYPE_ORIGINS
from dvgen.types import (
    TypesError, index_types, legacy_types, parse_legacy_sql, resolve_type,
)

PROJECTS_ROOT = Path(__file__).resolve().parents[3]

OPUS_STYLE = """{{ config(materialized='view') }}
/* datatypes : every column cast to varchar (BD3). cast(FAKE as number) */
select
    cast(CLAIM_ID as varchar) as CLAIM_ID,
    cast(amount as varchar) as AMOUNT
from {{ source('opus_health_delta3', 'BJAZ_CLAIMS') }}
"""

MAXIMUS_STYLE = """{{ config(materialized='view') }}
-- source view : MAXI_CLAIM_DETAIL   KEY_HASH::timestamp in a comment
select
    claim_number::varchar as CLAIM_NUMBER,
    KEY_HASH::number as KEY_HASH,
    "2D_ECHO"::varchar as "2D_ECHO",
    PAID_ON::timestamp_ntz as PAID_ON,
    AMT::number(18, 2) as AMT
from {{ source('maxi_hlth_v3', 'maxi_claim_detail') }}
"""


def _write(dir_: Path, name: str, text: str) -> Path:
    dir_.mkdir(parents=True, exist_ok=True)
    path = dir_ / name
    path.write_text(text, encoding="utf-8")
    return path


def _index(path: Path, tables: list[dict]) -> Path:
    path.write_text(json.dumps({"stage": "00_tables_index", "tables": tables}),
                    encoding="utf-8")
    return path


def _col(name: str, data_type: str, raw: str | None = None) -> dict:
    return {"name": name, "name_normalized": name.strip().upper(),
            "data_type": data_type, "data_type_raw": raw or data_type}


# ---------------------------------------------------------------- legacy

def test_cast_as_varchar_gives_no_type():
    table, cols = parse_legacy_sql(OPUS_STYLE)
    assert table == "BJAZ_CLAIMS"
    assert cols == {}  # comment text is ignored too


def test_double_colon_casts_are_typed_and_upper_cased():
    table, cols = parse_legacy_sql(MAXIMUS_STYLE)
    assert table == "MAXI_CLAIM_DETAIL"
    assert cols == {
        "CLAIM_NUMBER": "text",
        "KEY_HASH": "number",
        "2D_ECHO": "text",
        "PAID_ON": "timestamp",
        "AMT": "number",
    }


def test_legacy_types_reads_dir_sorted(tmp_path):
    d = tmp_path / "staging"
    _write(d, "stg_b.sql", MAXIMUS_STYLE)
    _write(d, "stg_a.sql", OPUS_STYLE)
    _write(d, "notes.txt", "KEY::number")  # not a .sql file
    result = legacy_types(d)
    assert list(result) == ["BJAZ_CLAIMS", "MAXI_CLAIM_DETAIL"]
    assert result["BJAZ_CLAIMS"] == {}
    assert list(result["MAXI_CLAIM_DETAIL"]) == sorted(
        result["MAXI_CLAIM_DETAIL"])
    assert legacy_types(d) == result


def test_legacy_conflicting_kinds_raise(tmp_path):
    d = tmp_path / "staging"
    _write(d, "stg_1.sql", "select X::number as X from {{ source('s', 'T') }}")
    _write(d, "stg_2.sql", "select X::varchar as X from {{ source('s', 'T') }}")
    with pytest.raises(TypesError, match="T.X"):
        legacy_types(d)


def test_legacy_requires_one_source_and_known_types():
    with pytest.raises(TypesError, match="source"):
        parse_legacy_sql("select X::number as X from raw_table")
    with pytest.raises(TypesError, match="unknown type"):
        parse_legacy_sql("select X::variant as X from {{ source('s', 'T') }}")


def test_legacy_missing_dir_raises(tmp_path):
    with pytest.raises(TypesError):
        legacy_types(tmp_path / "absent")


# ----------------------------------------------------------------- index

def test_index_type_mapping(tmp_path):
    path = _index(tmp_path / "ix.json", [
        {"table_name": "bjaz_claims", "columns": [
            _col("Claim_Id", "TEXT"),
            _col("AMOUNT", "NUMBER", "NUMBER(10) not null,"),
            _col("REMARKS", "VARCHAR2", "VARCHAR2(200),"),
            _col("FLAG", "CHAR", "char(1)"),
            _col("OPENED", "DATE"),
            _col("UPDATED_AT", "TIMESTAMP_NTZ"),
        ]},
    ])
    assert index_types(path) == {"BJAZ_CLAIMS": {
        "AMOUNT": "number",
        "CLAIM_ID": "text",
        "FLAG": "text",
        "OPENED": "timestamp",
        "REMARKS": "text",
        "UPDATED_AT": "timestamp",
    }}


def test_index_unknown_type_raises(tmp_path):
    path = _index(tmp_path / "ix.json", [
        {"table_name": "T", "columns": [_col("X", "BLOB")]}])
    with pytest.raises(TypesError, match="unknown type"):
        index_types(path)


# --------------------------------------------------------------- resolve

def test_resolve_precedence():
    index = {"T": {"A": "number"}}
    legacy = {"T": {"A": "text", "B": "timestamp"}}
    assert resolve_type("T", "A", index, legacy) == ("number", "index")
    assert resolve_type("t", "b", index, legacy) == ("timestamp", "legacy")
    assert resolve_type("T", "C", index, legacy) == ("text", "untyped")
    assert resolve_type("OTHER", "A", index, legacy) == ("text", "untyped")
    for args in (("T", "A"), ("T", "B"), ("T", "C")):
        kind, origin = resolve_type(*args, index, legacy)
        assert kind in COLUMN_KINDS and origin in TYPE_ORIGINS


# ------------------------------------------------ real inputs (read-only)

@pytest.mark.parametrize("project", ["opus_health_dv_dbt",
                                     "maximus_health_dv_dbt"])
def test_real_legacy_staging_parses(project):
    d = PROJECTS_ROOT / project / "legacy_v3" / "models" / "staging"
    if not d.is_dir():
        pytest.skip(f"{d} not present")
    result = legacy_types(d)
    assert result
    kinds = {k for cols in result.values() for k in cols.values()}
    assert kinds <= COLUMN_KINDS
    if project == "opus_health_dv_dbt":
        assert kinds == set()  # every OPUS cast is cast(X as varchar)


def test_real_tables_index_parses():
    path = (PROJECTS_ROOT / "opus_health_dv_dbt" / "inputs"
            / "00_tables_index.DELTA3.json")
    if not path.is_file():
        pytest.skip(f"{path} not present")
    result = index_types(path)
    assert len(result) == 20
    assert sum(len(c) for c in result.values()) == 716
