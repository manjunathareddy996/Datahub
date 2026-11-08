"""Unit tests for dvgen.template_links (hub order of Template_Project links)."""
from __future__ import annotations

import pytest

from dvgen.template_links import (
    TemplateLinkError,
    parse_link_model,
    template_link_hub_order,
)

MODEL = """{%- set yaml_metadata -%}
source_model: 'stg2_lnk_claim_party'
src_pk: 'CLAIM_PARTY_HKEY'
src_fk:
  - 'PARTY_HKEY'
  - "CLAIM_HKEY"
src_ldts: 'LOAD_DATETIME'
{%- endset -%}
"""


def test_parse_keeps_src_fk_order():
    assert parse_link_model(MODEL) == \
        ("LNK_CLAIM_PARTY", ("HUB_PARTY", "HUB_CLAIM"))


def test_non_link_model_gives_none():
    assert parse_link_model("select 1") is None


@pytest.mark.parametrize("text", [
    "src_pk: 'X_HKEY'\n",
    "src_pk: 'X_HKEY'\nsrc_fk:\n  - 'A_HKEY'\n  - 'A_HKEY'\n",
    "src_pk: 'X_HKEY'\nsrc_fk:\n  - 'A_ID'\n",
])
def test_bad_models_raise(text):
    with pytest.raises(TemplateLinkError):
        parse_link_model(text)


def test_directory_scan(tmp_path):
    d = tmp_path / "links"
    d.mkdir()
    (d / "lnk_claim_party.sql").write_text(MODEL, encoding="utf-8")
    (d / "other.sql").write_text("select 1", encoding="utf-8")
    assert template_link_hub_order(d) == \
        {"LNK_CLAIM_PARTY": ("HUB_PARTY", "HUB_CLAIM")}
    assert template_link_hub_order(tmp_path / "missing") == {}


def test_conflicting_files_raise(tmp_path):
    (tmp_path / "a.sql").write_text(MODEL, encoding="utf-8")
    (tmp_path / "b.sql").write_text(
        MODEL.replace("'PARTY_HKEY'", "'X_HKEY'"), encoding="utf-8")
    with pytest.raises(TemplateLinkError):
        template_link_hub_order(tmp_path)
