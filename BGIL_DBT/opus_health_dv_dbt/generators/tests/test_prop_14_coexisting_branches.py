"""Feature: health-lob-dv-dbt-build, Property 14: Coexisting values get distinct branches.

For any set of n columns of one table mapped to one attribute of a
multi-active satellite with pairwise distinct instances, the plan has exactly
n branches for that (table, attribute), and their literal child-key values are
pairwise distinct. On a single-active satellite the same rows become
``unresolved_mapping`` gaps and are never collapsed into one branch.

**Validates: Requirements 6.7**
"""
from __future__ import annotations

from types import SimpleNamespace

from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen.model import Column, IntermediateSpec, MappingRow, SatelliteFact, Table
from dvgen.plan import STEPS, PlanContext, plan_branches
from dvgen.render_stage import _childkey_expr

SA = SatelliteFact("SAT_A", "standard", "HUB_A", "", "own_spec")
MA = SatelliteFact("SAT_M", "standard", "HUB_A", "Item Code", "own_spec")


def cfg():
    return SimpleNamespace(PROJECT="p", RECORD_SOURCE_PREFIX="OPUS_",
                           RECORD_SOURCE_GROUP="OPUS",
                           WATERMARK_COLUMN="inc_job_updated_at",
                           WATERMARK_OVERRIDES={}, STG1_SOURCE="raw")


def run_to_branches(rows, tables):
    """Run the planner steps up to and including plan_branches."""
    s = IntermediateSpec("p", tuple(tables), ("HUB_A",), (), (SA, MA), (),
                         tuple(rows), (), (), ()).canonical()
    ctx = PlanContext(spec=s, cfg=cfg())
    for step in STEPS:
        step(ctx)
        if step is plan_branches:
            break
    return ctx


_COLUMN = st.from_regex(r"[A-Z][A-Z0-9_]{0,10}", fullmatch=True)
_INSTANCE = st.text(
    alphabet=st.sampled_from("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                             "0123456789 -_/&."),
    min_size=1, max_size=20,
).map(str.strip).filter(bool)


@st.composite
def coexisting_rows(draw):
    n = draw(st.integers(min_value=2, max_value=6))
    columns = draw(st.lists(_COLUMN, min_size=n, max_size=n, unique=True))
    instances = draw(st.lists(_INSTANCE, min_size=n, max_size=n, unique=True))
    attr = draw(st.sampled_from(["Amount", "Item Value", "Rate", "Benefit Amt"]))
    orders = draw(st.permutations(range(1, n + 1)))
    return columns, instances, attr, list(orders)


def make_rows(code, columns, instances, attr, orders):
    return [MappingRow(f"m#{o}", o, "T", c, "mapped", "satellite_attribute",
                       code, attr, inst, None, None, None)
            for c, inst, o in zip(columns, instances, orders)]


def make_table(columns):
    return Table("T", "t", tuple(Column(c, "text", "untyped", False)
                                 for c in columns), "unknown")


@settings(max_examples=150, deadline=None)
@given(coexisting_rows())
def test_multi_active_coexisting_values_get_one_branch_each(case):
    columns, instances, attr, orders = case
    rows = make_rows("SAT_M", columns, instances, attr, orders)
    ctx = run_to_branches(rows, [make_table(columns)])

    assert ctx.gaps == []
    branches = [b for b in ctx.branches
                if b.satellite == "SAT_M" and b.table == "T"]
    assert len(branches) == len(columns)

    literals = []
    for b in branches:
        assert b.multi_active
        (ck,) = b.childkey
        assert ck["column"] == "ITEMCODE"
        assert "expr" not in ck
        literals.append(ck["literal"])
        # The renderer turns the literal into the AutomateDV constant.
        assert _childkey_expr(ck, "test") == "!" + ck["literal"]
        (p,) = b.payload
        assert isinstance(p["expr"], str) and len(p["row_ids"]) == 1
    assert sorted(literals) == sorted(instances)
    assert len(set(literals)) == len(literals)

    suffixes = [b.branch for b in branches]
    assert None not in suffixes and len(set(suffixes)) == len(suffixes)

    covered = sorted(rid for b in branches for rid in b.row_ids)
    assert covered == sorted(r.row_id for r in rows)


@settings(max_examples=150, deadline=None)
@given(coexisting_rows())
def test_single_active_coexisting_values_are_gaps_not_collapsed(case):
    columns, instances, attr, orders = case
    rows = make_rows("SAT_A", columns, instances, attr, orders)
    ctx = run_to_branches(rows, [make_table(columns)])

    assert [b for b in ctx.branches if b.satellite == "SAT_A"] == []
    gapped = {}
    for g in ctx.gaps:
        assert g.reason == "unresolved_mapping"
        assert g.target == f"SAT_A.{attr}"
        assert "single-active" in g.detail
        for rid in g.row_ids:
            gapped[rid] = g.source_column
    assert gapped == {r.row_id: r.column for r in rows}
