"""Unit tests for dvgen.model: validation, plan ordering and spec JSON."""
from __future__ import annotations

import dataclasses
import json

import pytest

from dvgen.model import (
    Artifact, Column, DerivedFact, FrozenDict, Gap, IntermediateSpec,
    KeySlot, MappingRow, ModelError, Plan, SatelliteFact, Table, Walk,
    WatermarkRisk, SPEC_SCHEMA, dump_spec, load_spec, parse_spec,
)


def _spec() -> IntermediateSpec:
    t1 = Table("BJAZ_HM_GPA_BILL_DTLS", "bjaz_hm_gpa_bill_dtls", (
        Column("ROOM_RENT_AMT", "number", "index", False),
        Column("CLAIM_ID", "text", "index", True),
    ), "catalogue_yes")
    t2 = Table("BA_CCP_INSURED_DETAILS", "ba_ccp_insured_details", (
        Column("FIRST_NAME", "text", "untyped", False),
    ), "catalogue_no")
    return IntermediateSpec(
        project="opus_health_dv_dbt",
        tables=(t1, t2),
        hubs=("HUB_POLICY", "HUB_CLAIM"),
        links=("LNK_CLAIM_POLICY",),
        satellites=(
            SatelliteFact("SAT_CLAIM_NOTE", "standard", "HUB_CLAIM", "",
                          "own_spec"),
            SatelliteFact("SAT_CLAIM_BENEFIT_HEAD", "standard", "HUB_CLAIM",
                          "Benefit Head Code", "sibling_model"),
            SatelliteFact("SAT_X", "augmented", None, None, "none"),
        ),
        key_slots=(
            KeySlot("BJAZ_HM_GPA_BILL_DTLS", "HUB_CLAIM", None, "CLAIM_ID",
                    ("CLAIM_ID",), "spec.key_slot"),
            KeySlot("BJAZ_HM_GPA_BILL_DTLS", "LNK_CLAIM_POLICY", "x",
                    "CLAIM_ID || POLICY_NO", ("POLICY_NO", "CLAIM_ID"),
                    "map.KEY"),
        ),
        rows=(
            MappingRow("DELTA3#0", 5, "BJAZ_HM_GPA_BILL_DTLS",
                       "ROOM_RENT_AMT", "mapped", "satellite_attribute",
                       "SAT_CLAIM_BENEFIT_HEAD", "Benefit Amount",
                       "Room Rent", None, None, None),
            MappingRow("SETTLED#1", 1, "BA_CCP_INSURED_DETAILS", "FIRST_NAME",
                       "augmentation_needed", "augmentation", "SAT_X",
                       "First Name — ünïcode", None, None, None,
                       "anchor_not_keyed_on_this_view_in_legacy_sql"),
        ),
        precedence=(("SAT_B", "Attr", ("T2", "T1")),
                    ("SAT_A", "Attr", ("T1", "T2"))),
        walks=(Walk("spans#0", "A", "PARENT_KEY_HASH", ("B", "C"), ("D",),
                    "D", "CLAIM_NUMBER", "spine[...]"),),
        input_digests=(("inputs/b.json", "bb"), ("inputs/a.json", "aa")),
    )


def _reverse_all(spec: IntermediateSpec) -> IntermediateSpec:
    """Same facts, every top-level collection (and columns) reversed."""
    return dataclasses.replace(
        spec,
        tables=tuple(dataclasses.replace(t, columns=t.columns[::-1])
                     for t in spec.tables[::-1]),
        hubs=spec.hubs[::-1], links=spec.links[::-1],
        satellites=spec.satellites[::-1], key_slots=spec.key_slots[::-1],
        rows=spec.rows[::-1], precedence=spec.precedence[::-1],
        walks=spec.walks[::-1], input_digests=spec.input_digests[::-1],
    )


def test_spec_round_trip_preserves_canonical_spec(tmp_path):
    spec = _spec()
    text = dump_spec(spec)
    path = tmp_path / "health_spec.json"
    path.write_bytes(text.encode("utf-8"))
    loaded = load_spec(path)
    assert loaded == spec.canonical()
    assert dump_spec(loaded) == text


def test_dump_is_order_independent_and_sorted():
    spec = _spec()
    text = dump_spec(spec)
    assert dump_spec(_reverse_all(spec)) == text
    assert text.endswith("}\n") and not text.endswith("\n\n")
    assert "\r" not in text
    body = json.loads(text)
    assert body["schema"] == SPEC_SCHEMA
    assert list(body) == sorted(body)
    assert [t["name"] for t in body["tables"]] == sorted(
        t.name for t in spec.tables)


def test_canonical_keeps_inner_order():
    canon = _spec().canonical()
    lnk = [k for k in canon.key_slots if k.vault_code == "LNK_CLAIM_POLICY"]
    assert lnk[0].source_columns == ("POLICY_NO", "CLAIM_ID")
    assert canon.precedence[1] == ("SAT_B", "Attr", ("T2", "T1"))
    assert canon.walks[0].climb == ("B", "C")
    assert [r.row_id for r in canon.rows] == ["SETTLED#1", "DELTA3#0"]


def test_childkey_none_and_empty_are_distinct_after_round_trip():
    loaded = parse_spec(dump_spec(_spec()))
    by_code = {s.code: s for s in loaded.satellites}
    assert by_code["SAT_CLAIM_NOTE"].childkey == ""
    assert by_code["SAT_X"].childkey is None
    assert by_code["SAT_CLAIM_BENEFIT_HEAD"].is_multi_active


@pytest.mark.parametrize("mutate", [
    lambda b: b.update(schema="other/v1"),
    lambda b: b.update(extra=1),
    lambda b: b["tables"][0].pop("stem"),
    lambda b: b["tables"][0]["columns"][0].update(kind="varchar"),
    lambda b: b["rows"][0].update(row_order="1"),
    lambda b: b["tables"][0]["columns"][0].update(is_key=1),
    lambda b: b["precedence"][0].pop(),
])
def test_parse_spec_rejects_malformed(mutate):
    body = json.loads(dump_spec(_spec()))
    mutate(body)
    with pytest.raises(ModelError):
        parse_spec(json.dumps(body))


def test_closed_sets_are_enforced():
    with pytest.raises(ModelError):
        Column("A", "date", "index", False)
    with pytest.raises(ModelError):
        Gap("standard", "T", None, "SAT_A.x", "missing parent", "", ())
    with pytest.raises(ModelError):
        SatelliteFact("SAT_A", "ratified", "HUB_A", "", "own_spec")
    with pytest.raises(ModelError):
        Table("T", "t", (Column("A", "text", "index", False),
                         Column("A", "text", "index", False)), "unknown")


@pytest.mark.parametrize("bad", ["", "/abs/x.sql", "models/../x.sql",
                                 "models\\x.sql", "models//x.sql"])
def test_artifact_path_must_be_relative_posix(bad):
    with pytest.raises(ModelError):
        Artifact("stg1", bad, "x")


def test_artifact_data_is_frozen_and_hashable():
    art = Artifact("stage", "models/staging/a.sql", "a",
                   {"cols": ["b", "a"], "meta": {"z": 1, "a": [1, 2]}})
    assert isinstance(art.data, FrozenDict)
    assert art.data["cols"] == ("b", "a")
    assert list(art.data["meta"]) == ["a", "z"]
    with pytest.raises(TypeError):
        art.data["cols"] = ()  # type: ignore[index]
    same = Artifact("stage", "models/staging/a.sql", "a",
                    {"meta": {"a": (1, 2), "z": 1}, "cols": ("b", "a")})
    assert art == same and hash(art) == hash(same)


def test_plan_sorts_every_list_and_rejects_duplicate_paths():
    a1 = Artifact("stg1", "models/staging/health/stg_health__b.sql", "b")
    a2 = Artifact("stg1", "models/staging/health/stg_health__a.sql", "a")
    a3 = Artifact("hub", "models/raw_vault/hubs/hub_claim.sql", "hub_claim")
    g1 = Gap("standard", "T2", "C", "SAT_A.x", "missing_grain_key", "d", ())
    g2 = Gap("standard", "T2", None, "SAT_A", "missing_parent", "d", ())
    g3 = Gap("augmented", "T9", "C", "SAT_A.x", "unresolved_mapping", "d", ())
    f1 = DerivedFact("hub", "HUB_CLAIM", None, "own_spec")
    f2 = DerivedFact("hub", "HUB_AGENT", None, "own_spec")
    w1 = WatermarkRisk("T2", "catalogue_no", "inputs/i.json")
    w2 = WatermarkRisk("T1", "unknown", "inputs/i.json")
    plan = Plan((a1, a2, a3), (g1, g2, g3), (f1, f2, f1), (w1, w2),
                hist_skips=(("X_HIST", "X"),), not_fed=("LNK_B", "LNK_A"))
    assert plan.artifacts == (a3, a2, a1)
    assert plan.gaps == (g3, g2, g1)
    assert plan.derived_facts == (f2, f1)
    assert plan.watermark_risks == (w2, w1)
    assert plan.not_fed == ("LNK_A", "LNK_B")
    with pytest.raises(ModelError):
        Plan((a1, a1), (), (), ())
