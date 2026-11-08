"""Unit tests for dvgen.plan steps 1-3: tables, satellite facts, derived facts.

Requirements 3.1, 3.9, 4.1, 4.3, 4.4.
"""
from __future__ import annotations

from types import SimpleNamespace

import pytest

from dvgen.model import (
    Column,
    DerivedFact,
    IntermediateSpec,
    KeySlot,
    MappingRow,
    SatelliteFact,
    Table,
    Walk,
    WatermarkRisk,
    dumps,
)
from dvgen.plan import (
    PlanError,
    SiblingModel,
    hist_skips,
    plan,
    resolve_satellite,
)


def cfg(**over):
    base = dict(PROJECT="p", RECORD_SOURCE_PREFIX="OPUS_",
                RECORD_SOURCE_GROUP="OPUS", WATERMARK_COLUMN="inc_job_updated_at",
                WATERMARK_OVERRIDES={}, STG1_SOURCE="health_test_raw",
                SPEC_SOURCE="build_artifacts/hcon_spec.json",
                COLUMN_CATALOGUE="inputs/00_tables_index.DELTA3.json")
    base.update(over)
    return SimpleNamespace(**base)


def col(name, kind="text", origin="untyped", key=False):
    return Column(name, kind, origin, key)


def table(name, cols=(), evidence="unknown", stem=None):
    return Table(name, stem or name.lower(), tuple(cols), evidence)


def row(i, tbl, column, code="SAT_A", attr="Attr", outcome="mapped",
        kind="satellite_attribute"):
    return MappingRow(f"m#{i}", i, tbl, column, outcome, kind, code, attr,
                      None, None, None, None)


def spec(tables=(), rows=(), slots=(), walks=(), sats=(), hubs=(), links=()):
    return IntermediateSpec("p", tuple(tables), tuple(hubs), tuple(links),
                            tuple(sats), tuple(slots), tuple(rows), (),
                            tuple(walks), ())


def stg1(p):
    return {a.data["table"]: a for a in p.artifacts if a.kind == "stg1"}


# --------------------------------------------------------------------------
# Tables
# --------------------------------------------------------------------------

def test_one_stg1_per_referenced_table_only():
    s = spec(
        tables=[table("T_ROW", [col("A")]), table("T_AUG", [col("B")]),
                table("T_SLOT", [col("K")]), table("T_WALK"),
                table("T_UNUSED", [col("Z")])],
        rows=[row(1, "T_ROW", "A"),
              row(2, "T_AUG", "B", outcome="augmentation_needed",
                  kind="augmentation")],
        slots=[KeySlot("T_SLOT", "HUB_X", None, "K", ("K",), "spec.key_slot")],
        walks=[Walk("spans#0", "T_SLOT", "PARENT_KEY_HASH", (), (), "T_WALK",
                    "KEY_HASH", "raw")],
    )
    arts = stg1(plan(s, cfg()))
    assert sorted(arts) == ["T_AUG", "T_ROW", "T_SLOT", "T_WALK"]
    a = arts["T_ROW"]
    assert a.path == "models/staging/health/stg_health__t_row.sql"
    assert a.name == "stg_health__t_row"
    assert a.data["source"] == "health_test_raw"
    assert a.data["stem"] == "t_row"


def test_stg1_data_columns_sorted_key_flag_and_watermark_excluded():
    s = spec(
        tables=[table("T", [col("Z_COL", "number", "index"),
                            col("INC_JOB_UPDATED_AT", "timestamp", "index"),
                            col("A_KEY", "number", "index"),
                            col("M", key=True)], evidence="catalogue_yes")],
        slots=[KeySlot("T", "HUB_X", None, "a_key", ("A_KEY",),
                       "spec.key_slot")],
    )
    p = plan(s, cfg())
    data = stg1(p)["T"].data
    assert [c["name"] for c in data["columns"]] == ["A_KEY", "M", "Z_COL"]
    assert [c["is_key"] for c in data["columns"]] == [True, True, False]
    assert dict(data["columns"][2]) == {"name": "Z_COL", "kind": "number",
                                        "type_origin": "index",
                                        "is_key": False}
    assert data["watermark"] == "inc_job_updated_at"
    assert data["watermark_evidence"] == "catalogue_yes"
    assert p.watermark_risks == ()


def test_hist_skip_rule():
    names = {"CLM_HIST", "CLM", "POL_HIST", "POLICY_CLAIM_HISTORY",
             "POLICY_CLAIM"}
    assert hist_skips(names) == {"CLM_HIST": "CLM"}
    s = spec(tables=[table(n) for n in names],
             rows=[row(i, n, "C") for i, n in enumerate(sorted(names))])
    p = plan(s, cfg())
    assert sorted(stg1(p)) == ["CLM", "POLICY_CLAIM", "POLICY_CLAIM_HISTORY",
                               "POL_HIST"]
    assert p.hist_skips == (("CLM_HIST", "CLM"),)


def test_watermark_override_and_risks():
    s = spec(tables=[table("T_NO", evidence="catalogue_no"),
                     table("T_UNK"), table("T_YES", evidence="catalogue_yes"),
                     table("T_OVR", evidence="catalogue_no")],
             rows=[row(i, n, "C") for i, n in
                   enumerate(["T_NO", "T_UNK", "T_YES", "T_OVR"])])
    p = plan(s, cfg(WATERMARK_OVERRIDES={"T_OVR": "rec_refresh_at"}))
    arts = stg1(p)
    assert arts["T_OVR"].data["watermark"] == "rec_refresh_at"
    assert arts["T_OVR"].data["watermark_evidence"] == "unknown"
    assert arts["T_NO"].data["watermark"] == "inc_job_updated_at"
    assert p.watermark_risks == (
        WatermarkRisk("T_NO", "catalogue_no",
                      "inputs/00_tables_index.DELTA3.json"),
        WatermarkRisk("T_UNK", "unknown", "no column catalogue entry"),
    )


def test_stem_collision_and_missing_table_stop_the_build():
    s = spec(tables=[table("A", stem="x"), table("B", stem="x")],
             rows=[row(1, "A", "C"), row(2, "B", "C")])
    with pytest.raises(PlanError, match="stem collision"):
        plan(s, cfg())
    with pytest.raises(PlanError, match="NOPE"):
        plan(spec(rows=[row(1, "NOPE", "C")]), cfg())


# --------------------------------------------------------------------------
# Satellite facts
# --------------------------------------------------------------------------

SIB = SiblingModel(sat_parent={"SAT_S": "HUB_S", "SAT_E": ""},
                   source="../maximus_health_dv_dbt/build_artifacts/mxh3_spec.json")


def test_resolve_satellite_fallback_order():
    own = resolve_satellite(SatelliteFact("SAT_S", "standard", "HUB_OWN", "",
                                          "own_spec"), SIB)
    assert own.fact.parent == "HUB_OWN" and own.fact.parent_origin == "own_spec"
    sib = resolve_satellite(SatelliteFact("SAT_S", "standard", "", "Code",
                                          "none"), SIB)
    assert sib.fact.parent == "HUB_S"
    assert sib.fact.parent_origin == "sibling_model"
    assert sib.fact.childkey == "Code"
    gone = resolve_satellite(SatelliteFact("SAT_E", "standard", None, "",
                                           "none"), SIB)
    assert gone.fact is None and gone.situations == ("parent_empty",)
    nock = resolve_satellite(SatelliteFact("SAT_S", "standard", "HUB_S", None,
                                           "own_spec"), SIB)
    assert nock.fact is None and nock.situations == ("childkey_field_absent",)


def test_omitted_satellites_become_gaps():
    s = spec(
        tables=[table("T", [col("A"), col("B")])],
        rows=[row(1, "T", "A", code="SAT_E", attr="Note"),
              row(2, "T", "A", code="SAT_E", attr="Note"),
              row(3, "T", "B", code="SAT_BOTH", attr="X")],
        sats=[SatelliteFact("SAT_E", "standard", "", "", "none"),
              SatelliteFact("SAT_CK", "standard", "HUB_C", None, "own_spec"),
              SatelliteFact("SAT_BOTH", "standard", None, None, "none"),
              SatelliteFact("SAT_OK", "standard", "HUB_C", "", "own_spec")],
    )
    p = plan(s, cfg(), SIB)
    got = {(g.target, g.source_table, g.source_column, g.reason, g.row_ids)
           for g in p.gaps}
    assert got == {
        ("SAT_E.Note", "T", "A", "missing_parent", ("m#1", "m#2")),
        ("SAT_CK", "", None, "missing_childkey_field", ()),
        ("SAT_BOTH.X", "T", "B", "missing_parent", ("m#3",)),
        ("SAT_BOTH", "", None, "missing_childkey_field", ()),
    }
    facts = {(f.category, f.subject) for f in p.derived_facts}
    assert ("satellite_parent", "SAT_OK (standard)") in facts
    assert not any("SAT_E" in subj or "SAT_CK" in subj for _, subj in facts)


def test_derived_facts_record_origin():
    s = spec(hubs=["HUB_A"], links=["LNK_A_B"],
             sats=[SatelliteFact("SAT_S", "standard", "", "Code", "none"),
                   SatelliteFact("SAT_O", "augmented", "HUB_A", "", "own_spec")])
    p = plan(s, cfg(), SIB)
    src = "build_artifacts/hcon_spec.json"
    assert set(p.derived_facts) == {
        DerivedFact("hub", "HUB_A", None, "own_spec", src),
        DerivedFact("link", "LNK_A_B", None, "own_spec", src),
        DerivedFact("satellite_parent", "SAT_S (standard)", "HUB_S",
                    "sibling_model", SIB.source),
        DerivedFact("satellite_childkey", "SAT_S (standard)", "Code",
                    "own_spec", src),
        DerivedFact("hub", "HUB_S", None, "sibling_model", SIB.source),
        DerivedFact("satellite_parent", "SAT_O (augmented)", "HUB_A",
                    "own_spec", src),
        DerivedFact("satellite_childkey", "SAT_O (augmented)", "", "own_spec",
                    src),
    }


def test_sibling_model_from_mxh3():
    sib = SiblingModel.from_mxh3({"model": {"sat_parent": {"SAT_A": "HUB_A",
                                                           "SAT_B": ""},
                                            "sat_childkey": {"SAT_A": ""}}})
    assert sib.parent("SAT_A") == "HUB_A"
    assert sib.parent("SAT_B") is None and sib.parent("SAT_Z") is None
    with pytest.raises(PlanError):
        SiblingModel.from_mxh3({})


def test_plan_is_order_independent():
    tables = [table("T1", [col("A"), col("B")]), table("T2", [col("C")])]
    rows = [row(1, "T1", "A", code="SAT_E"), row(2, "T2", "C")]
    sats = [SatelliteFact("SAT_E", "standard", "", "", "none"),
            SatelliteFact("SAT_A", "standard", "HUB_A", "", "own_spec")]
    a = plan(spec(tables, rows, sats=sats, hubs=["HUB_A"]), cfg())
    b = plan(spec(tables[::-1], rows[::-1], sats=sats[::-1], hubs=["HUB_A"]),
             cfg())
    assert a == b
    assert dumps(a) == dumps(b)
