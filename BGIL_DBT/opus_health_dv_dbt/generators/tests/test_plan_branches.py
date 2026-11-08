"""Unit tests for dvgen.plan step 4: branches and fan-in.

Requirements 4.2, 6.6, 6.7, 8.3.
"""
from __future__ import annotations

from collections import Counter
from types import SimpleNamespace

import pytest

from dvgen.gaps import UnknownPriorKind
from dvgen.model import Column, IntermediateSpec, KeySlot, MappingRow, SatelliteFact, Table
from dvgen.plan import (
    STEPS,
    PlanContext,
    PlanError,
    parse_legs,
    plan,
    plan_branches,
    resolve_leg_value,
)


def cfg():
    return SimpleNamespace(PROJECT="p", RECORD_SOURCE_PREFIX="OPUS_",
                           RECORD_SOURCE_GROUP="OPUS",
                           WATERMARK_COLUMN="inc_job_updated_at",
                           WATERMARK_OVERRIDES={}, STG1_SOURCE="raw")


def table(name, cols):
    return Table(name, name.lower(), tuple(Column(c, "text", "untyped", False)
                                           for c in cols), "unknown")


def row(i, tbl, column, code="SAT_A", attr="Attr", instance=None, ck=None,
        unresolved=None, outcome="mapped", kind="satellite_attribute"):
    return MappingRow(f"m#{i}", i, tbl, column, outcome, kind, code, attr,
                      instance, None, ck, unresolved)


SA = SatelliteFact("SAT_A", "standard", "HUB_A", "", "own_spec")
MA = SatelliteFact("SAT_M", "standard", "HUB_A", "Item Code", "own_spec")
MA2 = SatelliteFact("SAT_M2", "standard", "HUB_A", "Ref Type + Ref Seq",
                    "own_spec")


def run(rows, tables, sats=(SA, MA, MA2), slots=()):
    """Run the planner steps up to and including plan_branches."""
    s = IntermediateSpec("p", tuple(tables), ("HUB_A",), (), tuple(sats),
                         tuple(slots), tuple(rows), (), (), ()).canonical()
    ctx = PlanContext(spec=s, cfg=cfg())
    for step in STEPS:
        step(ctx)
        if step is plan_branches:
            break
    return ctx


def gaps_by_row(ctx):
    out = {}
    for g in ctx.gaps:
        for rid in g.row_ids:
            out.setdefault(rid, []).append(g)
    return out


T = table("T", ["A", "B", "C", "MEMBER_NO", "K"])


# --------------------------------------------------------------------------
# Single-active
# --------------------------------------------------------------------------

def test_single_row_single_active_branch():
    ctx = run([row(1, "T", "A")], [T])
    (b,) = ctx.branches
    assert (b.track, b.satellite, b.table, b.key_instance, b.parent) == \
        ("standard", "SAT_A", "T", None, "HUB_A")
    assert b.multi_active is False and b.branch is None and b.childkey == ()
    (p,) = b.payload
    assert dict(p) == {"attribute": "Attr", "column": "ATTR", "expr": "a",
                       "source_columns": ("A",), "row_ids": ("m#1",)}
    assert ctx.gaps == []


def test_fallback_is_coalesce_in_row_order_with_header():
    rows = [row(5, "T", "A"), row(2, "T", "C"), row(9, "T", "B")]
    ctx = run(rows, [T])
    (b,) = ctx.branches
    (p,) = b.payload
    assert p["expr"] == ("c", "a", "b")
    assert p["source_columns"] == ("C", "A", "B")
    assert p["row_ids"] == ("m#2", "m#5", "m#9")
    note = next(n for n in b.header_notes if n.startswith("ATTR:"))
    assert "coalesce(c, a, b)" in note
    for col, rid in (("C", "m#2"), ("A", "m#5"), ("B", "m#9")):
        assert f"{col} ({rid})" in note


def test_fallback_on_one_column_is_bare():
    ctx = run([row(1, "T", "A"), row(2, "T", "A")], [T])
    (p,) = ctx.branches[0].payload
    assert p["expr"] == "a" and p["row_ids"] == ("m#1", "m#2")


def test_mixed_instances_fall_back():
    ctx = run([row(1, "T", "A", instance="x"), row(2, "T", "B")], [T])
    (p,) = ctx.branches[0].payload
    assert p["expr"] == ("a", "b")


def test_distinct_instances_on_single_active_is_a_gap():
    rows = [row(1, "T", "A", instance="email"), row(2, "T", "B", instance="fax")]
    ctx = run(rows, [T])
    assert ctx.branches == []
    by_row = gaps_by_row(ctx)
    for rid, col in (("m#1", "A"), ("m#2", "B")):
        (g,) = by_row[rid]
        assert g.reason == "unresolved_mapping"
        assert g.source_column == col and g.target == "SAT_A.Attr"
        assert "single-active" in g.detail


# --------------------------------------------------------------------------
# Multi-active
# --------------------------------------------------------------------------

def test_coexisting_values_get_one_branch_each():
    rows = [row(i, "T", c, code="SAT_M", attr="Amount", instance=inst)
            for i, (c, inst) in enumerate([("A", "Room Rent"), ("B", "ICU"),
                                           ("C", "Room Rent Extra")], 1)]
    ctx = run(rows, [T])
    assert len(ctx.branches) == 3
    lits = {b.childkey[0]["literal"] for b in ctx.branches}
    assert lits == {"Room Rent", "ICU", "Room Rent Extra"}
    for b in ctx.branches:
        assert b.multi_active and b.childkey[0]["column"] == "ITEMCODE"
        assert len(b.payload) == 1 and isinstance(b.payload[0]["expr"], str)
    names = [b.branch for b in ctx.branches]
    assert len(set(names)) == 3 and "room_rent" in names
    assert ctx.gaps == []


def test_attributes_with_the_same_child_key_share_a_branch():
    rows = [row(1, "T", "A", code="SAT_M", attr="Amount", ck="Item Code = DISC"),
            row(2, "T", "B", code="SAT_M", attr="Rate", ck="Item Code = DISC"),
            row(3, "T", "C", code="SAT_M", attr="Amount", ck="Item Code = LOAD")]
    ctx = run(rows, [T])
    assert len(ctx.branches) == 2
    disc = next(b for b in ctx.branches if b.childkey[0]["literal"] == "DISC")
    assert [p["column"] for p in disc.payload] == ["AMOUNT", "RATE"]
    assert disc.row_ids == ("m#1", "m#2")


def test_instance_wins_over_leg_and_data_driven_leg():
    rows = [row(1, "T", "A", code="SAT_M", attr="Amount", instance="Lit",
                ck="Item Code = OTHER"),
            row(2, "T", "B", code="SAT_M", attr="Rate", ck="{MEMBER_NO}")]
    ctx = run(rows, [T])
    cks = sorted(tuple(sorted(b.childkey[0].items())) for b in ctx.branches)
    assert cks == [(("column", "ITEMCODE"), ("expr", "member_no")),
                   (("column", "ITEMCODE"), ("literal", "Lit"))]


def test_multi_part_child_key_in_part_order():
    rows = [row(1, "T", "A", code="SAT_M2", attr="Value",
                ck="Ref Seq = {K} | Ref Type = 'PAN'")]
    ctx = run(rows, [T])
    (b,) = ctx.branches
    assert [dict(c) for c in b.childkey] == [
        {"column": "REFTYPE", "literal": "PAN"},
        {"column": "REFSEQ", "expr": "k"}]


@pytest.mark.parametrize("ck", [None, "{spine:X.Y}", "{NOT_A_COL}",
                                "Wrong Part = X", ""])
def test_unresolved_leg_is_a_gap(ck):
    ctx = run([row(1, "T", "A", code="SAT_M", attr="Amount", ck=ck)], [T])
    assert ctx.branches == []
    (g,) = gaps_by_row(ctx)["m#1"]
    assert g.reason == "unresolved_mapping" and g.target == "SAT_M.Amount"


def test_multi_part_missing_leg_is_a_gap():
    ctx = run([row(1, "T", "A", code="SAT_M2", attr="V", ck="Ref Type = X")],
              [T])
    (g,) = gaps_by_row(ctx)["m#1"]
    assert "Ref Seq" in g.detail


def test_parse_and_resolve_helpers():
    assert parse_legs("a = {x || y} | B = 'q|r'", ["A", "b"]) == (
        {"A": "{x || y}", "b": "'q|r'"}, "")
    assert parse_legs("email", ["Contact Type"]) == ({"Contact Type": "email"}, "")
    assert resolve_leg_value("{nullif(trim(K),'')}", ["K"]) == (
        ("expr", "nullif(trim(k),'')"), "")
    assert resolve_leg_value("{a[x]}", ["A"])[0] is None
    assert resolve_leg_value("'it''s'", []) == (("literal", "it's"), "")


# --------------------------------------------------------------------------
# Collisions and row-level gaps
# --------------------------------------------------------------------------

def test_payload_collision_stops_the_build_naming_both():
    rows = [row(1, "T", "A", attr="Note Text"), row(2, "T", "B", attr="Note-Text")]
    with pytest.raises(PlanError) as err:
        run(rows, [T])
    assert "'Note Text'" in str(err.value) and "'Note-Text'" in str(err.value)


def test_case_and_spacing_variants_are_one_attribute():
    ctx = run([row(1, "T", "A", attr="Note Text"),
               row(2, "T", "B", attr="note  text")], [T])
    assert ctx.branches[0].payload[0]["expr"] == ("a", "b")


def test_childkey_collision_stops_the_build():
    rows = [row(1, "T", "A", code="SAT_M", attr="Item-Code", instance="x")]
    with pytest.raises(PlanError, match="Item Code.*Item-Code"):
        run(rows, [T])


def test_attribute_that_is_a_child_key_part_is_a_gap():
    ctx = run([row(1, "T", "A", code="SAT_M", attr="item code", instance="x")],
              [T])
    (g,) = gaps_by_row(ctx)["m#1"]
    assert g.reason == "unresolved_mapping" and "child-key part" in g.detail


def test_spec_unresolved_rows():
    rows = [row(1, "T", "A", unresolved="satellite_home_is_pure_prose"),
            row(2, "T", "B", attr="Other",
                unresolved="loader_has_no_feed_in_the_map")]
    ctx = run(rows, [T])
    (g,) = gaps_by_row(ctx)["m#1"]
    assert g.reason == "unresolved_mapping"
    assert g.detail.startswith("satellite_home_is_pure_prose")
    assert [b.row_ids for b in ctx.branches] == [("m#2",)]
    with pytest.raises(UnknownPriorKind):
        run([row(1, "T", "A", unresolved="never_heard_of_it")], [T])


def test_unknown_satellite_and_augmented_home_fallback():
    rows = [row(1, "T", "A", code="SAT_NONE"),
            row(2, "T", "B", outcome="augmentation_needed", kind="augmentation")]
    ctx = run(rows, [T])
    (g,) = gaps_by_row(ctx)["m#1"]
    assert g.reason == "missing_parent"
    (b,) = ctx.branches
    assert b.track == "augmented" and b.parent == "HUB_A"


def test_key_instance_groups_separately():
    slot = KeySlot("T", "HUB_A", "insured", "K", ("K",), "spec.key_slot")
    rows = [row(1, "T", "A", instance="insured"), row(2, "T", "B")]
    ctx = run(rows, [T], slots=[slot])
    assert [(b.key_instance, b.branch, b.row_ids) for b in ctx.branches] == [
        (None, None, ("m#2",)), ("insured", "insured", ("m#1",))]


# --------------------------------------------------------------------------
# Coverage and determinism
# --------------------------------------------------------------------------

def test_every_row_ends_in_one_branch_or_one_gap_and_order_is_stable():
    rows = [row(1, "T", "A"), row(2, "T", "B"),
            row(3, "T", "A", attr="X", instance="e"),
            row(4, "T", "B", attr="X", instance="f"),
            row(5, "T", "A", code="SAT_M", attr="Amount", instance="p"),
            row(6, "T", "B", code="SAT_M", attr="Amount", instance="q"),
            row(7, "T", "C", code="SAT_M", attr="Amount"),
            row(8, "T", "C", code="SAT_GONE"),
            row(9, "U", "Z")]
    tables = [T, table("U", ["Z"])]
    ctx = run(rows, tables)
    counts = Counter()
    for b in ctx.branches:
        counts.update(b.row_ids)
    for g in ctx.gaps:
        counts.update(g.row_ids)
    assert counts == Counter({r.row_id: 1 for r in rows})
    again = run(rows[::-1], tables[::-1])
    assert again.branches == ctx.branches
    assert plan(again.spec, cfg()) == plan(ctx.spec, cfg())
