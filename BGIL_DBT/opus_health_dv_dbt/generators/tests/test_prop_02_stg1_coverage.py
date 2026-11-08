"""Property 2: Stg1 coverage, naming and ``_HIST`` skip.

**Validates: Requirements 3.1, 3.2, 3.9**
"""
from __future__ import annotations

from types import SimpleNamespace

from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen.model import IntermediateSpec, KeySlot, MappingRow, Table, Walk
from dvgen.plan import plan, referenced_tables
from dvgen.readme import RoundInputs, render_round


def _cfg():
    return SimpleNamespace(
        PROJECT="p", RECORD_SOURCE_PREFIX="OPUS_", RECORD_SOURCE_GROUP="OPUS",
        WATERMARK_COLUMN="inc_job_updated_at", WATERMARK_OVERRIDES={},
        STG1_SOURCE="health_test_raw",
        SPEC_SOURCE="build_artifacts/hcon_spec.json",
        COLUMN_CATALOGUE="inputs/00_tables_index.DELTA3.json")


# Base names; each base contributes some subset of
# BASE, BASE_HIST (twin or orphan), BASE_HISTORY and HIST_BASE.
_BASES = st.lists(
    st.from_regex(r"\A[A-Z]{1,4}(_[A-Z]{1,4})?\Z", fullmatch=True)
    .filter(lambda s: "HIST" not in s),
    min_size=1, max_size=6, unique=True)

_VARIANTS = st.fixed_dictionaries({
    "base": st.booleans(),
    "hist": st.booleans(),
    "history": st.booleans(),
    "prefix": st.booleans(),
})

# How a table is referenced: mapping row, key slot, or bridge walk end.
_HOW = st.sampled_from(["row", "slot", "walk"])


@st.composite
def _specs(draw):
    names: list[str] = []
    for base in draw(_BASES):
        v = draw(_VARIANTS)
        for flag, name in (("base", base), ("hist", f"{base}_HIST"),
                           ("history", f"{base}_HISTORY"),
                           ("prefix", f"HIST_{base}")):
            if v[flag]:
                names.append(name)
    if not names:
        names.append(draw(_BASES)[0] + "_HIST")
    names = sorted(set(names))
    unreferenced = draw(st.sets(st.sampled_from(names), max_size=2))
    referenced = [n for n in names if n not in unreferenced] or names[:1]

    rows, slots, walks = [], [], []
    for i, name in enumerate(referenced):
        how = draw(_HOW)
        if how == "row":
            rows.append(MappingRow(f"m#{i}", i, name, "K", "mapped",
                                   "hub_key", "HUB_X", None, None, None,
                                   None, None))
        elif how == "slot":
            slots.append(KeySlot(name, "HUB_X", None, "k", ("K",),
                                 "spec.key_slot"))
        else:
            # A walk from the table to itself references only that table.
            walks.append(Walk(f"spans#{i}", name, "PARENT_KEY_HASH", (), (),
                              name, "KEY_HASH", "raw"))
    tables = [Table(n, n.lower(), (), "catalogue_yes") for n in names]
    perm = draw(st.permutations(tables))
    spec = IntermediateSpec("p", tuple(perm), (), (), (), tuple(slots),
                            tuple(rows), (), tuple(walks), ())
    return spec, set(referenced)


@settings(max_examples=150, deadline=None)
@given(_specs())
def test_stg1_coverage_naming_and_hist_skip(case):
    """Feature: health-lob-dv-dbt-build, Property 2: Stg1 coverage, naming and `_HIST` skip"""
    spec, referenced = case
    assert referenced_tables(spec) == referenced

    expected_skips = {n: n[:-len("_HIST")] for n in referenced
                      if n.endswith("_HIST") and n[:-len("_HIST")] in referenced}
    expected_built = referenced - set(expected_skips)

    p = plan(spec, _cfg())
    stg1 = [a for a in p.artifacts if a.kind == "stg1"]

    # Coverage and naming: one file per built table, named from its stem.
    files = sorted(a.path.rsplit("/", 1)[-1] for a in stg1)
    assert files == sorted(f"stg_health__{n.lower()}.sql"
                           for n in expected_built)
    assert len(files) == len(set(files))
    for a in stg1:
        stem = a.data["stem"]
        assert a.name == f"stg_health__{stem}"
        assert a.path == f"models/staging/health/stg_health__{stem}.sql"
        assert a.data["table"] in expected_built

    # _HIST skip rule; ..._HISTORY, HIST_... and orphan _HIST are built.
    assert dict(p.hist_skips) == expected_skips
    built = {a.data["table"] for a in stg1}
    for n in referenced:
        if n.endswith("_HISTORY") or n.startswith("HIST_"):
            assert n in built
        if n.endswith("_HIST") and n[:-len("_HIST")] not in referenced:
            assert n in built

    # Every skipped table appears in the README _HIST section.
    text = render_round(1, RoundInputs(project="p", input_digests=(), plan=p))
    section = text.split("### `_HIST` tables", 1)[1]
    assert f"{len(expected_skips)} `_HIST` tables skipped." in section
    for hist, twin in expected_skips.items():
        assert f"| {hist} | {twin} |" in section
