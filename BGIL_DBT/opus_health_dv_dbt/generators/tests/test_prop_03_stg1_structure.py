"""Feature: health-lob-dv-dbt-build, Property 3: Stg1 structure and watermark

*For any* table and any ``WATERMARK_OVERRIDES`` map, the rendered Stg1 SQL
contains exactly one ``source(`` call, no ``join``, no ``hash(``/``md5(``,
ends with ``select * from source``, and selects
``WATERMARK_OVERRIDES.get(TABLE, WATERMARK_COLUMN)``. A table not in the map
selects ``WATERMARK_COLUMN``.

**Validates: Requirements 3.3, 3.6, 3.10**
"""
from __future__ import annotations

import re
from types import SimpleNamespace

from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen.model import COLUMN_KINDS, TYPE_ORIGINS, WATERMARK_EVIDENCE, Column, Table
from dvgen.plan import stg1_artifact
from dvgen.render_stg1 import column_alias, render_stg1

DEFAULT_WATERMARKS = ("inc_job_updated_at", "INC_JOB_UPDATED_AT", "rec_refresh_at")

_IDENT = st.from_regex(r"\A[A-Z][A-Z0-9_]{0,14}\Z", fullmatch=True)
# Names the planner actually meets: _HIST / HISTORY suffixes and twins, plus
# words that are SQL keywords or look like the forbidden tokens.
_SPECIAL = st.sampled_from(
    ["JOIN", "HASH", "MD5", "SOURCE", "FROM", "SELECT", "INC_JOB_UPDATED_AT",
     "REC_REFRESH_AT", "JOIN_DATE", "HASH_KEY"])
_COL_NAME = st.one_of(_IDENT, _SPECIAL)
_TABLE_BASE = st.from_regex(r"\A(BA|BJAZ|MAXI)_[A-Z][A-Z0-9_]{0,12}\Z",
                            fullmatch=True)
_TABLE_NAME = st.builds(lambda b, s: b + s, _TABLE_BASE,
                        st.sampled_from(["", "_HIST", "HISTORY", "_HISTORY"]))


@st.composite
def tables(draw, name=None):
    tname = name if name is not None else draw(_TABLE_NAME)
    names = draw(st.lists(_COL_NAME, min_size=0, max_size=8, unique=True))
    cols = tuple(
        Column(n, draw(st.sampled_from(sorted(COLUMN_KINDS))),
               draw(st.sampled_from(sorted(TYPE_ORIGINS))), draw(st.booleans()))
        for n in names)
    evidence = draw(st.sampled_from(sorted(WATERMARK_EVIDENCE)))
    return Table(tname, tname.lower(), cols, evidence)


@st.composite
def scenarios(draw):
    """A few distinct tables, a random overrides map over a name pool that
    includes some (not necessarily all) of them, and a default column."""
    names = draw(st.lists(_TABLE_NAME, min_size=1, max_size=4, unique=True))
    tbls = [draw(tables(name=n)) for n in names]
    extra = draw(st.lists(_TABLE_NAME, max_size=3))
    pool = sorted(set(names) | set(extra))
    overrides = draw(st.dictionaries(st.sampled_from(pool), _COL_NAME,
                                     max_size=len(pool)))  # empty map included
    default = draw(st.sampled_from(DEFAULT_WATERMARKS))
    keys = {t.name: frozenset(draw(st.lists(
        st.sampled_from([c.name for c in t.columns]), unique=True)))
        if t.columns else frozenset() for t in tbls}
    return tbls, overrides, default, keys


def _cfg(default, overrides):
    return SimpleNamespace(WATERMARK_COLUMN=default,
                           WATERMARK_OVERRIDES=overrides,
                           STG1_SOURCE="health_test_raw")


def _code(text: str) -> str:
    """SQL body without comment lines and quoted identifiers, lower-cased."""
    body = "\n".join(l for l in text.splitlines() if not l.startswith("--"))
    return re.sub(r'"[^"]*"', '""', body).lower()


def _select_lines(text: str) -> list[str]:
    lines = text.splitlines()
    start = lines.index("    select") + 1
    end = next(i for i, l in enumerate(lines) if l.startswith("    from {{ source("))
    return [l.rstrip(",") for l in lines[start:end]]


def _check_structure(text: str, table: str) -> None:
    code = _code(text)
    assert text.count("source(") == 1
    assert f"{{{{ source('health_test_raw', '{table}') }}}}" in text
    assert re.search(r"\bjoin\b", code) is None
    assert "hash(" not in code and "md5(" not in code
    assert code.count("with source as (") == 1
    assert text.endswith("select * from source\n")


@settings(max_examples=150, deadline=None)
@given(scenarios())
def test_stg1_structure_and_watermark(scenario):
    tbls, overrides, default, keys = scenario
    cfg = _cfg(default, overrides)
    for t in tbls:
        expected = overrides.get(t.name.upper(), default).upper()
        if t.name.upper() not in overrides:
            assert expected == default.upper()
        art = stg1_artifact(t, cfg, keys[t.name])
        assert art.data["watermark"].upper() == expected
        text = render_stg1(art)
        _check_structure(text, t.name)
        selects = _select_lines(text)
        # The watermark is selected exactly once, last, cast to timestamp_ntz.
        wm_ref = f'"{expected}"'
        assert selects[-1] == (
            f"    {wm_ref}::timestamp_ntz as {column_alias(expected)}")
        assert sum(1 for s in selects if s.lstrip().startswith(wm_ref)) == 1
        # Every other source column is still selected once.
        others = {c.name for c in t.columns} - {expected}
        assert len(selects) == len(others) + 1


@settings(max_examples=100, deadline=None)
@given(tables(), st.dictionaries(_TABLE_NAME, _COL_NAME, max_size=4),
       st.sampled_from(DEFAULT_WATERMARKS))
def test_override_applies_to_its_own_table_only(table, others, default):
    """Overrides listed for other tables never change this table's watermark,
    and adding this table's own entry changes only this table."""
    others = {k: v for k, v in others.items() if k != table.name.upper()}
    text = render_stg1(stg1_artifact(table, _cfg(default, others)))
    _check_structure(text, table.name)
    assert _select_lines(text)[-1].startswith(f'    "{default.upper()}"::')

    own = dict(others, **{table.name.upper(): "OVERRIDE_WM_COL"})
    text = render_stg1(stg1_artifact(table, _cfg(default, own)))
    _check_structure(text, table.name)
    assert _select_lines(text)[-1] == (
        '    "OVERRIDE_WM_COL"::timestamp_ntz as override_wm_col')
