"""Unit tests for dvgen.gaps (Requirements 8.2, 8.3)."""
from __future__ import annotations

import json

import pytest

from dvgen.emit import WriteGuard
from dvgen.gaps import (
    GAPS_REL,
    GAPS_SCHEMA,
    PRIOR_KIND_REASONS,
    SITUATION_REASONS,
    GapError,
    UnknownPriorKind,
    classify,
    dump_gaps,
    gap_from_prior,
    load_gaps,
    parse_gaps,
    reason_for_prior_kind,
    write_gaps,
)
from dvgen.model import GAP_REASONS, Gap, ModelError, WatermarkRisk


def _gap(track="standard", table="T", column="C", target="SAT_X.A",
         reason="missing_grain_key", detail="d", row_ids=("r#1",)):
    return Gap(track=track, source_table=table, source_column=column,
               target=target, reason=reason, detail=detail,
               row_ids=tuple(row_ids))


# -- classification ----------------------------------------------------------

def test_reason_set_is_imported_from_model():
    for table in (SITUATION_REASONS, PRIOR_KIND_REASONS):
        assert {r for r in table.values() if r is not None} <= set(GAP_REASONS)
    # Every reason is reachable from some planner situation.
    assert set(SITUATION_REASONS.values()) == set(GAP_REASONS)


@pytest.mark.parametrize("kind,reason", [
    # hcon_spec.json unresolved[].kind
    ("anchor_not_keyed_on_this_view_in_legacy_sql", "missing_grain_key"),
    ("legacy_key_not_recoverable", "missing_grain_key"),
    ("view_has_no_recoverable_key_at_all", "missing_grain_key"),
    ("satellite_has_no_anchor", "missing_parent"),
    ("multiple_registries_key_this_view_hub", "unresolved_mapping"),
    ("child_key_leg_refused", "unresolved_mapping"),
    ("payload_collides_with_child_key_leg", "unresolved_mapping"),
    ("satellite_home_is_pure_prose", "unresolved_mapping"),
    ("loader_has_no_feed_in_the_map", None),
    # mxh3_spec.json unresolved[].kind and row-level refusals
    ("anchor_has_no_declared_expression_on_this_view", "missing_grain_key"),
    ("spine_display_rung_with_no_declared_walk", "missing_grain_key"),
    ("anchor_does_not_resolve_uniquely", "unresolved_mapping"),
    ("child_key_leg_does_not_resolve_on_its_own_view", "unresolved_mapping"),
    ("s54_payload_attribute_is_also_a_child_key_leg", "unresolved_mapping"),
    ("refuse_row", "unresolved_mapping"),
    ("do_not_build", "unresolved_mapping"),
])
def test_prior_kind_reasons(kind, reason):
    assert reason_for_prior_kind(kind) == reason


@pytest.mark.parametrize("kind", ["", "something_new", None, "MISSING_PARENT"])
def test_unknown_prior_kind_raises(kind):
    with pytest.raises(UnknownPriorKind):
        reason_for_prior_kind(kind)


def test_classify_situations_and_unknown():
    assert classify("parent_empty") == "missing_parent"
    assert classify("childkey_field_absent") == "missing_childkey_field"
    assert classify("no_grain_key") == "missing_grain_key"
    assert classify("augmentation_no_key_slot") == \
        "no_verified_augmentation_key"
    assert classify("distinct_values_single_active") == "unresolved_mapping"
    with pytest.raises(GapError):
        classify("not_a_situation")


def test_gap_from_prior():
    g = gap_from_prior("legacy_key_not_recoverable", track="standard",
                       source_table="T", source_column=None,
                       target="SAT_X", detail="no NK", row_ids=["a#1"])
    assert g.reason == "missing_grain_key"
    assert g.detail == "legacy_key_not_recoverable: no NK"
    assert g.row_ids == ("a#1",)
    assert gap_from_prior("loader_has_no_feed_in_the_map", track="standard",
                          source_table="T", source_column=None,
                          target="LNK_X", detail="") is None
    with pytest.raises(UnknownPriorKind):
        gap_from_prior("bogus", track="standard", source_table="T",
                       source_column=None, target="X", detail="")


# -- gap file ----------------------------------------------------------------

def test_dump_sorts_and_has_schema():
    gaps = [
        _gap(track="standard", table="B"),
        _gap(track="augmented", table="Z", reason="missing_parent"),
        _gap(track="standard", table="A", column=None),
        _gap(track="standard", table="A", column="C", reason="missing_parent"),
        _gap(track="standard", table="A", column="C",
             reason="missing_grain_key"),
    ]
    risks = [WatermarkRisk("T2", "unknown", "x"),
             WatermarkRisk("T1", "catalogue_no", "y")]
    body = json.loads(dump_gaps("proj", gaps, risks))
    assert body["schema"] == GAPS_SCHEMA == "health_gaps/v1"
    assert body["project"] == "proj"
    assert body["reasons"] == list(GAP_REASONS)
    order = [(g["track"], g["source_table"], g["source_column"], g["reason"])
             for g in body["gaps"]]
    assert order == [
        ("augmented", "Z", "C", "missing_parent"),
        ("standard", "A", None, "missing_grain_key"),
        ("standard", "A", "C", "missing_grain_key"),
        ("standard", "A", "C", "missing_parent"),
        ("standard", "B", "C", "missing_grain_key"),
    ]
    assert [r["table"] for r in body["watermark_risks"]] == ["T1", "T2"]


def test_dump_is_order_independent_and_round_trips():
    gaps = [_gap(table=t) for t in ("C", "A", "B")]
    risks = [WatermarkRisk("T1", "catalogue_no", "inputs/x.json")]
    a = dump_gaps("proj", gaps, risks)
    b = dump_gaps("proj", list(reversed(gaps)), risks)
    assert a == b and a.endswith("}\n") and "\r" not in a
    parsed = parse_gaps(a)
    assert parsed.project == "proj"
    assert parsed.gaps == tuple(sorted(gaps, key=Gap.sort_key))
    assert parsed.watermark_risks == tuple(risks)
    assert dump_gaps(parsed.project, parsed.gaps, parsed.watermark_risks) == a


def test_write_and_load_through_guard(tmp_path):
    guard = WriteGuard(tmp_path)
    gaps = [_gap()]
    sha = write_gaps(guard, "proj", gaps)
    assert guard.written[GAPS_REL] == sha
    loaded = load_gaps(tmp_path / GAPS_REL)
    assert loaded.gaps == tuple(gaps) and loaded.watermark_risks == ()


@pytest.mark.parametrize("mutate", [
    lambda b: b.update(schema="health_gaps/v0"),
    lambda b: b.update(reasons=b["reasons"][:-1]),
    lambda b: b.pop("watermark_risks"),
    lambda b: b.update(extra=1),
    lambda b: b["gaps"][0].update(reason="made_up"),
    lambda b: b.update(project=""),
])
def test_parse_rejects_bad_files(mutate):
    body = json.loads(dump_gaps("proj", [_gap()]))
    mutate(body)
    # GapError subclasses ModelError; a bad Gap record raises ModelError.
    with pytest.raises(ModelError):
        parse_gaps(json.dumps(body))


def test_parse_rejects_non_json():
    with pytest.raises(GapError):
        parse_gaps("not json")
