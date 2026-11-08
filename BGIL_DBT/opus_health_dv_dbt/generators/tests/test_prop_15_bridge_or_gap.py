"""Feature: health-lob-dv-dbt-build, Property 15: Bridge resolution or gap

For a table T with a satellite attribute whose hub H has no key on T, a bridge
exists iff some table B is keyed on H and shares a key (same column set) with T
on another hub. Then exactly one ``bridge_<stem>__<hub>`` artifact is planned,
joined to B on the shared key, carrying H's key columns, and the hub stage reads
it. Otherwise a ``missing_grain_key`` Gap lists every candidate checked with the
reason it failed, and the rows are in ``ctx.gapped_rows``. A candidate feeding a
link between the shared hub and H is preferred, then lexical order.

**Validates: Requirements 6.8, 6.9**
"""
from __future__ import annotations

from types import SimpleNamespace

from hypothesis import given, settings, strategies as st

from dvgen.model import (
    Column,
    IntermediateSpec,
    KeySlot,
    MappingRow,
    SatelliteFact,
    Table,
)
from dvgen.plan import PlanContext, STEPS, plan_grain_keys

HUBS = ("HUB_A", "HUB_G1", "HUB_G2")
GS = ("HUB_G1", "HUB_G2")
LINKS = {"HUB_G1": "LNK_A_G1", "HUB_G2": "LNK_A_G2"}
KEYCOLS = {"HUB_G1": ("G1_ID", "G1_ALT"), "HUB_G2": ("G2_ID", "G2_ALT")}
ALL_COLS = ("X", "A_ID", "G1_ID", "G1_ALT", "G2_ID", "G2_ALT")


def cfg():
    return SimpleNamespace(PROJECT="p", RECORD_SOURCE_PREFIX="OPUS_",
                           RECORD_SOURCE_GROUP="OPUS",
                           WATERMARK_COLUMN="inc_job_updated_at",
                           WATERMARK_OVERRIDES={}, STG1_SOURCE="raw")


def table(name):
    return Table(name, name.lower(),
                 tuple(Column(c, "text", "untyped", False) for c in ALL_COLS),
                 "unknown")


def slot(tbl, code, cols):
    return KeySlot(tbl, code, None, "", tuple(cols), "spec.key_slot")


@st.composite
def graphs(draw):
    """T's keys on G hubs, candidate tables B1..B4 (keyed on HUB_A), a decoy D."""
    t_keys = {g: draw(st.sampled_from(KEYCOLS[g])) for g in GS
              if draw(st.booleans())}
    cands = {}
    for name in draw(st.lists(st.sampled_from(["B1", "B2", "B3", "B4"]),
                              unique=True, max_size=4)):
        keys = {g: draw(st.sampled_from(KEYCOLS[g])) for g in GS
                if draw(st.booleans())}
        links = {g for g in GS if draw(st.booleans())}
        cands[name] = (keys, links)
    decoy = {g: KEYCOLS[g][0] for g in GS if draw(st.booleans())}
    return t_keys, cands, decoy


def build(t_keys, cands, decoy):
    slots = [slot("T", g, [c]) for g, c in t_keys.items()]
    for name, (keys, links) in cands.items():
        slots.append(slot(name, "HUB_A", ["A_ID"]))
        slots += [slot(name, g, [c]) for g, c in keys.items()]
        slots += [slot(name, LINKS[g], ["A_ID", KEYCOLS[g][0]]) for g in links]
    slots += [slot("D", g, [c]) for g, c in decoy.items()]
    tables = [table(n) for n in ["T", "D", *cands]]
    row = MappingRow("m#1", 1, "T", "X", "mapped", "satellite_attribute",
                     "SAT_A", "Attr", None, None, None, None)
    sat = SatelliteFact("SAT_A", "standard", "HUB_A", "", "own_spec")
    return IntermediateSpec("p", tuple(tables), HUBS, tuple(LINKS.values()),
                            (sat,), tuple(slots), (row,), (), (), ()).canonical()


def run(spec):
    ctx = PlanContext(spec=spec, cfg=cfg())
    for step in STEPS:
        step(ctx)
        if step is plan_grain_keys:
            break
    return ctx


def viable(t_keys, cands):
    """[(not feeds_link, candidate, shared hub)] per the property statement."""
    out = []
    for name, (keys, links) in cands.items():
        for g, cols in keys.items():
            if t_keys.get(g) == cols:
                out.append((g not in links, name, g))
    return sorted(out)


@settings(max_examples=200, deadline=None)
@given(graphs())
def test_bridge_or_gap(g):
    t_keys, cands, decoy = g
    ctx = run(build(t_keys, cands, decoy))
    bridges = [a for a in ctx.artifacts if a.kind == "bridge"]
    hubs = [a for a in ctx.artifacts if a.kind == "stage_hub"]
    options = viable(t_keys, cands)
    if options:
        _, best, shared = options[0]
        assert ctx.gaps == [] and ctx.gapped_rows == set()
        assert [b.name for b in bridges] == ["bridge_t__a"]
        d = bridges[0].data
        assert d["hub"] == "HUB_A" and d["table"] == "T"
        (join,) = d["joins"]
        assert join["model"] == f"stg_health__{best.lower()}"
        col = t_keys[shared].lower()
        assert [dict(o) for o in join["on"]] == \
            [{"left": f"t.{col}", "right": f"b1.{col}"}]
        assert [dict(c) for c in d["columns"]] == \
            [{"column": "bridge_a_id", "expr": "b1.a_id"}]
        (res,) = ctx.key_resolutions.values()
        assert res.bridge == "bridge_t__a" and res.source_model == "bridge_t__a"
        assert [h.data["source_model"] for h in hubs] == ["bridge_t__a"]
    else:
        assert bridges == [] and hubs == [] and ctx.branches == []
        assert ctx.key_resolutions == {}
        assert ctx.gapped_rows == {"m#1"}
        (gap,) = ctx.gaps
        assert gap.reason == "missing_grain_key" and gap.row_ids == ("m#1",)
        if not cands:
            assert "none" in gap.detail
        for name, (keys, _links) in cands.items():
            marker = f"table {name}: "
            assert marker in gap.detail
            tail = gap.detail.split(marker, 1)[1].split("; table ")[0]
            if not keys.keys() & t_keys.keys():
                assert tail.startswith("no hub other than HUB_A")
            else:
                assert "key columns differ" in tail
        assert "table D" not in gap.detail


def test_link_feeding_candidate_preferred_example():
    t_keys = {"HUB_G1": "G1_ID"}
    cands = {"B1": ({"HUB_G1": "G1_ID"}, set()),
             "B2": ({"HUB_G1": "G1_ID"}, {"HUB_G1"})}
    ctx = run(build(t_keys, cands, {}))
    (b,) = [a for a in ctx.artifacts if a.kind == "bridge"]
    assert b.data["joins"][0]["model"] == "stg_health__b2"
