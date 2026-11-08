"""Property test for ``dvgen.render_stitch.render_stitch``.

Feature: health-lob-dv-dbt-build, Property 24: Stitch uses one macro call

For any satellite with declared cross-table precedence over k >= 2 tables
sharing one key, the stitch file contains exactly one top-level
``stitch_incremental(`` call (never wrapped in another ``WITH``), k source
dicts in declared order, ``coalesce_rules`` in the declared precedence order
per column, ``unique_key='parent_bk'``, a final ``{% set coalesce_rules %}``
that closes with plain ``%}``, and no ``join`` keyword outside the macro call.

**Validates: Requirements 6.5**
"""
from __future__ import annotations

import re
import string

import pytest
from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen import naming
from dvgen.model import Artifact
from dvgen.render_stitch import StitchRenderError, render_stitch

# SQL words that must not appear in generated identifiers, so any match in the
# output can only come from the renderer itself.
_RESERVED = {"with", "join", "select", "from", "on", "as", "left", "inner"}

_WORD = st.text(alphabet=string.ascii_lowercase, min_size=1, max_size=6).filter(
    lambda w: w not in _RESERVED)
_IDENT = st.lists(_WORD, min_size=1, max_size=3).map("_".join).filter(
    lambda w: w not in _RESERVED)
_SAT_NAME = st.lists(
    st.text(alphabet=string.ascii_uppercase + string.digits, min_size=1, max_size=6),
    min_size=1, max_size=3,
).map("_".join).filter(lambda s: not s.startswith("AUG"))
_PREFIX = st.sampled_from(["OPUS_", "MAXIMUS_"])


@st.composite
def stitch_cases(draw):
    """A valid stitch artifact plus the declared sources and ladders."""
    sat = "SAT_" + draw(_SAT_NAME)
    prefix = draw(_PREFIX)
    k = draw(st.integers(min_value=2, max_value=5))
    models = draw(st.lists(_IDENT, min_size=k, max_size=k, unique=True))
    models = [f"stg_health__{m}" for m in models]
    tables = draw(st.lists(_IDENT, min_size=k, max_size=k, unique=True))
    n_cols = draw(st.integers(min_value=1, max_value=5))
    output_columns = draw(st.lists(_IDENT, min_size=n_cols, max_size=n_cols,
                                   unique=True))
    key_column = draw(_IDENT)

    # Which sources provide each column. Column 0 is shared by >= 2 sources
    # (the cross-table precedence); every source provides at least one column.
    provides = {c: set() for c in output_columns}
    provides[output_columns[0]] |= set(
        draw(st.lists(st.sampled_from(models), min_size=2, max_size=k, unique=True)))
    for col in output_columns[1:]:
        provides[col] |= set(
            draw(st.lists(st.sampled_from(models), min_size=1, max_size=k, unique=True)))
    for m in models:
        if not any(m in p for p in provides.values()):
            provides[draw(st.sampled_from(output_columns))].add(m)

    # Declared precedence: any permutation of the providers.
    ladders = {c: draw(st.permutations(sorted(provides[c]))) for c in output_columns}
    # Rule dict insertion order is independent of output_columns order.
    rule_keys = draw(st.permutations(output_columns))

    sources = []
    for m, table in zip(models, tables):
        cols = [{"src": draw(_IDENT), "tgt": c}
                for c in output_columns if m in provides[c]]
        sources.append({
            "model": m,
            "source_tag": prefix + table.upper(),
            "ldts_column": draw(st.sampled_from(
                ["inc_job_updated_at", "rec_refresh_at", "updated_at"])),
            "key_column": key_column,
            "columns": cols,
        })
    data = {
        "sat": sat,
        "parent_code": "HUB_" + draw(_SAT_NAME),
        "target_sat": naming.sat_model(sat, "standard"),
        "record_source_prefix": prefix,
        "sources": sources,
        "output_columns": output_columns,
        "coalesce_rules": {c: list(ladders[c]) for c in rule_keys},
    }
    if draw(st.booleans()):
        data["unique_key"] = "parent_bk"
    name = naming.stitch_model(sat)
    art = Artifact(kind="stitch", path=f"models/raw_vault/standard/stitched/{name}.sql",
                   name=name, data=data)
    return art, models, output_columns, ladders


def _rules_block(sql: str) -> list[str]:
    start = sql.index("{%- set coalesce_rules = {\n") + len("{%- set coalesce_rules = {\n")
    end = sql.index("\n} %}", start)
    return sql[start:end].split("\n")


@settings(max_examples=150)
@given(case=stitch_cases())
def test_stitch_single_top_level_call(case):
    art, models, output_columns, ladders = case
    sql = render_stitch(art)

    # Exactly one macro call, at top level, as the last statement of the file.
    assert sql.count("stitch_incremental(") == 1
    call_at = sql.index("{{ stitch_incremental(")
    assert sql.endswith(") }}\n")
    assert sql[call_at:].count("{{") == 1
    # Never wrapped in another WITH; no join anywhere outside the macro.
    assert not re.search(r"\bwith\b", sql, re.IGNORECASE)
    assert not re.search(r"\bjoin\b", sql, re.IGNORECASE)

    # The final set before the call is coalesce_rules and closes with plain %}.
    before = sql[:call_at]
    assert before.endswith("} %}\n\n")
    last_set = before.rindex("{%- set ")
    assert before[last_set:].startswith("{%- set coalesce_rules = {")
    assert "-%}" not in before[last_set:]

    call = sql[call_at:]
    assert "    unique_key='parent_bk',\n" in call
    assert f"    target_sat='{art.data['target_sat']}'\n" in call

    # k source dicts, aliases t0..t(k-1) in declared order.
    assert sql.count("'source_tag':") == len(models)
    found = re.findall(r"'model': '([^']+)',\n        'alias': 't(\d+)',", sql)
    assert found == [(m, str(i)) for i, m in enumerate(models)]

    # coalesce_rules: keys in output_columns order, ladders as declared.
    alias_of = {m: f"t{i}" for i, m in enumerate(models)}
    rows = _rules_block(sql)
    assert len(rows) == len(output_columns)
    for n, (row, col) in enumerate(zip(rows, output_columns)):
        comma = "," if n < len(output_columns) - 1 else ""
        expected = ("    '" + col + "': ["
                    + ", ".join(f"'{alias_of[m]}'" for m in ladders[col])
                    + "]" + comma)
        assert row == expected


@settings(max_examples=100)
@given(case=stitch_cases(), bad=_IDENT.filter(lambda s: s != "parent_bk"))
def test_stitch_rejects_other_unique_key(case, bad):
    art, *_ = case
    data = dict(art.data)
    data["unique_key"] = bad
    bad_art = Artifact(kind="stitch", path=art.path, name=art.name, data=data)
    with pytest.raises(StitchRenderError, match="unique_key"):
        render_stitch(bad_art)
