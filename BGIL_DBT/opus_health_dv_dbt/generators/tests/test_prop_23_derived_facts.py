"""Property test for the recorded Derived_Facts (Requirement 4.4).

Feature: health-lob-dv-dbt-build, Property 23: Derived facts are recorded

For any intermediate spec, every hub, every link, and every satellite's parent
and child key used by the build appears in the README Derived_Facts table with
its origin.

Specs carry random hubs, links and satellites (own parent, empty parent with
an optional sibling-model fallback, absent child-key field) and no mapping
rows, so only the satellite resolution and fact-recording steps act on them.
The check is made twice: on ``plan.derived_facts`` and on the Derived_Facts
section of the README round rendered from that plan. Satellites the build
omits (no parent after the fallback, or no child-key field) must not appear.

**Validates: Requirements 4.4**
"""
from __future__ import annotations

import string
from types import SimpleNamespace

from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen.model import IntermediateSpec, SatelliteFact
from dvgen.plan import SiblingModel, plan
from dvgen.readme import RoundInputs, _cell, _childkey_text, render_round

SPEC_SRC = "build_artifacts/hcon_spec.json"
SIB_SRC = "../maximus_health_dv_dbt/build_artifacts/mxh3_spec.json"

_NAME = st.text(alphabet=string.ascii_uppercase, min_size=1, max_size=4)
_TRACKS = ("standard", "augmented", "reference")
_CHILDKEY = st.one_of(
    st.none(), st.just(""),
    st.text(alphabet=string.ascii_letters + " _", min_size=1, max_size=8))


def _cfg():
    return SimpleNamespace(
        PROJECT="p", RECORD_SOURCE_PREFIX="OPUS_", RECORD_SOURCE_GROUP="OPUS",
        WATERMARK_COLUMN="inc_job_updated_at", WATERMARK_OVERRIDES={},
        STG1_SOURCE="health_test_raw", SPEC_SOURCE=SPEC_SRC)


@st.composite
def _case(draw):
    hubs = draw(st.lists(_NAME.map(lambda n: "HUB_" + n), max_size=6))
    links = draw(st.lists(_NAME.map(lambda n: "LNK_" + n), max_size=6))
    anchors = st.one_of(
        st.sampled_from(hubs + links) if hubs or links else st.nothing(),
        st.builds(lambda p, n: p + n, st.sampled_from(["HUB_", "LNK_"]),
                  _NAME))
    keys = draw(st.lists(
        st.tuples(_NAME.map(lambda n: "SAT_" + n), st.sampled_from(_TRACKS)),
        max_size=8, unique=True))
    sats = []
    for code, track in keys:
        parent = draw(st.one_of(st.none(), anchors))
        sats.append(SatelliteFact(
            code=code, track=track, parent=parent, childkey=draw(_CHILDKEY),
            parent_origin="own_spec" if parent else "none"))
    sibling = None
    if draw(st.booleans()):
        pool = sorted({c for c, _ in keys} | {"SAT_ZZZZZ"})
        parents = {c: draw(st.one_of(st.just(""), anchors))
                   for c in draw(st.lists(st.sampled_from(pool), unique=True))}
        sibling = SiblingModel(sat_parent=parents, source=SIB_SRC)
    spec = IntermediateSpec("p", (), tuple(hubs), tuple(links), tuple(sats),
                            (), (), (), (), ())
    return spec, sibling


def _expected(sat: SatelliteFact, sibling):
    """(parent, origin, source) the build uses, or None if omitted."""
    if sat.childkey is None:
        return None
    if sat.parent:
        return sat.parent, "own_spec", SPEC_SRC
    if sibling is not None and sibling.sat_parent.get(sat.code):
        return sibling.sat_parent[sat.code], "sibling_model", SIB_SRC
    return None


def _subsections(readme: str) -> dict[str, list[str]]:
    """Derived_Facts sub-tables: title (without count) -> table body rows."""
    section = readme.split("### Derived_Facts", 1)[1]
    section = section.split("### `_HIST` tables", 1)[0]
    out: dict[str, list[str]] = {}
    for chunk in section.split("#### ")[1:]:
        title, _, body = chunk.partition("\n")
        rows = [ln for ln in body.splitlines() if ln.startswith("| ")]
        out[title.rsplit(" (", 1)[0]] = rows[1:]   # drop the header row
    return out


def _row(*cells) -> str:
    return "| " + " | ".join(_cell(c) for c in cells) + " |"


@settings(max_examples=200)
@given(case=_case())
def test_derived_facts_recorded(case):
    spec, sibling = case
    p = plan(spec, _cfg(), sibling)
    facts = set(p.derived_facts)
    readme = render_round(1, RoundInputs(project="p", input_digests=(),
                                         plan=p))
    sub = _subsections(readme)
    hub_rows, link_rows = set(sub["Hubs"]), set(sub["Links"])
    sat_rows = sub["Satellite parent and child key"]

    for code in spec.hubs:
        assert any(f.category == "hub" and f.subject == code
                   and f.origin == "own_spec" for f in facts)
        assert _row(code, "own_spec", SPEC_SRC) in hub_rows
    for code in spec.links:
        assert any(f.category == "link" and f.subject == code
                   and f.origin == "own_spec" for f in facts)
        assert _row(code, "own_spec", SPEC_SRC) in link_rows

    parent_facts = {f.subject: f for f in facts
                    if f.category == "satellite_parent"}
    childkey_facts = {f.subject: f for f in facts
                      if f.category == "satellite_childkey"}
    sat_subjects = {r.split(" | ", 1)[0][2:] for r in sat_rows}
    built = set()
    for sat in spec.satellites:
        subject = f"{sat.code} ({sat.track})"
        exp = _expected(sat, sibling)
        if exp is None:
            assert subject not in parent_facts
            assert subject not in childkey_facts
            assert subject not in sat_subjects
            continue
        built.add(subject)
        parent, origin, src = exp
        pf, cf = parent_facts[subject], childkey_facts[subject]
        assert (pf.value, pf.origin, pf.source) == (parent, origin, src)
        assert (cf.value, cf.origin, cf.source) == (
            sat.childkey, "own_spec", SPEC_SRC)
        sources = ", ".join(sorted({src, SPEC_SRC}))
        assert _row(subject, parent, origin, _childkey_text(sat.childkey),
                    "own_spec", sources) in sat_rows

    # Exactly the built satellites are listed, each once.
    assert len(sat_rows) == len(built)
    assert sat_subjects == built
