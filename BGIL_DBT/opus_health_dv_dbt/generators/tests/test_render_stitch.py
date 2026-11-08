"""Unit tests for dvgen.render_stitch (task 5.9; Requirements 5.6, 6.5)."""
from __future__ import annotations

import re

import pytest

from dvgen import emit
from dvgen.model import Artifact
from dvgen.render_stitch import (
    StitchRenderError,
    render_stitch,
    render_stitch_stage,
    stitch_stage_model,
)

A = "stg_health__bjaz_hm_member_dtls"
B = "stg_health__bjaz_pa_detl_extn"


def _stitch_data(**over):
    data = {
        "sat": "SAT_POLICY_BONUS_TRACKING",
        "parent_code": "HUB_POLICY",
        "target_sat": "sat_policy_bonus_tracking",
        "unique_key": "parent_bk",
        "record_source_prefix": "OPUS_",
        "sources": [
            {"model": A, "source_tag": "OPUS_BJAZ_HM_MEMBER_DTLS",
             "ldts_column": "inc_job_updated_at", "key_column": "contract_id",
             "columns": [{"src": "bonus_si", "tgt": "bonusamount"},
                         {"src": "cumm_bonus_per", "tgt": "cumulativebonuspercentage"}]},
            {"model": B, "source_tag": "OPUS_BJAZ_PA_DETL_EXTN",
             "ldts_column": "rec_refresh_at", "key_column": "contract_id",
             "columns": [{"src": "coalesce(cum_bonus, cummulative_bonus)",
                          "tgt": "bonusamount"}]},
        ],
        "output_columns": ["bonusamount", "cumulativebonuspercentage"],
        # declared precedence: B before A for bonusamount
        "coalesce_rules": {"bonusamount": [B, A], "cumulativebonuspercentage": [A]},
    }
    data.update(over)
    return data


def _stitch(**over):
    return Artifact(kind="stitch",
                    path="models/raw_vault/standard/stitched/stitch_policy_bonus_tracking.sql",
                    name="stitch_policy_bonus_tracking", data=_stitch_data(**over))


def _stage(**over):
    data = {
        "sat": "SAT_POLICY_BONUS_TRACKING",
        "source_model": "stitch_policy_bonus_tracking",
        "parent_code": "HUB_POLICY",
        "payload": ["CUMULATIVEBONUSPERCENTAGE", "BONUSAMOUNT"],
        "source_tags": ["OPUS_BJAZ_HM_MEMBER_DTLS", "OPUS_BJAZ_PA_DETL_EXTN"],
    }
    data.update(over)
    return Artifact(kind="stitch_stage",
                    path="models/raw_vault/standard/staging/"
                         "stg2_sat_stitch__policy_bonus_tracking.sql",
                    name="stg2_sat_stitch__policy_bonus_tracking", data=data)


# -- stitch ----------------------------------------------------------------

def test_stitch_single_top_level_call_and_shape():
    sql = render_stitch(_stitch())
    assert sql.count("stitch_incremental(") == 1
    assert emit.has_generated_header(sql)
    assert emit.generated_header("render_stitch") in sql
    assert sql.endswith(") }}\n") and not sql.endswith("\n\n")
    assert "\r" not in sql
    # never wrapped in another WITH, no join outside the macro
    assert not re.search(r"\bwith\b", sql, re.IGNORECASE)
    assert not re.search(r"\bjoin\b", sql, re.IGNORECASE)
    # final set closes with plain %}, then the call
    assert "} %}\n\n{{ stitch_incremental(" in sql
    assert "unique_key='parent_bk'," in sql
    assert "target_sat='sat_policy_bonus_tracking'" in sql


def test_stitch_sources_tags_watermarks_and_aliases():
    sql = render_stitch(_stitch())
    assert sql.count("'source_tag':") == 2
    assert "'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS'" in sql
    assert "'source_tag': 'OPUS_BJAZ_PA_DETL_EXTN'" in sql
    # per-table ldts_column kept as given (watermark_for result)
    assert "'ldts_column': 'inc_job_updated_at'" in sql
    assert "'ldts_column': 'rec_refresh_at'" in sql
    assert f"'model': '{A}',\n        'alias': 't0'," in sql
    assert f"'model': '{B}',\n        'alias': 't1'," in sql
    assert "{'src': 'coalesce(cum_bonus, cummulative_bonus)', 'tgt': 'bonusamount'}" in sql
    assert f"-- depends_on: {{{{ ref('{A}') }}}}" in sql
    assert f"-- depends_on: {{{{ ref('{B}') }}}}" in sql


def test_stitch_coalesce_rules_in_declared_order():
    sql = render_stitch(_stitch())
    assert ("{%- set output_columns = ['bonusamount', 'cumulativebonuspercentage'] -%}"
            in sql)
    assert "    'bonusamount': ['t1', 't0'],\n    'cumulativebonuspercentage': ['t0']\n} %}" in sql
    assert f"--   bonusamount: {B} > {A}" in sql


def test_stitch_is_deterministic():
    assert render_stitch(_stitch()) == render_stitch(_stitch())


@pytest.mark.parametrize("over, msg", [
    ({"record_source_prefix": None, "sources": [
        {"model": A, "source_tag": "OPUS_X", "ldts_column": "inc_job_updated_at",
         "key_column": "k", "columns": [{"src": "a", "tgt": "bonusamount"}]},
        {"model": B, "source_tag": "MAXIMUS_Y", "ldts_column": "inc_job_updated_at",
         "key_column": "k", "columns": [{"src": "b", "tgt": "bonusamount"}]}],
      "output_columns": ["bonusamount"],
      "coalesce_rules": {"bonusamount": [A, B]}}, "mixed source-system"),
    ({"record_source_prefix": "MAXIMUS_"}, "does not start with prefix"),
    ({"unique_key": "pk"}, "unique_key"),
    ({"coalesce_rules": {"bonusamount": [A], "cumulativebonuspercentage": [A]}},
     "sources providing it"),
    ({"coalesce_rules": {"bonusamount": [B, A]}}, "no coalesce rule"),
    ({"output_columns": ["bonusamount"]}, "not in output_columns"),
])
def test_stitch_rejects_contract_violations(over, msg):
    with pytest.raises(StitchRenderError, match=msg):
        render_stitch(_stitch(**over))


def test_stitch_rejects_quote_in_value():
    data = _stitch_data()
    data["sources"][0]["columns"][0]["src"] = "nvl(bonus_si, '0')"
    art = Artifact(kind="stitch", path="models/x/stitch_policy_bonus_tracking.sql",
                   name="stitch_policy_bonus_tracking", data=data)
    with pytest.raises(StitchRenderError, match="quote"):
        render_stitch(art)


def test_stitch_rejects_wrong_name_and_kind():
    art = Artifact(kind="stitch", path="models/x/stitch_other.sql",
                   name="stitch_other", data=_stitch_data())
    with pytest.raises(StitchRenderError, match="artifact name"):
        render_stitch(art)
    with pytest.raises(StitchRenderError, match="kind"):
        render_stitch(_stage())


# -- stage over the stitch ------------------------------------------------

def test_stitch_stage_model_name():
    assert stitch_stage_model("SAT_POLICY_HEADER") == "stg2_sat_stitch__policy_header"


def test_stitch_stage_shape():
    sql = render_stitch_stage(_stage())
    assert emit.has_generated_header(sql)
    assert sql.endswith("\n") and not sql.endswith("\n\n")
    assert "source_model: 'stitch_policy_bonus_tracking'" in sql
    assert "  POLICY_HKEY: 'PARENT_NK'\n" in sql
    assert ("    columns:\n      - 'BONUSAMOUNT'\n      - 'CUMULATIVEBONUSPERCENTAGE'\n"
            in sql)
    assert "  PARENT_NK: \"'HUB_POLICY|' || (PARENT_BK)\"\n" in sql
    # LOAD_DATETIME is the stitch's watermark output column, never a literal
    assert "  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'\n" in sql
    assert "LOAD_DATETIME: '!" not in sql
    # RECORD_SOURCE passes through from the stitch: no literal here
    assert "RECORD_SOURCE:" not in sql
    assert "include_source_columns=true" in sql
    assert "AS DBT_RUN_TS FROM columns_to_select" in sql
    assert render_stitch_stage(_stage()) == sql


@pytest.mark.parametrize("over, msg", [
    ({"source_model": "stitch_other"}, "source_model"),
    ({"hkey": "PARTY_HKEY"}, "hkey"),
    ({"load_datetime": "REC_REFRESH_AT"}, "load_datetime"),
    ({"source_tags": ["OPUS_A", "MAXIMUS_B"]}, "mixed source-system"),
    ({"payload": []}, "payload is empty"),
])
def test_stitch_stage_rejects_contract_violations(over, msg):
    with pytest.raises(StitchRenderError, match=msg):
        render_stitch_stage(_stage(**over))
