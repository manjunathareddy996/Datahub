"""Property test for fallback fan-in (planner step 4, ``plan_branches``).

Feature: health-lob-dv-dbt-build, Property 13: Fallback fan-in is a complete ordered coalesce

For any non-empty list of fallback columns from one table onto one attribute,
given in workbook row order, the derived expression is the bare column when
the list has one element, and otherwise ``coalesce(c1, ..., cn)`` with exactly
those columns in that order. The header comment names all n columns.

Rows are drawn on one table, one single-active satellite and one attribute,
with no ``instance`` (so they are fallbacks, never coexisting values). Columns
may repeat across rows; the expected column list is the distinct columns in
``row_order``. Row orders are a random permutation, so input order differs
from workbook order.

**Validates: Requirements 6.6**
"""
from __future__ import annotations

import string
from types import SimpleNamespace

from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen.model import Column, IntermediateSpec, MappingRow, SatelliteFact, Table
from dvgen.naming import payload_column
from dvgen.plan import STEPS, PlanContext, plan_branches
from dvgen.render_stg1 import column_alias

SA = SatelliteFact("SAT_A", "standard", "HUB_A", "", "own_spec")

_COLUMN = st.builds(
    lambda head, tail: head + tail,
    st.sampled_from(string.ascii_uppercase),
    st.text(alphabet=string.ascii_uppercase + string.digits + "_",
            max_size=6))
_ATTRIBUTE = st.sampled_from(["Attr", "Member Name", "Sum Insured",
                              "Claim Amount 2"])


def _cfg():
    return SimpleNamespace(PROJECT="p", RECORD_SOURCE_PREFIX="OPUS_",
                           RECORD_SOURCE_GROUP="OPUS",
                           WATERMARK_COLUMN="inc_job_updated_at",
                           WATERMARK_OVERRIDES={}, STG1_SOURCE="raw")


def _run_to_branches(rows, columns):
    tbl = Table("T", "t", tuple(Column(c, "text", "untyped", False)
                                for c in columns), "unknown")
    spec = IntermediateSpec("p", (tbl,), ("HUB_A",), (), (SA,), (),
                            tuple(rows), (), (), ()).canonical()
    ctx = PlanContext(spec=spec, cfg=_cfg())
    for step in STEPS:
        step(ctx)
        if step is plan_branches:
            break
    return ctx


@st.composite
def _case(draw):
    columns = draw(st.lists(_COLUMN, min_size=1, max_size=5,
                            unique_by=str.upper))
    picks = draw(st.lists(st.sampled_from(columns), min_size=1, max_size=8))
    orders = draw(st.permutations(range(1, len(picks) + 1)))
    attribute = draw(_ATTRIBUTE)
    rows = [MappingRow(f"m#{o}", o, "T", col, "mapped", "satellite_attribute",
                       "SAT_A", attribute, None, None, None, None)
            for col, o in zip(picks, orders)]
    return columns, rows, attribute


@settings(max_examples=200)
@given(case=_case())
def test_fallback_fan_in_is_complete_ordered_coalesce(case):
    columns, rows, attribute = case
    ctx = _run_to_branches(rows, columns)

    ordered = sorted(rows, key=lambda r: r.row_order)
    expected_cols: list[str] = []
    for r in ordered:
        if r.column not in expected_cols:
            expected_cols.append(r.column)
    aliases = tuple(column_alias(c) for c in expected_cols)
    column = payload_column(attribute)

    assert ctx.gaps == []
    (branch,) = ctx.branches
    assert branch.satellite == "SAT_A" and branch.table == "T"
    assert branch.multi_active is False and branch.childkey == ()
    (entry,) = branch.payload
    assert entry["attribute"] == attribute
    assert entry["column"] == column

    # Every distinct column exactly once, in row order.
    assert entry["source_columns"] == tuple(expected_cols)
    if len(aliases) == 1:
        assert entry["expr"] == aliases[0]
    else:
        assert entry["expr"] == aliases
    # Every row is accounted for, in row order.
    assert entry["row_ids"] == tuple(r.row_id for r in ordered)

    notes = [n for n in branch.header_notes if n.startswith(f"{column}:")]
    if len(rows) == 1:
        assert notes == []
        return
    (note,) = notes
    how = (f"coalesce({', '.join(aliases)})" if len(aliases) > 1
           else aliases[0])
    assert how in note
    for r in ordered:
        assert f"{r.column} ({r.row_id})" in note
    # The note lists the rows in row order.
    positions = [note.index(f"{r.column} ({r.row_id})") for r in ordered]
    assert positions == sorted(positions)
