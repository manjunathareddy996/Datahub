"""Property test for ``dvgen.naming``.

Feature: health-lob-dv-dbt-build, Property 8: Project-independent naming

For any vault code, the hub, link and satellite model names and the hash-key
name are the same for both projects. Satellite names are
``sat_<code without SAT_, lowercased>`` (with ``aug_`` after ``sat_`` on the
augmented track) and never contain a project or source-system segment.
Payload column names depend only on the attribute text. Only
``record_source`` and ``source_tag`` take the project's Record_Source_Prefix,
and the project changes nothing but that prefix.

**Validates: Requirements 5.1, 5.2, 5.4, 5.9**
"""
from __future__ import annotations

import inspect
import string

import pytest
from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen import naming
from dvgen.naming import (
    NamingError, hkey, hub_model, link_model, payload_column, record_source,
    sat_model, source_tag, stg2_model,
)

# Record_Source_Prefix and group of each Health_Project (design project_config).
PROJECTS = {"OPUS": "OPUS_", "MAXIMUS": "MAXIMUS_"}
_PROJECT_WORDS = ("opus", "maximus")

# Code segments: upper-case alphanumerics. Segments naming a project are
# excluded so any project text in an output must have come from the Builder.
# "AUG" is excluded as a first segment because SAT_AUG_<x> is the augmented
# model-name prefix, not a standard satellite code.
_SEGMENT = st.text(
    alphabet=string.ascii_uppercase + string.digits, min_size=1, max_size=8
).filter(lambda s: not any(w in s.lower() for w in _PROJECT_WORDS))
_NAME = st.lists(_SEGMENT, min_size=1, max_size=4).filter(
    lambda parts: parts[0] != "AUG"
).map("_".join)
_TABLE = st.text(alphabet=string.ascii_letters + string.digits + "_", min_size=1, max_size=20)

_ASCII_ALNUM = set(string.ascii_letters + string.digits)


def _no_project_segment(name: str) -> None:
    assert not any(w in name.lower() for w in _PROJECT_WORDS), name


@settings(max_examples=200)
@given(name=_NAME)
def test_hub_link_names_and_hkeys(name):
    hub_code, link_code = f"HUB_{name}", f"LNK_{name}"

    # Requirement 5.1: hash key is the code without HUB_/LNK_ plus _HKEY.
    assert hkey(hub_code) == f"{name}_HKEY"
    assert hkey(link_code) == f"{name}_HKEY"
    # Case of the input code does not matter.
    assert hkey(hub_code.lower()) == hkey(hub_code)

    assert hub_model(hub_code) == f"hub_{name.lower()}"
    assert link_model(link_code) == f"lnk_{name.lower()}"
    # Model name given as a code or as a model name resolves to the same name.
    assert hub_model(hub_model(hub_code)) == hub_model(hub_code)
    assert link_model(link_model(link_code)) == link_model(link_code)

    for out in (hkey(hub_code), hkey(link_code), hub_model(hub_code), link_model(link_code)):
        _no_project_segment(out)


@settings(max_examples=200)
@given(name=_NAME)
def test_sat_names_have_no_prefix(name):
    code = f"SAT_{name}"
    # Requirement 5.4: sat_<name>, aug_ after sat_ on the augmented track.
    assert sat_model(code, "standard") == f"sat_{name.lower()}"
    assert sat_model(code, "augmented") == f"sat_aug_{name.lower()}"
    for track in ("standard", "augmented"):
        out = sat_model(code, track)
        _no_project_segment(out)
        # Re-deriving from the model name is stable.
        assert sat_model(out, track) == out


@settings(max_examples=200)
@given(name=_NAME, table=_TABLE, stem=_TABLE)
def test_project_changes_only_record_source_prefix(name, table, stem):
    # Requirement 5.9: no name except record_source/source_tag can see the project.
    for fn in (hkey, hub_model, link_model, sat_model, stg2_model):
        assert "prefix" not in inspect.signature(fn).parameters

    per_project = {}
    for project, prefix in PROJECTS.items():
        rs = record_source(prefix, table)
        tag = source_tag(prefix, table)
        assert rs == f"!{prefix}{table.upper()}"
        assert tag == f"{prefix}{table.upper()}"
        # Stripping the prefix leaves the same project-free text.
        per_project[project] = (rs[len("!" + prefix):], tag[len(prefix):])
    assert per_project["OPUS"] == per_project["MAXIMUS"]


@settings(max_examples=200)
@given(attribute=st.text(max_size=40))
def test_payload_column_depends_only_on_text(attribute):
    expected = "".join(c for c in attribute if c in _ASCII_ALNUM).upper()
    if not expected:
        with pytest.raises(NamingError):
            payload_column(attribute)
        return
    assert payload_column(attribute) == expected
    # Same text, same column, regardless of surrounding punctuation/spacing.
    assert payload_column(f"  {attribute} - ") == expected
    assert naming.ck_column(attribute) == expected
