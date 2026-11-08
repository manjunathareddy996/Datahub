"""Unit tests for dvgen.plan steps 6 to 9: stitch or union, macro choice,
references, augmented track, hub and link models, not-fed objects.

Requirements 4.2, 6.1, 6.3, 6.4, 6.5, 6.10, 7.1, 7.2, 7.3, 10.2.
"""
from __future__ import annotations

import random
from types import SimpleNamespace

import pytest

from dvgen import naming
from dvgen.model import (
    Column,
    IntermediateSpec,
    KeySlot,
    MappingRow,
    SatelliteFact,
    Table,
)
from dvgen.plan import plan
from dvgen.render_stage import render as render_stage
from dvgen.render_stg1 import render_stg1
from dvgen.render_ref import render_ref
from dvgen.render_stitch import render_stitch, render_stitch_stage
from dvgen.render_vault import render_vault


def cfg(**extra):
    return SimpleNamespace(PROJECT="p", RECORD_SOURCE_PREFIX="OPUS_",
                           RECORD_SOURCE_GROUP="OPUS",
                           WATERMARK_COLUMN="inc_job_updated_at",
                           WATERMARK_OVERRIDES={}, STG1_SOURCE="raw", **extra)


def table(name, cols):
    return Table(name, name.lower(), tuple(Column(c, "text", "untyped", False)
                                           for c in cols), "unknown")


_n = [0]


def row(tbl, column, code, attr, instance=None, kind="satellite_attribute",
        outcome="mapped"):
    _n[0] += 1
    return MappingRow(f"m#{_n[0]}", _n[0], tbl, column, outcome, kind, code,
                      attr, instance, None, None, None)


def slot(tbl, code, cols, instance=None):
    return KeySlot(tbl, code, instance, "", tuple(cols), "spec.key_slot")


def sat(code, parent, childkey="", track="standard"):
    return SatelliteFact(code, track, parent, childkey, "own_spec")


def build(rows, tables, slots, sats, hubs=("HUB_CLAIM", "HUB_PARTY"),
          links=("LNK_CLAIM_PARTY",), precedence=()):
    return IntermediateSpec("p", tuple(tables), tuple(hubs), tuple(links),
                            tuple(sats), tuple(slots), tuple(rows),
                            tuple(precedence), (), ())


def by_kind(result, kind):
    return {a.name: a for a in result.artifacts if a.kind == kind}


def claim_spec(precedence=(), b_key="CLAIM_ID"):
    ta = table("CLAIM_A", ["CLAIM_ID", "AMT", "NOTE"])
    tb = table("CLAIM_B", ["CLAIM_ID", "CLAIM_NO", "AMT2"])
    rows = [row("CLAIM_A", "AMT", "SAT_CLAIM_DETAIL", "Amount"),
            row("CLAIM_A", "NOTE", "SAT_CLAIM_DETAIL", "Note"),
            row("CLAIM_B", "AMT2", "SAT_CLAIM_DETAIL", "Amount")]
    slots = [slot("CLAIM_A", "HUB_CLAIM", ["CLAIM_ID"]),
             slot("CLAIM_B", "HUB_CLAIM", [b_key])]
    return build(rows, [ta, tb], slots,
                 [sat("SAT_CLAIM_DETAIL", "HUB_CLAIM")],
                 hubs=("HUB_CLAIM",), links=(), precedence=precedence)


# --------------------------------------------------------------------------
# Macro choice and maps
# --------------------------------------------------------------------------

def test_one_stage_uses_sat():
    ta = table("CLAIM_A", ["CLAIM_ID", "AMT"])
    spec = build([row("CLAIM_A", "AMT", "SAT_X", "Amount")], [ta],
                 [slot("CLAIM_A", "HUB_CLAIM", ["CLAIM_ID"])],
                 [sat("SAT_X", "HUB_CLAIM")], hubs=("HUB_CLAIM",), links=())
    result = plan(spec, cfg())
    (s,) = by_kind(result, "sat").values()
    assert s.name == "sat_x"
    assert s.path == "models/raw_vault/standard/satellites/sat_x.sql"
    assert s.data["macro"] == "sat"
    assert s.data["source_model"] == "stg2_sat_claim_a__x"
    assert s.data["src_pk"] == "CLAIM_HKEY"
    assert s.data["src_payload"] == ("AMOUNT",)
    assert "src_column_map" not in s.data
    stage = by_kind(result, "stage_sat")["stg2_sat_claim_a__x"]
    assert stage.path == "models/raw_vault/standard/staging/stg2_sat_claim_a__x.sql"
    assert stage.data["parent_bk"] == "claim_id"
    assert stage.data["record_source"] == "!OPUS_CLAIM_A"


def test_two_stages_use_sat_multi_source_with_maps():
    result = plan(claim_spec(), cfg())
    (s,) = by_kind(result, "sat").values()
    assert s.data["macro"] == "sat_multi_source"
    names = sorted(s.data["source_model"])
    assert names == ["stg2_sat_claim_a__claim_detail",
                     "stg2_sat_claim_b__claim_detail"]
    assert {k: tuple(v) for k, v in s.data["src_column_map"].items()} == {
        "stg2_sat_claim_a__claim_detail": ("AMOUNT", "NOTE"),
        "stg2_sat_claim_b__claim_detail": ("AMOUNT",)}
    assert dict(s.data["src_record_source_map"]) == {n: "OPUS" for n in names}
    assert s.data["src_payload"] == ("AMOUNT", "NOTE")
    assert not by_kind(result, "stitch")


def _multi_active_spec(two_branches):
    tp = table("PARTY_T", ["PARTY_ID", "PHONE", "EMAIL"])
    rows = [row("PARTY_T", "PHONE", "SAT_CONTACT", "Contact Value", "Phone")]
    if two_branches:
        rows.append(row("PARTY_T", "EMAIL", "SAT_CONTACT", "Contact Value",
                        "Email"))
    return build(rows, [tp], [slot("PARTY_T", "HUB_PARTY", ["PARTY_ID"])],
                 [sat("SAT_CONTACT", "HUB_PARTY", "Contact Type")],
                 hubs=("HUB_PARTY",), links=())


def test_single_stage_multi_active_uses_ma_sat():
    result = plan(_multi_active_spec(False), cfg())
    (s,) = by_kind(result, "sat").values()
    assert s.data["macro"] == "ma_sat"
    assert s.data["src_cdk"] == ("CONTACTTYPE",)
    assert isinstance(s.data["source_model"], str)


def test_multi_active_two_stages_use_ma_sat_multi_source():
    result = plan(_multi_active_spec(True), cfg())
    (s,) = by_kind(result, "sat").values()
    assert s.data["macro"] == "ma_sat_multi_source"
    assert s.data["src_cdk"] == ("CONTACTTYPE",)
    assert len(s.data["source_model"]) == 2
    assert set(s.data["src_record_source_map"].values()) == {"OPUS"}


# --------------------------------------------------------------------------
# Stitch
# --------------------------------------------------------------------------

PREC = (("SAT_CLAIM_DETAIL", "Amount", ("CLAIM_B", "CLAIM_A")),)


def test_stitch_planned_with_precedence_and_same_key():
    result = plan(claim_spec(PREC), cfg())
    stitch = by_kind(result, "stitch")["stitch_claim_detail"]
    assert stitch.path == "models/raw_vault/standard/stitched/stitch_claim_detail.sql"
    d = stitch.data
    assert d["target_sat"] == "sat_claim_detail"
    assert [s["model"] for s in d["sources"]] == ["stg_health__claim_a",
                                                  "stg_health__claim_b"]
    assert [s["key_column"] for s in d["sources"]] == ["claim_id", "claim_id"]
    assert list(d["coalesce_rules"]["amount"]) == ["stg_health__claim_b",
                                                   "stg_health__claim_a"]
    assert list(d["coalesce_rules"]["note"]) == ["stg_health__claim_a"]
    stage = by_kind(result, "stitch_stage")["stg2_sat_stitch__claim_detail"]
    assert stage.data["source_model"] == "stitch_claim_detail"
    (s,) = by_kind(result, "sat").values()
    assert s.data["macro"] == "sat"
    assert s.data["source_model"] == "stg2_sat_stitch__claim_detail"
    assert tuple(s.data["src_extra_columns"]) == ("DBT_RUN_TS",)
    assert not by_kind(result, "stage_sat")


def test_no_stitch_without_precedence():
    assert not by_kind(plan(claim_spec(), cfg()), "stitch")


def test_no_stitch_when_key_expressions_differ_and_reason_in_header():
    result = plan(claim_spec(PREC, b_key="CLAIM_NO"), cfg())
    assert not by_kind(result, "stitch")
    (s,) = by_kind(result, "sat").values()
    assert s.data["macro"] == "sat_multi_source"
    assert any(h.startswith("stitch not used") and "key expression" in h
               for h in s.data["header"])
    assert len(by_kind(result, "stage_sat")) == 2


# --------------------------------------------------------------------------
# References, augmented track, hubs, links, not fed
# --------------------------------------------------------------------------

def full_spec():
    claim_a = table("CLAIM_A", ["CLAIM_ID", "AMT", "NOTE"])
    claim_b = table("CLAIM_B", ["CLAIM_ID", "CLAIM_NO", "AMT2"])
    party = table("PARTY_T", ["PARTY_ID", "CLAIM_ID", "ROLE", "PHONE", "EMAIL"])
    bank = table("BANK", ["IFSC_CODE", "MICR_CODE"])
    rows = [
        row("CLAIM_A", "AMT", "SAT_CLAIM_DETAIL", "Amount"),
        row("CLAIM_A", "NOTE", "SAT_CLAIM_DETAIL", "Note"),
        row("CLAIM_B", "AMT2", "SAT_CLAIM_DETAIL", "Amount"),
        row("CLAIM_A", "NOTE", "SAT_CLAIM_DETAIL", "Extra Note",
            kind="augmentation", outcome="augmentation_needed"),
        row("PARTY_T", "ROLE", "SAT_CLAIM_PARTY_ROLE", "Role"),
        row("PARTY_T", "PHONE", "SAT_CONTACT", "Contact Value", "Phone"),
        row("PARTY_T", "EMAIL", "SAT_CONTACT", "Contact Value", "Email"),
        row("BANK", "IFSC_CODE", "REF_BANK", "IFSC Code"),
        row("BANK", "MICR_CODE", "REF_BANK", "MICR Code"),
    ]
    slots = [slot("CLAIM_A", "HUB_CLAIM", ["CLAIM_ID"]),
             slot("CLAIM_B", "HUB_CLAIM", ["CLAIM_ID"]),
             slot("PARTY_T", "HUB_CLAIM", ["CLAIM_ID"]),
             slot("PARTY_T", "HUB_PARTY", ["PARTY_ID"])]
    sats = [sat("SAT_CLAIM_DETAIL", "HUB_CLAIM"),
            sat("SAT_CLAIM_DETAIL", "HUB_CLAIM", track="augmented"),
            sat("SAT_CLAIM_PARTY_ROLE", "LNK_CLAIM_PARTY"),
            sat("SAT_CONTACT", "HUB_PARTY", "Contact Type"),
            sat("REF_BANK", "HUB_BANK", track="reference"),
            sat("SAT_UNFED", "HUB_CLAIM")]
    return build(rows, [claim_a, claim_b, party, bank], slots, sats,
                 hubs=("HUB_CLAIM", "HUB_PARTY", "HUB_UNFED"),
                 links=("LNK_CLAIM_PARTY", "LNK_UNFED"),
                 precedence=PREC)


def test_reference_satellite_becomes_ref_view():
    result = plan(full_spec(), cfg())
    ref = by_kind(result, "ref")["ref_bank"]
    assert ref.path == "models/raw_vault/standard/references/ref_bank.sql"
    (src,) = ref.data["sources"]
    assert src["source_model"] == "stg_health__bank"
    assert [c["column"] for c in src["columns"]] == ["IFSCCODE", "MICRCODE"]
    assert "ref_bank" not in by_kind(result, "sat")


def test_augmented_track_naming_and_folders():
    result = plan(full_spec(), cfg())
    aug = by_kind(result, "sat")["sat_aug_claim_detail"]
    assert aug.path == "models/raw_vault/augmented/satellites/sat_aug_claim_detail.sql"
    assert aug.data["macro"] == "sat"
    stage = by_kind(result, "stage_aug")["stg2_aug_claim_a__claim_detail"]
    assert stage.path == ("models/raw_vault/augmented/staging/"
                          "stg2_aug_claim_a__claim_detail.sql")
    assert "sat_claim_detail" in by_kind(result, "sat")


def test_augmented_row_without_key_is_one_gap_and_no_artifact():
    ta = table("CLAIM_A", ["CLAIM_ID", "NOTE"])
    spec = build([row("CLAIM_A", "NOTE", "SAT_X", "Note",
                      kind="augmentation", outcome="augmentation_needed")],
                 [ta], [], [sat("SAT_X", "HUB_CLAIM", track="augmented")],
                 hubs=("HUB_CLAIM",), links=())
    result = plan(spec, cfg())
    assert [g.reason for g in result.gaps] == ["no_verified_augmentation_key"]
    assert not by_kind(result, "sat") and not by_kind(result, "stage_aug")


def test_hub_source_models_cover_all_stage_hubs():
    result = plan(full_spec(), cfg())
    hub_stage = {a.name for a in result.artifacts if a.kind == "stage_hub"
                 and a.data["target"] == "HUB_CLAIM"}
    hub = by_kind(result, "hub")["hub_claim"]
    assert hub.path == "models/raw_vault/standard/hubs/hub_claim.sql"
    assert set(hub.data["source_model"]) == hub_stage
    assert {"stg2_hub_claim_a__claim", "stg2_hub_claim_b__claim",
            "stg2_hub_party_t__claim"} <= hub_stage
    assert set(by_kind(result, "hub")) == {"hub_claim", "hub_party"}


def test_link_stage_link_and_src_fk_order():
    template = {"LNK_CLAIM_PARTY": ("HUB_PARTY", "HUB_CLAIM")}
    result = plan(full_spec(), cfg(TEMPLATE_LINK_HUB_ORDER=template))
    stage = by_kind(result, "stage_link")["stg2_link_party_t__claim_party"]
    assert [k["code"] for k in stage.data["hub_keys"]] == ["HUB_PARTY",
                                                           "HUB_CLAIM"]
    link = by_kind(result, "link")["lnk_claim_party"]
    assert link.path == "models/raw_vault/standard/links/lnk_claim_party.sql"
    assert tuple(link.data["src_fk"]) == ("PARTY_HKEY", "CLAIM_HKEY")
    assert tuple(link.data["source_model"]) == ("stg2_link_party_t__claim_party",)
    sat_link = by_kind(result, "sat")["sat_claim_party_role"]
    assert sat_link.data["src_pk"] == "CLAIM_PARTY_HKEY"


def test_not_fed_lists_unfed_objects():
    result = plan(full_spec(), cfg())
    assert result.not_fed == ("HUB_UNFED", "LNK_UNFED", "SAT_UNFED")


# --------------------------------------------------------------------------
# Rendering and determinism
# --------------------------------------------------------------------------

def _render(a):
    if a.kind == "stg1":
        return render_stg1(a)
    if a.kind in ("hub", "link", "sat"):
        return render_vault(a)
    if a.kind == "stitch":
        return render_stitch(a)
    if a.kind == "stitch_stage":
        return render_stitch_stage(a)
    if a.kind == "ref":
        return render_ref(a)
    return render_stage(a)


@pytest.mark.parametrize("precedence", [(), PREC])
def test_every_artifact_renders(precedence):
    spec = full_spec()
    spec = IntermediateSpec(**{**spec.__dict__, "precedence": precedence})
    result = plan(spec, cfg())
    kinds = {a.kind for a in result.artifacts}
    assert {"stg1", "stage_hub", "stage_sat", "stage_aug", "stage_link", "sat",
            "hub", "link", "ref"} <= kinds
    for a in result.artifacts:
        text = _render(a)
        assert text.endswith("\n"), a.path


def test_output_lists_sorted_by_kind_and_path():
    result = plan(full_spec(), cfg())
    keys = [(a.kind, a.path) for a in result.artifacts]
    assert keys == sorted(keys)


def test_shuffled_input_gives_equal_plan():
    spec = full_spec()
    shuffled = IntermediateSpec(
        spec.project,
        tuple(random.Random(1).sample(spec.tables, len(spec.tables))),
        tuple(reversed(spec.hubs)), tuple(reversed(spec.links)),
        tuple(random.Random(2).sample(spec.satellites, len(spec.satellites))),
        tuple(random.Random(3).sample(spec.key_slots, len(spec.key_slots))),
        tuple(random.Random(4).sample(spec.rows, len(spec.rows))),
        spec.precedence, spec.walks, spec.input_digests)
    assert plan(shuffled, cfg()) == plan(spec, cfg())
