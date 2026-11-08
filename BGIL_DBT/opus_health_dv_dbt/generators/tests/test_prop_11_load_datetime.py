"""Feature: health-lob-dv-dbt-build, Property 11: LOAD_DATETIME is a column reference

*For any* emitted stage and any ``WATERMARK_OVERRIDES`` map, ``LOAD_DATETIME``
equals the upper-cased ``WATERMARK_OVERRIDES.get(TABLE, WATERMARK_COLUMN)`` of
the stage's source table and does not start with ``!``.

Covered here:

- per-table stages (``stage_hub``, ``stage_link``, ``stage_sat``,
  ``stage_aug``) rendered by ``render_stage``: ``LOAD_DATETIME: '<UPPER wm>'``;
- an override changes only its own table's stages, every other stage is
  byte-identical;
- an override value starting with ``!`` is refused, never rendered;
- stitch stages (``render_stitch_stage``) whose source is the stitch: always
  the stitch's output column ``INC_JOB_UPDATED_AT``, whatever the overrides;
- reference views (``render_ref``): ``<watermark alias> as LOAD_DATETIME``.

**Validates: Requirements 3.10, 5.8, 7.3**
"""
from __future__ import annotations

import re

import pytest
from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen import naming
from dvgen.model import Artifact
from dvgen.render_ref import render_ref
from dvgen.render_stage import RenderError, render_stage
from dvgen.render_stitch import (
    STITCH_LDTS_OUTPUT,
    StitchRenderError,
    render_stitch_stage,
    stitch_stage_model,
)
from dvgen.render_stg1 import column_alias

PREFIX = "OPUS_"
DEFAULT_WATERMARKS = ("inc_job_updated_at", "INC_JOB_UPDATED_AT", "rec_refresh_at")
STAGE_KINDS = ("stage_hub", "stage_link", "stage_sat", "stage_aug")

_TABLE_NAME = st.builds(
    lambda b, s: b + s,
    st.from_regex(r"\A(BA|BJAZ|MAXI)_[A-Z][A-Z0-9_]{0,12}\Z", fullmatch=True),
    st.sampled_from(["", "_HIST", "HISTORY"]))
_WM_COL = st.one_of(
    st.from_regex(r"\A[A-Za-z][A-Za-z0-9_]{0,14}\Z", fullmatch=True),
    st.sampled_from(["rec_refresh_at", "REC_REFRESH_AT", "inc_job_updated_at",
                     "Updated_At", "load_ts"]))

_LDTS_LINE = re.compile(r"^  LOAD_DATETIME: '([^']*)'$", re.MULTILINE)
_REF_LDTS = re.compile(r"^    (\S+) as LOAD_DATETIME$", re.MULTILINE)


@st.composite
def scenarios(draw):
    """Distinct tables (spelled in mixed case, as callers may pass them), a
    random overrides map over a pool that includes some of them (the empty
    map included) and a default column."""
    names = draw(st.lists(_TABLE_NAME, min_size=1, max_size=4, unique=True))
    spelled = [draw(st.sampled_from([n, n.lower()])) for n in names]
    extra = draw(st.lists(_TABLE_NAME, max_size=3))
    pool = sorted(set(names) | set(extra))
    overrides = draw(st.dictionaries(st.sampled_from(pool), _WM_COL,
                                     max_size=len(pool)))
    default = draw(st.sampled_from(DEFAULT_WATERMARKS))
    return spelled, overrides, default


def _stage(kind: str, table: str, load_datetime: str) -> Artifact:
    upper = table.upper()
    stem = table.lower()
    data = dict(table=table, source_model=naming.stg1_model(stem),
                record_source=naming.record_source(PREFIX, upper),
                load_datetime=load_datetime)
    if kind == "stage_hub":
        data.update(target="HUB_CLAIM", parent_code="HUB_CLAIM",
                    parent_bk="claim_id")
        name = naming.stg2_model("hub", stem, "HUB_CLAIM")
    elif kind == "stage_link":
        data.update(target="LNK_CLAIM_POLICY", parent_code="LNK_CLAIM_POLICY",
                    hub_keys=[{"code": "HUB_CLAIM", "raw": "claim_id"},
                              {"code": "HUB_POLICY", "raw": "policy_no"}])
        name = naming.stg2_model("link", stem, "LNK_CLAIM_POLICY")
    else:
        sat = "SAT_AUG_CLAIM_NOTE" if kind == "stage_aug" else "SAT_CLAIM_NOTE"
        data.update(target=sat, parent_code="HUB_CLAIM", parent_bk="claim_id",
                    payload=[{"column": "NOTETEXT", "expr": "note_text"}])
        name = naming.stg2_model("aug" if kind == "stage_aug" else "sat",
                                 stem, "SAT_CLAIM_NOTE")
    return Artifact(kind=kind, path=f"models/x/{name}.sql", name=name, data=data)


def _render_all(tables, default, overrides) -> dict[tuple[str, str], str]:
    out = {}
    for t in tables:
        wm = naming.watermark_for(t, default, overrides)
        for kind in STAGE_KINDS:
            out[(t, kind)] = render_stage(_stage(kind, t, wm))
    return out


def _ldts(text: str) -> str:
    found = _LDTS_LINE.findall(text)
    assert len(found) == 1, found
    return found[0]


@settings(max_examples=150, deadline=None)
@given(scenarios())
def test_stage_load_datetime_is_upper_watermark_column(scenario):
    tables, overrides, default = scenario
    for (t, _kind), text in _render_all(tables, default, overrides).items():
        expected = overrides.get(t.upper(), default).upper()
        if t.upper() not in overrides:
            assert expected == default.upper()
        value = _ldts(text)
        assert value == expected
        assert not value.startswith("!")


@settings(max_examples=100, deadline=None)
@given(scenarios(), st.data())
def test_override_changes_only_its_own_table(scenario, data):
    tables, overrides, default = scenario
    target = data.draw(st.sampled_from(tables))
    new_col = data.draw(_WM_COL)
    before = _render_all(tables, default, overrides)
    after = _render_all(tables, default,
                        dict(overrides, **{target.upper(): new_col}))
    for key, text in after.items():
        t, _kind = key
        if t.upper() == target.upper():
            assert _ldts(text) == new_col.upper()
            # Only the LOAD_DATETIME line may differ.
            assert (_LDTS_LINE.sub("", text) == _LDTS_LINE.sub("", before[key]))
        else:
            assert text == before[key]


@settings(max_examples=100, deadline=None)
@given(_TABLE_NAME, _WM_COL, st.sampled_from(DEFAULT_WATERMARKS),
       st.sampled_from(STAGE_KINDS))
def test_bang_override_is_refused(table, col, default, kind):
    wm = naming.watermark_for(table, default, {table.upper(): "!" + col})
    assert wm.startswith("!")
    with pytest.raises(RenderError):
        render_stage(_stage(kind, table, wm))


def _stitch_stage(tables, load_datetime=None) -> Artifact:
    sat = "SAT_POLICY_BONUS_TRACKING"
    data = {"sat": sat, "source_model": naming.stitch_model(sat),
            "parent_code": "HUB_POLICY", "payload": ["BONUSAMOUNT"],
            "source_tags": [naming.source_tag(PREFIX, t) for t in tables]}
    if load_datetime is not None:
        data["load_datetime"] = load_datetime
    name = stitch_stage_model(sat)
    return Artifact(kind="stitch_stage", path=f"models/x/{name}.sql",
                    name=name, data=data)


@settings(max_examples=100, deadline=None)
@given(scenarios())
def test_stitch_stage_reads_stitch_output_column(scenario):
    """A stitch stage's source is the stitch, whose watermark output column is
    always ``inc_job_updated_at``; per-table overrides do not reach it."""
    tables, overrides, _default = scenario
    tables = sorted({t.upper() for t in tables})
    text = render_stitch_stage(_stitch_stage(tables))
    value = _ldts(text)
    assert value == STITCH_LDTS_OUTPUT.upper()
    assert not value.startswith("!")
    for t in tables:
        wm = overrides.get(t)
        if wm is not None and wm.upper() != STITCH_LDTS_OUTPUT.upper():
            with pytest.raises(StitchRenderError):
                render_stitch_stage(_stitch_stage(tables, wm.upper()))


@settings(max_examples=100, deadline=None)
@given(scenarios())
def test_ref_load_datetime_is_watermark_alias(scenario):
    tables, overrides, default = scenario
    tables = sorted({t.upper() for t in tables})
    sources = [{"source_model": naming.stg1_model(t.lower()), "table": t,
                "record_source": naming.source_tag(PREFIX, t),
                "load_datetime": naming.watermark_for(t, default, overrides),
                "columns": [{"column": "IFSCCODE", "expr": "ifsc_code"}]}
               for t in tables]
    name = naming.ref_model("REF_BANK_BRANCH_IFSC")
    art = Artifact(kind="ref", path=f"models/x/{name}.sql", name=name,
                   data={"ref": "REF_BANK_BRANCH_IFSC",
                         "record_source_prefix": PREFIX, "sources": sources})
    found = _REF_LDTS.findall(render_ref(art))
    assert len(found) == len(tables)
    for t, alias in zip(tables, found):
        expected = overrides.get(t, default)
        assert alias == column_alias(expected)
        assert alias.strip('"').upper() == expected.upper()
        assert not alias.startswith("!")
