"""Property test for macro selection in ``dvgen.plan`` and ``render_vault``.

Feature: health-lob-dv-dbt-build, Property 6: Macro selection and multi-source maps

For any satellite fed by n stage models with child-key flag c, the rendered
file calls ``automate_dv.sat`` (n=1, not c), ``automate_dv.ma_sat`` (n=1, c),
``sat_multi_source`` (n>=2, not c) or ``ma_sat_multi_source`` (n>=2, c). For
n>=2 the ``src_column_map`` and ``src_record_source_map`` keys both equal the
``source_model`` entries, every ``src_record_source_map`` value is the project
record-source group, and every payload column appears in some stage's
``src_column_map``. For n=1 neither map appears.

**Validates: Requirements 4.2, 6.3, 6.4**
"""
from __future__ import annotations

import re
from types import SimpleNamespace

from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen import naming
from dvgen.model import (
    Column,
    IntermediateSpec,
    KeySlot,
    MappingRow,
    SatelliteFact,
    Table,
)
from dvgen.plan import plan
from dvgen.render_vault import render_vault

GROUP = "OPUS"
ATTRS = ["Alpha", "Beta Two", "Gamma-3", "Delta", "Epsilon Five"]


def _cfg():
    return SimpleNamespace(PROJECT="p", RECORD_SOURCE_PREFIX="OPUS_",
                           RECORD_SOURCE_GROUP=GROUP,
                           WATERMARK_COLUMN="inc_job_updated_at",
                           WATERMARK_OVERRIDES={}, STG1_SOURCE="raw")


@st.composite
def cases(draw):
    n_tables = draw(st.integers(1, 4))
    child_key = draw(st.booleans())
    tables, rows, slots = [], [], []
    counter = 0
    for i in range(n_tables):
        name = f"TBL{i}"
        attrs = draw(st.lists(st.sampled_from(ATTRS), min_size=1, max_size=3,
                              unique=True))
        cols = [f"C{i}_{j}" for j in range(len(attrs))]
        tables.append(Table(name, name.lower(),
                            tuple(Column(c, "text", "untyped", False)
                                  for c in ["KEY_ID", *cols]), "unknown"))
        slots.append(KeySlot(name, "HUB_P", None, "", ("KEY_ID",),
                             "spec.key_slot"))
        for col, attr in zip(cols, attrs):
            counter += 1
            rows.append(MappingRow(f"m#{counter}", counter, name, col,
                                   "mapped", "satellite_attribute", "SAT_X",
                                   attr, f"Kind{i}" if child_key else None,
                                   None, None, None))
    spec = IntermediateSpec(
        "p", tuple(tables), ("HUB_P",), (),
        (SatelliteFact("SAT_X", "standard", "HUB_P",
                       "Kind" if child_key else "", "own_spec"),),
        tuple(slots), tuple(rows), (), (), ())
    return spec, n_tables, child_key


def _block(lines, start, pred):
    out = []
    for line in lines[start:]:
        if not pred(line):
            break
        out.append(line)
    return out


def _parse(text):
    lines = text.splitlines()
    parsed = {"source_model": [], "payload": [], "rs_map": None,
              "col_map": None}
    for i, line in enumerate(lines):
        if line.startswith("source_model: '"):
            parsed["source_model"] = [line.split("'")[1]]
        elif line == "source_model:":
            parsed["source_model"] = [
                b.split("'")[1] for b in
                _block(lines, i + 1, lambda s: s.startswith("  - "))]
        elif line == "src_payload:":
            parsed["payload"] = [
                b.split("'")[1] for b in
                _block(lines, i + 1, lambda s: s.startswith("  - "))]
        elif line == "src_record_source_map:":
            parsed["rs_map"] = {
                m.group(1): m.group(2) for m in
                (re.match(r"  (\w+): '(\w+)'$", b) for b in
                 _block(lines, i + 1, lambda s: re.match(r"  \w+: '", s)))}
        elif "src_column_map={" in line:
            entries = _block(lines, i + 1, lambda s: "'" in s and "[" in s)
            parsed["col_map"] = {
                m.group(1): re.findall(r"'(\w+)'", m.group(2)) for m in
                (re.match(r"\s*'(\w+)': \[(.*)\],?$", e) for e in entries)}
    return parsed


@settings(max_examples=100, deadline=None)
@given(cases())
def test_macro_selection_and_multi_source_maps(case):
    spec, n_tables, child_key = case
    result = plan(spec, _cfg())
    sats = [a for a in result.artifacts if a.kind == "sat"]
    assert len(sats) == 1 and not result.gaps
    stages = [a for a in result.artifacts if a.kind == "stage_sat"]
    n = len(stages)
    assert n == n_tables

    text = render_vault(sats[0])
    if n == 1:
        macro_call = "{{ automate_dv.ma_sat(" if child_key else "{{ automate_dv.sat("
    else:
        macro_call = ("{{ ma_sat_multi_source(" if child_key
                      else "{{ sat_multi_source(")
    calls = re.findall(r"\{\{ (?:automate_dv\.)?\w*sat\w*\(", text)
    assert calls == [macro_call]

    parsed = _parse(text)
    assert sorted(parsed["source_model"]) == sorted(a.name for a in stages)
    if n == 1:
        assert "src_column_map" not in text
        assert "src_record_source_map" not in text
        return

    sources = set(parsed["source_model"])
    assert parsed["col_map"] is not None and parsed["rs_map"] is not None
    assert set(parsed["col_map"]) == sources
    assert set(parsed["rs_map"]) == sources
    assert set(parsed["rs_map"].values()) == {GROUP}
    mapped = {c for cols in parsed["col_map"].values() for c in cols}
    assert set(parsed["payload"]) <= mapped
    expected = {naming.payload_column(r.attribute) for r in spec.rows}
    assert set(parsed["payload"]) == expected
