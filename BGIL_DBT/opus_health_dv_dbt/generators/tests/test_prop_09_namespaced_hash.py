"""Property test for namespaced key hashing in ``dvgen.render_stage``.

Feature: health-lob-dv-dbt-build, Property 9: Namespaced key hashing

For any vault code and raw key expression, the stage emits
``PARENT_NK = "'" + code + "|' || (" + raw + ")"`` and
``hashed_columns[hkey(code)] = 'PARENT_NK'``; link stages emit the ``LNK_``
namespace with components in hub-code order (the supplied ``hub_keys``
order). No stage hashes a bare raw key.

**Validates: Requirements 5.3, 9.3**
"""
from __future__ import annotations

import re
import string

from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen import naming
from dvgen.model import Artifact
from dvgen.render_stage import render_stage

_PLAIN = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*\Z")

# --------------------------------------------------------------------------
# Strategies
# --------------------------------------------------------------------------

_SEGMENT = st.text(alphabet=string.ascii_uppercase + string.digits,
                   min_size=1, max_size=6)
_NAME = st.lists(_SEGMENT, min_size=1, max_size=3).map("_".join)

_IDENT = st.from_regex(r"[a-z][a-z0-9_]{0,10}", fullmatch=True)


def _composite(cols: list[str]) -> str:
    return (f"case when coalesce({', '.join(cols)}) is null then null else "
            + " || '|' || ".join(f"coalesce({c},'')" for c in cols) + " end")


# Raw business-key expressions over stg1 aliases, as keys.raw_key builds them:
# a bare alias, a function call, a concatenation or a null-safe composite.
_RAW = st.one_of(
    _IDENT,
    _IDENT.map(lambda c: f"trim({c})"),
    st.tuples(_IDENT, _IDENT).map(lambda t: f"upper({t[0]}) || {t[1]}"),
    st.lists(_IDENT, min_size=2, max_size=3, unique=True).map(_composite),
)

_TABLE = st.from_regex(r"[A-Z][A-Z0-9_]{0,15}", fullmatch=True)


@st.composite
def _hubs_and_link(draw, min_hubs=2, max_hubs=4):
    """Distinct hub names, a link name that clashes with none, raw keys and
    an arbitrary (not necessarily sorted) hub order."""
    names = draw(st.lists(_NAME, min_size=min_hubs, max_size=max_hubs,
                          unique=True))
    link = draw(_NAME.filter(lambda n: n not in names))
    raws = draw(st.lists(_RAW, min_size=len(names), max_size=len(names)))
    order = draw(st.permutations(list(range(len(names)))))
    hubs = [(f"HUB_{names[i]}", raws[i]) for i in order]
    return f"LNK_{link}", hubs


def _common(kind: str, target: str, table: str) -> dict:
    return {
        "target": target,
        "source_model": f"stg_health__{table.lower()}",
        "table": table,
        "record_source": naming.record_source("OPUS_", table),
        "load_datetime": "INC_JOB_UPDATED_AT",
    }


def _artifact(kind: str, data: dict) -> Artifact:
    return Artifact(kind=kind, path="models/x/stage.sql", name="stage", data=data)


_PAYLOAD = [{"column": "PAYLOADA", "expr": "col_a"},
            {"column": "PAYLOADB", "expr": None}]

# --------------------------------------------------------------------------
# Parsing the rendered yaml_metadata block
# --------------------------------------------------------------------------


def _unquote(value: str) -> str:
    if value.startswith("'") and value.endswith("'"):
        return value[1:-1]
    assert value.startswith('"') and value.endswith('"'), value
    out, i, inner = [], 0, value[1:-1]
    while i < len(inner):
        if inner[i] == "\\":
            i += 1
        out.append(inner[i])
        i += 1
    return "".join(out)


def _sections(text: str) -> tuple[list[tuple[str, str | None]], dict[str, str]]:
    """Top-level ``hashed_columns`` (ordered) and ``derived_columns`` entries."""
    block = text.split("{%- set yaml_metadata -%}\n", 1)[1]
    block = block.split("{%- endset -%}", 1)[0]
    hashed: list[tuple[str, str | None]] = []
    derived: dict[str, str] = {}
    section = None
    for line in block.splitlines():
        if not line.startswith(" "):
            section = line.rstrip(":") if line.endswith(":") else None
            continue
        if line.startswith("    "):
            continue  # HASHDIFF details
        name, _, value = line.strip().partition(":")
        value = value.strip()
        if section == "hashed_columns":
            hashed.append((name, _unquote(value) if value else None))
        elif section == "derived_columns":
            derived[name] = _unquote(value)
    return hashed, derived


def _component(raw: str) -> str:
    return raw if _PLAIN.match(raw) else f"({raw})"


def _expected_link_nk(link: str, hubs: list[tuple[str, str]]) -> str:
    return f"'{link}|' || " + " || '|' || ".join(_component(r) for _, r in hubs)


def _assert_never_bare(hashed, derived, raws) -> None:
    """Every hashed source is a derived NK column that starts with a vault
    code namespace; none is (or derives to) a bare raw key."""
    for _name, source in hashed:
        if source is None:  # HASHDIFF
            continue
        assert source == "PARENT_NK" or source.endswith("_HKEY_NK"), source
        assert source not in raws
        nk = derived[source]
        assert re.match(r"'(HUB|LNK)_[A-Z0-9_]+\|' \|\| ", nk), nk
        assert nk not in raws


# --------------------------------------------------------------------------
# Properties
# --------------------------------------------------------------------------


@settings(max_examples=150)
@given(name=_NAME, raw=_RAW, table=_TABLE,
       kind=st.sampled_from(["stage_hub", "stage_sat", "stage_aug"]))
def test_hub_parent_stage_hashes_namespaced_parent_nk(name, raw, table, kind):
    code = f"HUB_{name}"
    data = _common(kind, code, table)
    data.update(parent_code=code, parent_bk=raw)
    if kind != "stage_hub":
        data["payload"] = _PAYLOAD
    hashed, derived = _sections(render_stage(_artifact(kind, data)))

    hk = naming.hkey(code)
    keyed = [(n, s) for n, s in hashed if s is not None]
    assert keyed == [(hk, "PARENT_NK")]
    assert derived["PARENT_BK"] == raw
    assert derived["PARENT_NK"] == f"'{code}|' || ({raw})"
    assert derived["PARENT_NK"].startswith(f"'{code}|'")
    _assert_never_bare(hashed, derived, {raw})


@settings(max_examples=150)
@given(spec=_hubs_and_link(), table=_TABLE)
def test_link_stage_hashes_namespaced_keys_in_hub_order(spec, table):
    link, hubs = spec
    data = _common("stage_link", link, table)
    data.update(parent_code=link,
                hub_keys=[{"code": c, "raw": r} for c, r in hubs])
    hashed, derived = _sections(render_stage(_artifact("stage_link", data)))

    link_hk = naming.hkey(link)
    expected = [(naming.hkey(c), f"{naming.hkey(c)}_NK") for c, _ in hubs]
    expected.append((link_hk, f"{link_hk}_NK"))
    # Hash-key names come from naming.hkey, hubs in the supplied order.
    assert hashed == expected
    for code, raw in hubs:
        nk = derived[f"{naming.hkey(code)}_NK"]
        assert nk == f"'{code}|' || {_component(raw)}"
    link_nk = derived[f"{link_hk}_NK"]
    assert link_nk.startswith(f"'{link}|' || ")
    assert link_nk == _expected_link_nk(link, hubs)
    _assert_never_bare(hashed, derived, {r for _, r in hubs})


@settings(max_examples=150)
@given(spec=_hubs_and_link(), table=_TABLE,
       kind=st.sampled_from(["stage_sat", "stage_aug"]))
def test_link_parent_sat_hashes_namespaced_link_key(spec, table, kind):
    link, hubs = spec
    data = _common(kind, link, table)
    data.update(parent_code=link, payload=_PAYLOAD,
                hub_keys=[{"code": c, "raw": r} for c, r in hubs])
    hashed, derived = _sections(render_stage(_artifact(kind, data)))

    keyed = [(n, s) for n, s in hashed if s is not None]
    assert keyed == [(naming.hkey(link), "PARENT_NK")]
    assert derived["PARENT_NK"] == _expected_link_nk(link, hubs)
    assert derived["PARENT_BK"] == " || '|' || ".join(
        _component(r) for _, r in hubs)
    _assert_never_bare(hashed, derived, {r for _, r in hubs})
