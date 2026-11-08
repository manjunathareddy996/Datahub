"""Property test for the satellite parent / child-key fallback (design Q3).

Feature: health-lob-dv-dbt-build, Property 5: Spec normalization and parent fallback

For any hcon-shaped or mxh3-shaped satellite record, the normalized parent
equals the own-spec parent when non-empty, else the sibling model parent when
present. When both are empty, no satellite model is emitted and exactly one
``missing_parent`` gap exists for it. When the child-key field is absent, no
model is emitted and a ``missing_childkey_field`` gap exists. Otherwise the
child key equals the source field.

The hcon and mxh3 adapters are built later (tasks 7.2 / 7.3), so the records
are plain dicts in the two Spec_JSON shapes, normalized here to
``SatelliteFact`` the way the design describes:

- hcon: ``satellites[]`` entry, parent ``anchor``, child key ``model_childkey``.
- mxh3: ``model.sat_parent[<SAT>]`` and ``model.sat_childkey[<SAT>]``.

Fields are blanked (``""`` / ``None``) or removed at random, and a random
sibling model (or none) supplies the fallback parent.

**Validates: Requirements 4.1, 4.3**
"""
from __future__ import annotations

import string
from types import SimpleNamespace

from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen.model import IntermediateSpec, SatelliteFact
from dvgen.naming import sat_model
from dvgen.plan import SiblingModel, plan, resolve_satellite

_ABSENT = object()  # marker: the field is removed from the record

_NAME = st.text(alphabet=string.ascii_uppercase, min_size=1, max_size=4)
_CODES = st.lists(_NAME.map(lambda n: "SAT_" + n), min_size=1, max_size=8,
                  unique=True)
_PARENT_VALUE = st.one_of(
    st.just(_ABSENT), st.just(""), st.just(None),
    st.builds(lambda p, n: p + n, st.sampled_from(["HUB_", "LNK_"]), _NAME))
_CHILDKEY_VALUE = st.one_of(
    st.just(_ABSENT), st.just(""),
    st.text(alphabet=string.ascii_letters + " _|", min_size=1, max_size=8))
_TRACKS = ("standard", "augmented")


# --------------------------------------------------------------------------
# Local normalizers (mirror the design's Q3 field locations)
# --------------------------------------------------------------------------

def _own_fact(code: str, track: str, parent, childkey) -> SatelliteFact:
    parent = parent or None          # "" and None are both "empty"
    return SatelliteFact(code=code, track=track, parent=parent,
                         childkey=childkey,
                         parent_origin="own_spec" if parent else "none")


def normalize_hcon(entry: dict) -> SatelliteFact:
    """One hcon ``satellites[]`` entry -> SatelliteFact."""
    childkey = entry["model_childkey"] if "model_childkey" in entry else None
    return _own_fact(entry["code"], entry["track"], entry.get("anchor"),
                     childkey)


def normalize_mxh3(spec_json: dict) -> list[SatelliteFact]:
    """Every satellite in an mxh3 ``model`` section -> SatelliteFact."""
    model = spec_json["model"]
    parents, childkeys = model["sat_parent"], model["sat_childkey"]
    codes = sorted(set(parents) | set(childkeys))
    return [_own_fact(code, "standard", parents.get(code),
                      childkeys[code] if code in childkeys else None)
            for code in codes]


def _put(record: dict, key: str, value) -> None:
    if value is not _ABSENT:
        record[key] = value


# --------------------------------------------------------------------------
# Strategies
# --------------------------------------------------------------------------

@st.composite
def _hcon_records(draw):
    codes = draw(_CODES)
    records = []
    for code in codes:
        for track in draw(st.lists(st.sampled_from(_TRACKS), min_size=1,
                                   max_size=2, unique=True)):
            entry = {"code": code, "track": track,
                     "anchor_kind": draw(st.sampled_from(["hub", "link", "ref"]))}
            _put(entry, "anchor", draw(_PARENT_VALUE))
            _put(entry, "model_childkey", draw(_CHILDKEY_VALUE))
            records.append(entry)
    return codes, records


@st.composite
def _mxh3_spec(draw):
    codes = draw(_CODES)
    sat_parent, sat_childkey = {}, {}
    for code in codes:
        # At least one of the two maps names the satellite.
        parent = draw(_PARENT_VALUE)
        childkey = draw(_CHILDKEY_VALUE)
        if parent is _ABSENT and childkey is _ABSENT:
            parent = ""
        _put(sat_parent, code, parent)
        _put(sat_childkey, code, childkey)
    return codes, {"model": {"sat_parent": sat_parent,
                             "sat_childkey": sat_childkey}}


@st.composite
def _sibling(draw, codes):
    if draw(st.booleans()):
        return None
    pool = list(codes) + ["SAT_ZZZZZ"]
    parents = {}
    for code in draw(st.lists(st.sampled_from(pool), unique=True)):
        parents[code] = draw(st.one_of(
            st.just(""), st.builds(lambda n: "HUB_" + n, _NAME)))
    return SiblingModel.from_mxh3(
        {"model": {"sat_parent": parents, "sat_childkey": {}}},
        source="../maximus_health_dv_dbt/build_artifacts/mxh3_spec.json")


@st.composite
def _case(draw):
    shape = draw(st.sampled_from(["hcon", "mxh3"]))
    if shape == "hcon":
        codes, records = draw(_hcon_records())
        facts = [normalize_hcon(r) for r in records]
    else:
        codes, spec_json = draw(_mxh3_spec())
        facts = normalize_mxh3(spec_json)
    return shape, facts, draw(_sibling(codes))


# --------------------------------------------------------------------------
# Oracle and helpers
# --------------------------------------------------------------------------

def _expected_parent(fact: SatelliteFact, sibling):
    if fact.parent:
        return fact.parent, "own_spec"
    if sibling is not None and sibling.sat_parent.get(fact.code):
        return sibling.sat_parent[fact.code], "sibling_model"
    return None, "none"


def _cfg():
    return SimpleNamespace(
        PROJECT="p", RECORD_SOURCE_PREFIX="OPUS_", RECORD_SOURCE_GROUP="OPUS",
        WATERMARK_COLUMN="inc_job_updated_at", WATERMARK_OVERRIDES={},
        STG1_SOURCE="health_test_raw",
        SPEC_SOURCE="build_artifacts/hcon_spec.json")


def _spec(facts) -> IntermediateSpec:
    return IntermediateSpec("p", (), (), (), tuple(facts), (), (), (), (), ())


# --------------------------------------------------------------------------
# Properties
# --------------------------------------------------------------------------

@settings(max_examples=300)
@given(case=_case())
def test_resolve_satellite_parent_fallback(case):
    _shape, facts, sibling = case
    for fact in facts:
        res = resolve_satellite(fact, sibling)
        parent, origin = _expected_parent(fact, sibling)
        expected_situations = tuple(
            s for s, hit in (("parent_empty", parent is None),
                             ("childkey_field_absent", fact.childkey is None))
            if hit)
        assert res.situations == expected_situations
        if expected_situations:
            assert res.fact is None
            assert set(res.detail) == set(expected_situations)
            continue
        assert res.fact is not None
        assert res.fact.code == fact.code and res.fact.track == fact.track
        assert res.fact.parent == parent
        assert res.fact.parent_origin == origin
        # The child key is the source field, never the sibling's.
        assert res.fact.childkey == fact.childkey


@settings(max_examples=200)
@given(case=_case())
def test_plan_omits_satellite_and_records_gaps(case):
    _shape, facts, sibling = case
    p = plan(_spec(facts), _cfg(), sibling)
    sat_names = {a.name for a in p.artifacts}
    parent_facts = {f.subject: f for f in p.derived_facts
                    if f.category == "satellite_parent"}
    childkey_facts = {f.subject: f for f in p.derived_facts
                      if f.category == "satellite_childkey"}

    for fact in facts:
        parent, origin = _expected_parent(fact, sibling)
        mine = [g for g in p.gaps
                if g.target == fact.code and g.track == fact.track]
        reasons = sorted(g.reason for g in mine)
        subject = f"{fact.code} ({fact.track})"

        expected = sorted(
            ([] if parent is not None else ["missing_parent"])
            + ([] if fact.childkey is not None else ["missing_childkey_field"]))
        assert reasons == expected
        assert reasons.count("missing_parent") <= 1

        if expected:
            # Omitted: no satellite model and no resolved facts.
            assert sat_model(fact.code, fact.track) not in sat_names
            assert subject not in parent_facts
            assert subject not in childkey_facts
        else:
            assert parent_facts[subject].value == parent
            assert parent_facts[subject].origin == origin
            assert childkey_facts[subject].value == fact.childkey
