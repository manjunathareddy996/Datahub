"""Property test for ``dvgen.types.resolve_type`` and the Stg1 casts.

Feature: health-lob-dv-dbt-build, Property 4: Cast rule and type resolution

For any column with a catalogue type, a legacy type, both, or neither, and any
key flag: the resolved kind is the catalogue type if present, else the legacy
type, else ``text`` with origin ``untyped``. The rendered cast is the
trimmed-varchar idiom when the column is a key column or of kind ``text``,
``::number`` for ``number``, and ``::timestamp_ntz`` for ``timestamp``. Every
``untyped`` column appears in the README untyped list, and the Stg1 header
states that types are Derived_Facts.

**Validates: Requirements 3.4, 3.5, 3.7, 3.8**
"""
from __future__ import annotations

import string

from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen.model import Artifact, Plan
from dvgen.readme import RoundInputs, render_round
from dvgen.render_stg1 import cast_expression, column_alias, render_stg1
from dvgen.types import resolve_type

KINDS = ("text", "number", "timestamp")
WATERMARK = "INC_JOB_UPDATED_AT"

_FIRST = string.ascii_uppercase + "_"
_REST = string.ascii_uppercase + string.digits + "_"
_IDENT = st.builds(
    lambda a, b: a + b,
    st.sampled_from(_FIRST),
    st.text(alphabet=_REST, min_size=0, max_size=12),
)
# Column names: plain identifiers, reserved words and digit-led names, never
# the watermark (which the renderer always casts as timestamp).
_COLUMN = st.one_of(
    _IDENT,
    st.sampled_from(["FROM", "SELECT", "BODY", "2D_ECHO", "ORDER"]),
).filter(lambda n: n != WATERMARK)

_KIND = st.one_of(st.none(), st.sampled_from(KINDS))

# One column: (name, index kind or None, legacy kind or None, is_key).
_COL_SPEC = st.tuples(_COLUMN, _KIND, _KIND, st.booleans())
_TABLE_SPEC = st.tuples(
    _IDENT,
    st.lists(_COL_SPEC, min_size=1, max_size=12,
             unique_by=lambda c: c[0]),
)


def _expected_cast(name: str, kind: str, is_key: bool) -> str:
    ref = '"' + name + '"'
    if is_key or kind == "text":
        return f"nullif(trim(to_varchar({ref})), '')"
    if kind == "number":
        return f"{ref}::number"
    return f"{ref}::timestamp_ntz"


def _flip_case(text: str, mask: list[bool]) -> str:
    return "".join(c.lower() if m else c for c, m in zip(text, mask))


@settings(max_examples=200, deadline=None)
@given(name=_COLUMN, table=_IDENT, idx=_KIND, leg=_KIND, is_key=st.booleans(),
       mask=st.lists(st.booleans(), min_size=16, max_size=16))
def test_resolution_precedence_and_cast(name, table, idx, leg, is_key, mask):
    """Index beats legacy beats ('text', 'untyped'); cast follows kind/key."""
    index = {table: {name: idx}} if idx else {}
    legacy = {table: {name: leg}} if leg else {}
    # Lookups are case-insensitive on table and column.
    kind, origin = resolve_type(_flip_case(table, mask),
                                _flip_case(name, mask), index, legacy)
    if idx:
        assert (kind, origin) == (idx, "index")
    elif leg:
        assert (kind, origin) == (leg, "legacy")
    else:
        assert (kind, origin) == ("text", "untyped")
    assert cast_expression(name, kind, is_key) == _expected_cast(
        name, kind, is_key)


def _stg1_artifact(table, cols):
    stem = table.lower()
    return Artifact(
        kind="stg1", path=f"models/staging/health/stg_health__{stem}.sql",
        name=f"stg_health__{stem}",
        data={"table": table, "stem": stem, "source": "health_src",
              "watermark": WATERMARK, "watermark_evidence": "catalogue_yes",
              "columns": cols})


def _untyped_rows(readme: str) -> set[tuple[str, str]]:
    section = readme.split("#### Untyped columns", 1)[1]
    section = section.split("\n#### ", 1)[0]
    rows = set()
    for line in section.splitlines():
        if not line.startswith("| ") or line.startswith("| Table |"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        rows.add((cells[0], cells[1]))
    return rows


@settings(max_examples=100, deadline=None)
@given(spec=_TABLE_SPEC)
def test_rendered_stg1_and_readme(spec):
    """Every column is cast by its resolved kind and key flag; untyped
    columns are listed in the README; the header names Derived_Facts."""
    table, col_specs = spec
    index = {table: {n: i for n, i, _, _ in col_specs if i}}
    legacy = {table: {n: l for n, _, l, _ in col_specs if l}}

    cols = []
    for name, _, _, is_key in col_specs:
        kind, origin = resolve_type(table, name, index, legacy)
        cols.append({"name": name, "kind": kind, "type_origin": origin,
                     "is_key": is_key})
    artifact = _stg1_artifact(table, cols)
    sql = render_stg1(artifact)

    header = [ln for ln in sql.splitlines() if ln.startswith("--")]
    assert any("Types are Derived_Facts" in ln for ln in header)

    selects = {ln.strip().rstrip(",") for ln in sql.splitlines()
               if ln.startswith("    ") and " as " in ln
               and not ln.lstrip().startswith(("select", "from"))}
    for col in cols:
        line = (f"{_expected_cast(col['name'], col['kind'], col['is_key'])}"
                f" as {column_alias(col['name'])}")
        assert line in selects, (line, sql)
    wm = f'"{WATERMARK}"::timestamp_ntz as {column_alias(WATERMARK)}'
    assert wm in selects
    assert len(selects) == len(cols) + 1

    plan = Plan(artifacts=(artifact,), gaps=(), derived_facts=(),
                watermark_risks=())
    readme = render_round(1, RoundInputs(
        project="opus_health_dv_dbt", input_digests=(), plan=plan))
    expected_untyped = {(table, c["name"]) for c in cols
                        if c["type_origin"] == "untyped"}
    assert _untyped_rows(readme) == expected_untyped
