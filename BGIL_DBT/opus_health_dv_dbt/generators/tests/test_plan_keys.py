"""Unit tests for dvgen.plan step 5: grain keys, bridges and hub feeds.

Requirements 4.5, 6.8, 6.9, 9.6.
"""
from __future__ import annotations

from types import SimpleNamespace

from dvgen.model import (
    Artifact,
    Column,
    IntermediateSpec,
    KeySlot,
    MappingRow,
    SatelliteFact,
    Table,
    Walk,
)
from dvgen.plan import PlanContext, STEPS, link_hubs, plan
from dvgen.render_stage import render


def cfg(**extra):
    return SimpleNamespace(PROJECT="p", RECORD_SOURCE_PREFIX="OPUS_",
                           RECORD_SOURCE_GROUP="OPUS",
                           WATERMARK_COLUMN="inc_job_updated_at",
                           WATERMARK_OVERRIDES={}, STG1_SOURCE="raw", **extra)


def table(name, cols):
    return Table(name, name.lower(), tuple(Column(c, "text", "untyped", False)
                                           for c in cols), "unknown")


def row(i, tbl, column="X", code="SAT_A", attr="Attr", instance=None,
        outcome="mapped", kind="satellite_attribute"):
    return MappingRow(f"m#{i}", i, tbl, column, outcome, kind, code, attr,
                      instance, None, None, None)


def slot(tbl, code, cols, instance=None, expr=""):
    return KeySlot(tbl, code, instance, expr, tuple(cols), "spec.key_slot")


SA = SatelliteFact("SAT_A", "standard", "HUB_A", "", "own_spec")
SL = SatelliteFact("SAT_L", "standard", "LNK_A_G", "", "own_spec")
SAUG = SatelliteFact("SAT_A", "augmented", "HUB_A", "", "own_spec")


def spec(rows, tables, slots, sats=(SA,), links=(), walks=()):
    return IntermediateSpec("p", tuple(tables), ("HUB_A", "HUB_G"), tuple(links),
                            tuple(sats), tuple(slots), tuple(rows), (),
                            tuple(walks), ()).canonical()


def run(*args, config=None, **kwargs):
    ctx = PlanContext(spec=spec(*args, **kwargs), cfg=config or cfg())
    for step in STEPS:
        step(ctx)
    return ctx


def arts(ctx, kind):
    return {a.name: a for a in ctx.artifacts if a.kind == kind}


T = table("T", ["X", "A_ID", "G_ID"])


# --------------------------------------------------------------------------
# Direct keys and hub stages
# --------------------------------------------------------------------------

def test_direct_key_gets_hub_stage_with_same_parent_bk():
    ctx = run([row(1, "T")], [T], [slot("T", "HUB_A", ["A_ID"])])
    (b,) = ctx.branches
    res = ctx.key_resolutions[b.sort_key()]
    assert (res.source_model, res.bridge, res.parent_bk, res.hub_keys) == \
        ("stg_health__t", None, "a_id", ())
    hub = arts(ctx, "stage_hub")["stg2_hub_t__a"]
    assert hub.path == "models/raw_vault/standard/staging/stg2_hub_t__a.sql"
    d = hub.data
    assert (d["target"], d["parent_code"], d["source_model"], d["table"]) == \
        ("HUB_A", "HUB_A", "stg_health__t", "T")
    assert d["parent_bk"] == res.parent_bk
    assert d["record_source"] == "!OPUS_T"
    assert d["load_datetime"] == "inc_job_updated_at"
    assert ctx.gaps == [] and ctx.gapped_rows == set()
    render(hub)


def test_two_satellites_share_one_hub_stage():
    sats = (SA, SatelliteFact("SAT_B", "standard", "HUB_A", "", "own_spec"))
    ctx = run([row(1, "T"), row(2, "T", code="SAT_B")], [T],
              [slot("T", "HUB_A", ["A_ID"])], sats=sats)
    assert len(arts(ctx, "stage_hub")) == 1
    assert len(ctx.key_resolutions) == 2


def test_instance_key_names_hub_stage_with_suffix():
    ctx = run([row(1, "T", instance="Insured")], [T],
              [slot("T", "HUB_A", ["A_ID"], "Insured")])
    assert list(arts(ctx, "stage_hub")) == ["stg2_hub_t__a__insured"]


def test_composite_key_uses_raw_key_expression():
    ctx = run([row(1, "T")], [T], [slot("T", "HUB_A", ["A_ID", "G_ID"])])
    (res,) = ctx.key_resolutions.values()
    assert res.parent_bk.startswith("case when coalesce(a_id, g_id) is null")


# --------------------------------------------------------------------------
# Bridges (key-slot graph)
# --------------------------------------------------------------------------

B = table("B", ["A_ID", "G_ID"])
TG = table("T", ["X", "G_ID"])


def test_bridge_is_planned_and_stage_reads_it():
    ctx = run([row(1, "T")], [TG, B],
              [slot("T", "HUB_G", ["G_ID"]), slot("B", "HUB_A", ["A_ID"]),
               slot("B", "HUB_G", ["G_ID"])])
    (res,) = ctx.key_resolutions.values()
    assert (res.source_model, res.bridge, res.parent_bk) == \
        ("bridge_t__a", "bridge_t__a", "bridge_a_id")
    bridge = arts(ctx, "bridge")["bridge_t__a"]
    assert bridge.path == "models/raw_vault/standard/staging/bridge_t__a.sql"
    d = bridge.data
    assert (d["hub"], d["table"], d["source_model"]) == \
        ("HUB_A", "T", "stg_health__t")
    assert [dict(j["on"][0]) for j in d["joins"]] == \
        [{"left": "t.g_id", "right": "b1.g_id"}]
    assert d["joins"][0]["model"] == "stg_health__b"
    assert [dict(c) for c in d["columns"]] == \
        [{"column": "bridge_a_id", "expr": "b1.a_id"}]
    hub = arts(ctx, "stage_hub")["stg2_hub_t__a"]
    assert (hub.data["source_model"], hub.data["parent_bk"]) == \
        ("bridge_t__a", "bridge_a_id")
    render(bridge)
    render(hub)


def test_bridge_alias_does_not_clash_with_table_columns():
    t = table("T", ["X", "G_ID", "BRIDGE_A_ID"])
    ctx = run([row(1, "T")], [t, B],
              [slot("T", "HUB_G", ["G_ID"]), slot("B", "HUB_A", ["A_ID"]),
               slot("B", "HUB_G", ["G_ID"])])
    (res,) = ctx.key_resolutions.values()
    assert res.parent_bk == "bridge_a_id_b"
    assert arts(ctx, "bridge")["bridge_t__a"].data["columns"][0]["column"] \
        == "bridge_a_id_b"


def test_candidate_feeding_a_link_wins_over_lexical_order():
    b1, b2 = table("B1", ["A_ID", "G_ID"]), table("B2", ["A_ID", "G_ID"])
    slots = [slot("T", "HUB_G", ["G_ID"]),
             slot("B1", "HUB_A", ["A_ID"]), slot("B1", "HUB_G", ["G_ID"]),
             slot("B2", "HUB_A", ["A_ID"]), slot("B2", "HUB_G", ["G_ID"]),
             slot("B2", "LNK_A_G", ["A_ID", "G_ID"])]
    ctx = run([row(1, "T")], [TG, b1, b2], slots, links=("LNK_A_G",))
    d = arts(ctx, "bridge")["bridge_t__a"].data
    assert d["joins"][0]["model"] == "stg_health__b2"
    # Without the link, lexical order picks B1.
    ctx = run([row(1, "T")], [TG, b1, b2], slots[:-1], links=("LNK_A_G",))
    assert arts(ctx, "bridge")["bridge_t__a"].data["joins"][0]["model"] \
        == "stg_health__b1"


def test_bridge_is_deterministic_under_input_order():
    b1, b2 = table("B1", ["A_ID", "G_ID"]), table("B2", ["A_ID", "G_ID"])
    slots = [slot("T", "HUB_G", ["G_ID"]),
             slot("B1", "HUB_A", ["A_ID"]), slot("B1", "HUB_G", ["G_ID"]),
             slot("B2", "HUB_A", ["A_ID"]), slot("B2", "HUB_G", ["G_ID"])]
    rows = [row(1, "T"), row(2, "T", column="G_ID", attr="Other")]
    a = plan(spec(rows, [TG, b1, b2], slots), cfg())
    b = plan(spec(rows[::-1], [b2, b1, TG], slots[::-1]), cfg())
    assert a == b


def test_no_bridge_gives_missing_grain_key_gap_with_candidates():
    b = table("B", ["A_ID"])
    other = table("C", ["A_ID", "G_ID"])
    ctx = run([row(1, "T"), row(2, "T", column="G_ID", attr="Other")],
              [TG, b, other],
              [slot("T", "HUB_G", ["G_ID"]), slot("B", "HUB_A", ["A_ID"]),
               slot("C", "HUB_A", ["A_ID"]),
               slot("C", "HUB_G", ["OTHER_ID"])])
    assert ctx.branches == [] and ctx.key_resolutions == {}
    assert not arts(ctx, "stage_hub") and not arts(ctx, "bridge")
    assert ctx.gapped_rows == {"m#1", "m#2"}
    gaps = sorted(ctx.gaps, key=lambda g: g.source_column)
    assert [(g.reason, g.source_table, g.source_column, g.target, g.row_ids)
            for g in gaps] == [
        ("missing_grain_key", "T", "G_ID", "SAT_A.Other", ("m#2",)),
        ("missing_grain_key", "T", "X", "SAT_A.Attr", ("m#1",))]
    detail = gaps[1].detail
    assert "HUB_A key absent on T" in detail
    assert "table B: no hub other than HUB_A is keyed on both T and B" in detail
    assert "table C: HUB_G: key columns differ" in detail


def test_gap_when_no_candidate_exists_at_all():
    ctx = run([row(1, "T")], [TG], [slot("T", "HUB_G", ["G_ID"])])
    (g,) = ctx.gaps
    assert g.reason == "missing_grain_key" and "none" in g.detail


def test_augmented_branch_without_key_uses_augmentation_gap():
    r = row(1, "T", outcome="augmentation_needed", kind="augmentation")
    ctx = run([r], [TG], [slot("T", "HUB_G", ["G_ID"])], sats=(SAUG,))
    (g,) = ctx.gaps
    assert g.reason == "no_verified_augmentation_key"
    assert ctx.gapped_rows == {"m#1"}


# --------------------------------------------------------------------------
# Spine walks
# --------------------------------------------------------------------------

def test_spine_walk_bridge():
    t = table("T", ["X", "PARENT_KEY_HASH", "KEY_HASH"])
    p = table("P", ["KEY_HASH", "PARENT_KEY_HASH", "A_ID"])
    walk = Walk("spans#0", "T", "PARENT_KEY_HASH", ("P",), (), "P", "A_ID",
                "T>P")
    ctx = run([row(1, "T")], [t, p], [slot("P", "HUB_A", ["A_ID"])],
              walks=[walk])
    (res,) = ctx.key_resolutions.values()
    assert (res.bridge, res.parent_bk) == ("bridge_t__a", "bridge_a_id")
    d = arts(ctx, "bridge")["bridge_t__a"].data
    assert d["joins"][0]["model"] == "stg_health__p"
    assert dict(d["joins"][0]["on"][0]) == \
        {"left": "t.parent_key_hash", "right": "b1.key_hash"}
    assert dict(d["columns"][0]) == {"column": "bridge_a_id", "expr": "b1.a_id"}
    render(arts(ctx, "bridge")["bridge_t__a"])


def test_spine_walk_descent_and_failure_reason():
    t = table("T", ["X", "PARENT_KEY_HASH", "KEY_HASH"])
    c = table("C", ["KEY_HASH", "PARENT_KEY_HASH", "A_ID"])
    walk = Walk("spans#0", "T", "PARENT_KEY_HASH", (), ("C",), "C", "A_ID", "T>C")
    ctx = run([row(1, "T")], [t, c], [slot("C", "HUB_A", ["A_ID"])],
              walks=[walk])
    d = arts(ctx, "bridge")["bridge_t__a"].data
    assert dict(d["joins"][0]["on"][0]) == \
        {"left": "b1.parent_key_hash", "right": "t.key_hash"}
    # Terminal table keyed on another hub only: gap names the walk.
    ctx = run([row(1, "T")], [t, c], [slot("C", "HUB_G", ["A_ID"])],
              walks=[walk])
    (g,) = ctx.gaps
    assert "walk spans#0: terminal table C has no key for HUB_A" in g.detail


def test_walk_tables_get_stg1_models():
    t = table("T", ["X", "PARENT_KEY_HASH", "KEY_HASH"])
    p = table("P", ["KEY_HASH", "PARENT_KEY_HASH", "A_ID"])
    walk = Walk("spans#0", "T", "PARENT_KEY_HASH", ("P",), (), "P", "A_ID", "r")
    ctx = run([row(1, "T")], [t, p], [], walks=[walk])
    assert {"stg_health__t", "stg_health__p"} <= set(arts(ctx, "stg1"))


# --------------------------------------------------------------------------
# Link parents
# --------------------------------------------------------------------------

LT = table("T", ["X", "A_ID", "G_ID"])
LSLOTS = [slot("T", "HUB_A", ["A_ID"]), slot("T", "HUB_G", ["G_ID"])]


def test_link_parent_uses_template_hub_order():
    ctx = run([row(1, "T", code="SAT_L")], [LT], LSLOTS, sats=(SL,),
              config=cfg(TEMPLATE_LINK_HUB_ORDER={"LNK_A_G": ("HUB_G", "HUB_A")}))
    (res,) = ctx.key_resolutions.values()
    assert [dict(h) for h in res.hub_keys] == \
        [{"code": "HUB_G", "raw": "g_id"}, {"code": "HUB_A", "raw": "a_id"}]
    assert res.parent_bk is None
    assert set(arts(ctx, "stage_hub")) == {"stg2_hub_t__a", "stg2_hub_t__g"}


def test_link_parent_falls_back_to_sorted_hub_codes():
    ctx = run([row(1, "T", code="SAT_L")], [LT], LSLOTS, sats=(SL,))
    (res,) = ctx.key_resolutions.values()
    assert [h["code"] for h in res.hub_keys] == ["HUB_A", "HUB_G"]


def test_link_parent_needs_a_key_for_every_hub():
    ctx = run([row(1, "T", code="SAT_L")], [LT], LSLOTS[:1], sats=(SL,))
    assert ctx.branches == [] and not arts(ctx, "stage_hub")
    (g,) = ctx.gaps
    assert g.reason == "missing_grain_key" and "HUB_G key absent on T" in g.detail
    assert ctx.gapped_rows == {"m#1"}


def test_link_hubs_helper():
    hubs = ("HUB_A", "HUB_G", "HUB_AG")
    assert link_hubs("LNK_A_G", hubs, {"LNK_A_G": ("HUB_G", "HUB_A")}) == \
        (("HUB_G", "HUB_A"), "template")
    assert link_hubs("LNK_A_G", hubs) == (("HUB_A", "HUB_G"), "sorted")
    assert link_hubs("LNK_A_G", ("HUB_A",)) is None
    assert link_hubs("LNK_AG", hubs) == (("HUB_AG",), "sorted")


# --------------------------------------------------------------------------
# Row accounting
# --------------------------------------------------------------------------

def test_every_row_ends_in_one_branch_or_one_gap():
    rows = [row(1, "T"), row(2, "T", column="G_ID", attr="Other"),
            row(3, "U", code="SAT_A", attr="Third")]
    u = table("U", ["X"])
    ctx = run(rows, [T, u], [slot("T", "HUB_A", ["A_ID"])])
    in_branch = [rid for b in ctx.branches for rid in b.row_ids]
    in_gap = [rid for g in ctx.gaps for rid in g.row_ids]
    assert sorted(in_branch + in_gap) == ["m#1", "m#2", "m#3"]
    assert set(in_gap) == ctx.gapped_rows == {"m#3"}
    # The hub stage of the kept branches is still planned.
    assert isinstance(arts(ctx, "stage_hub")["stg2_hub_t__a"], Artifact)
