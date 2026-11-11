"""Property 18: Staging edit is idempotent and respects existing columns.

Applying edit_stg twice gives the same bytes as once; text that already aliases
inc_job_updated_at outside comments is returned unchanged with status ``already``;
every edited (or already aliased) model matches the alias pattern.

**Validates: Requirements 7.2, 7.6**
"""
import sys
from pathlib import Path

from hypothesis import given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from add_inc_job_updated_at import (  # noqa: E402
    ALREADY_RE, STATUS_ALREADY, STATUS_CHANGED, STATUS_SKIPPED, Evidence, edit_stg,
)

col = st.text(alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ_", min_size=1, max_size=10)
tables = st.text(alphabet="ABCDEFGH_", min_size=1, max_size=8)
nls = st.sampled_from(["\n", "\r\n"])
indents = st.sampled_from(["", "    ", "\t"])
alias_stmt = st.sampled_from([
    '"INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,',
    '"X"::timestamp_ntz AS INC_JOB_UPDATED_AT,',
])


@st.composite
def stg_texts(draw, with_alias=False, comment_alias=False, garbage=False):
    nl = draw(nls)
    ind = draw(indents)
    cols = draw(st.lists(col, min_size=1, max_size=8, unique=True))
    items = [f'{ind}"{c}"::varchar as {c.lower()},' for c in cols]
    if with_alias:
        items.insert(draw(st.integers(0, len(items))), ind + draw(alias_stmt))
    lines = ["with src as (", "select"] + items + [
        f"from {{{{ source('raw', '{draw(tables)}') }}}}", ")", "select * from src"]
    if garbage:
        lines.insert(2, "    some_func(x),")
    if comment_alias:
        lines.insert(0, "-- the column as inc_job_updated_at is added later")
    text = nl.join(lines) + nl
    return ("\ufeff" if draw(st.booleans()) else "") + text


evidence = st.one_of(
    st.none().map(lambda _: Evidence()),
    st.builds(lambda: Evidence(raw_columns={}, z_prefix_tables=frozenset())),
    st.builds(lambda t: Evidence(z_prefix_tables=frozenset([t])), tables),
)


@settings(max_examples=150, deadline=None)
@given(text=st.one_of(stg_texts(), stg_texts(comment_alias=True), stg_texts(garbage=True)),
       ev=evidence)
def test_edit_twice_equals_once(text, ev):
    once, r1 = edit_stg(text, ev)
    twice, r2 = edit_stg(once, ev)
    assert twice == once
    if r1.status == STATUS_CHANGED:
        assert r2.status == STATUS_ALREADY
        assert ALREADY_RE.search(once)
    else:
        assert r1.status == STATUS_SKIPPED
        assert once == text


@settings(max_examples=150, deadline=None)
@given(text=stg_texts(with_alias=True, comment_alias=True), ev=evidence)
def test_existing_alias_is_unchanged(text, ev):
    out, res = edit_stg(text, ev)
    assert out == text
    assert res.status == STATUS_ALREADY
