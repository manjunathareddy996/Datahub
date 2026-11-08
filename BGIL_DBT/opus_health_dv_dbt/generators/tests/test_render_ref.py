"""Unit test for references (task 5.12; Requirement 6.10).

A spec with one reference satellite emits ``ref_<name>.sql`` under
``models/raw_vault/standard/references/``.
"""
from __future__ import annotations

from types import SimpleNamespace

import pytest

from dvgen import emit, naming
from dvgen.model import Artifact, Column, IntermediateSpec, MappingRow, SatelliteFact, Table
from dvgen.plan import plan
from dvgen.render_ref import render_ref
from dvgen.render_stg1 import column_alias

REF_DIR = "models/raw_vault/standard/references/"
CODE = "REF_BANK_BRANCH_IFSC"
TABLE = "BJAZ_NEFT_IFSC_MASTER"
PREFIX = "OPUS_"
WATERMARK = "inc_job_updated_at"


def cfg():
    return SimpleNamespace(PROJECT="p", RECORD_SOURCE_PREFIX=PREFIX,
                           RECORD_SOURCE_GROUP="OPUS",
                           WATERMARK_COLUMN=WATERMARK,
                           WATERMARK_OVERRIDES={}, STG1_SOURCE="raw")


def spec_with_one_reference():
    tbl = Table(TABLE, TABLE.lower(),
                tuple(Column(c, "text", "untyped", False)
                      for c in ("IFSC_CODE", "MICR_CODE")), "unknown")
    sat = SatelliteFact(CODE, "reference", "HUB_BANK_BRANCH", "", "own_spec")
    rows = tuple(
        MappingRow(f"m#{i}", i, TABLE, col, "mapped", "satellite_attribute",
                   CODE, attr, None, None, None, None)
        for i, (col, attr) in enumerate((("IFSC_CODE", "IFSC Code"),
                                         ("MICR_CODE", "MICR Code")), 1))
    return IntermediateSpec("p", (tbl,), ("HUB_BANK_BRANCH",), (), (sat,), (),
                            rows, (), (), ())


def ref_artifact():
    name = naming.ref_model(CODE)
    stg1 = naming.stg1_model(TABLE.lower())
    return Artifact(
        kind="ref", path=f"{REF_DIR}{name}.sql", name=name,
        data={"ref": CODE, "record_source_prefix": PREFIX,
              "sources": [{
                  "source_model": stg1, "table": TABLE,
                  "record_source": naming.source_tag(PREFIX, TABLE),
                  "load_datetime": naming.watermark_for(TABLE, WATERMARK, {}),
                  "columns": [
                      {"column": naming.payload_column("IFSC Code"),
                       "expr": column_alias("IFSC_CODE")},
                      {"column": naming.payload_column("MICR Code"),
                       "expr": column_alias("MICR_CODE")}]}]})


def test_one_reference_satellite_renders_ref_view_under_references():
    art = ref_artifact()
    assert art.name == "ref_bank_branch_ifsc"
    assert art.path == "models/raw_vault/standard/references/ref_bank_branch_ifsc.sql"

    text = render_ref(art)
    assert text.startswith("{{ config(materialized='view') }}\n")
    assert emit.has_generated_header(text)
    assert text.count("select distinct") == 1
    assert "    ifsc_code as IFSCCODE,\n" in text
    assert "    micr_code as MICRCODE,\n" in text
    assert "    'OPUS_BJAZ_NEFT_IFSC_MASTER' as RECORD_SOURCE,\n" in text
    assert "    inc_job_updated_at as LOAD_DATETIME\n" in text
    assert text.endswith(
        "from {{ ref('stg_health__bjaz_neft_ifsc_master') }}\n")
    assert "\r" not in text and not text.endswith("\n\n")


def test_planner_plans_one_ref_artifact_for_reference_satellite():
    result = plan(spec_with_one_reference(), cfg())
    refs = [a for a in result.artifacts if a.kind == "ref"]
    assert len(refs) == 1
    (art,) = refs
    assert art.name == naming.ref_model(CODE)
    assert art.path == f"{REF_DIR}{art.name}.sql"
    text = render_ref(art)
    assert "IFSCCODE" in text and "MICRCODE" in text
    assert not [a for a in result.artifacts
                if a.kind == "sat" and a.name == naming.ref_model(CODE)]
