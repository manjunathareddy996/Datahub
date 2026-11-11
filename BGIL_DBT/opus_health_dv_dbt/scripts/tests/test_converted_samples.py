"""Unit tests: sample converted models against hand-checked expectations.

Covers task 10.3 (Requirements 4.2, 4.3, 4.5, 4.7, 4.9, 4.11, 4.12).
Read-only: reads the written models, never modifies them.
"""
import re
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
STITCHED = ROOT / "models" / "raw_vault" / "standard" / "stitched"


def read(name):
    return (STITCHED / f"{name}.sql").read_text(encoding="utf-8")


def source_blocks(text):
    """Return list of dicts: model, alias, key_column, source_tag, ldts, columns[(src, tgt)]."""
    out = []
    for m in re.finditer(r"\{\s*\n\s*'model': '([^']+)',(.*?)\n    \}", text, re.S):
        body = m.group(2)
        g = lambda k: re.search(rf"'{k}': (?:'([^']*)'|\"([^\"]*)\")", body)
        def val(k):
            r = g(k)
            return r.group(1) if r.group(1) is not None else r.group(2)
        cols = re.findall(r"\{'src': (?:\"([^\"]*)\"|'([^']*)'), 'tgt': '([^']+)'\}", body)
        out.append({
            "model": m.group(1),
            "alias": val("alias"),
            "key_column": val("key_column"),
            "ldts": val("ldts_column"),
            "source_tag": val("source_tag"),
            "columns": [((a or b), c) for a, b, c in cols],
        })
    return out


def list_after(text, marker):
    m = re.search(rf"set {marker} = \[(.*?)\] ?-?%\}}", text, re.S)
    return re.findall(r"'([^']+)'", m.group(1))


def macro_args(text):
    assert text.count("stitch_incremental(") == 1
    return {
        "unique_key": re.search(r"unique_key='([^']+)'", text).group(1),
        "target_sat": re.search(r"target_sat='([^']+)'", text).group(1),
    }


def coalesce_rules(text):
    m = re.search(r"set coalesce_rules = \{(.*?)\} ?%\}", text, re.S)
    rules = {}
    for k, v in re.findall(r"'([^']+)': \[([^\]]*)\]", m.group(1)):
        rules[k] = re.findall(r"'(t\d+)'", v)
    return rules


def common_part_checks(text):
    assert text.startswith("{{ config(materialized='view') }}")
    assert "union all" not in text.lower()
    for tok in ("__PREC", "__RID", "first_value"):
        assert tok not in text
    for s in source_blocks(text):
        assert s["ldts"] == "inc_job_updated_at"
        assert re.fullmatch(r"OPUS_[A-Z0-9_]+", s["source_tag"])
        assert s["source_tag"] == "OPUS_" + s["model"].split("stg_health__", 1)[1].upper()


# ---------------- class A ----------------
def test_class_a_assessment_underwriting():
    t = read("stitch_assessment_underwriting")
    common_part_checks(t)
    s = source_blocks(t)
    assert [(x["model"], x["alias"], x["key_column"], x["source_tag"]) for x in s] == [
        ("stg_health__bjaz_enroll_scr_dtls", "t0", "nullif(trim(scrutiny_no),'')", "OPUS_BJAZ_ENROLL_SCR_DTLS"),
        ("stg_health__ba_hcp_prod_8432_ecp_loader", "t1", "pd_scrutiny_number", "OPUS_BA_HCP_PROD_8432_ECP_LOADER"),
        ("stg_health__bjaz_bandhan_medi_clam", "t2", "scrutiny_no", "OPUS_BJAZ_BANDHAN_MEDI_CLAM"),
    ]
    assert [x["columns"] for x in s] == [
        [("accpepted_si_by", "assessment_underwriting__risk_acceptance_authority")],
        [("md_spcl_condtn_member_level", "assessment_underwriting__special_conditions_recommended")],
        [("uw_remark", "assessment_underwriting__underwriting_remarks")],
    ]
    assert list_after(t, "output_columns") == [
        "assessment_underwriting__risk_acceptance_authority",
        "assessment_underwriting__special_conditions_recommended",
        "assessment_underwriting__underwriting_remarks",
    ]
    assert coalesce_rules(t) == {
        "assessment_underwriting__risk_acceptance_authority": ["t0"],
        "assessment_underwriting__special_conditions_recommended": ["t1"],
        "assessment_underwriting__underwriting_remarks": ["t2"],
    }
    assert macro_args(t) == {"unique_key": "assessment_bk", "target_sat": "sat_assessment_underwriting"}


# ---------------- class B ----------------
def test_class_b_fintxn_tax_cgst():
    t = read("stitch_fintxn_tax__cgst")
    common_part_checks(t)
    s = source_blocks(t)
    assert len(s) == 1
    assert s[0]["model"] == "stg_health__bjaz_health_webservice_info"
    assert s[0]["key_column"] == "ptransaction_id"
    assert s[0]["source_tag"] == "OPUS_BJAZ_HEALTH_WEBSERVICE_INFO"
    # literal child key becomes a {src, tgt} source column
    assert s[0]["columns"] == [
        ("central_gst", "fintxn_tax__cgst_amount"),
        ("'CGST'", "fintxn_tax__tax_type_ck"),
    ]
    assert list_after(t, "output_columns") == ["fintxn_tax__cgst_amount", "fintxn_tax__tax_type_ck"]
    assert coalesce_rules(t) == {
        "fintxn_tax__cgst_amount": ["t0"],
        "fintxn_tax__tax_type_ck": ["t0"],
    }
    assert macro_args(t) == {"unique_key": "financial_transaction_bk", "target_sat": "sat_fintxn_tax"}


# ---------------- class C ----------------
def test_class_c_policy_classification():
    t = read("stitch_policy_classification")
    common_part_checks(t)
    s = source_blocks(t)
    assert len(s) == 18
    assert [x["alias"] for x in s] == [f"t{i}" for i in range(18)]
    # mixed: data-driven branch first (t0), literal branches after
    assert s[0]["model"] == "stg_health__bjaz_ctngy_nr_bases_extn"
    assert s[0]["key_column"] == (
        "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(param_ref, '~')"
    )
    assert s[0]["columns"] == [
        ("nullif(trim(contract_id),'')", "policy_bk"),
        ("param_ref", "policy_classification__classification_type_ck"),
        ("param_ref", "policy_classification__classification_type"),
        ("param_value", "policy_classification__classification_value"),
    ]
    assert s[1]["model"] == "stg_health__bjaz_enroll_scr_dtls"
    assert s[1]["key_column"] == (
        "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'TRANSACTION_TYPE'"
    )
    assert s[1]["columns"][1] == ("'TRANSACTION_TYPE'", "policy_classification__classification_type_ck")
    assert s[1]["source_tag"] == "OPUS_BJAZ_ENROLL_SCR_DTLS"
    assert s[17]["model"] == "stg_health__bjaz_starpkg_pol_dtls"
    assert s[17]["source_tag"] == "OPUS_BJAZ_STARPKG_POL_DTLS"
    # every key_column uses the same '|' template and separator
    for x in s:
        assert x["key_column"].count(" || '|' || ") == 1
    # the key parts come back as Key_Part_Columns
    assert list_after(t, "output_columns") == [
        "policy_bk",
        "policy_classification__classification_type_ck",
        "policy_classification__classification_type",
        "policy_classification__classification_value",
    ]
    all_t = [f"t{i}" for i in range(18)]
    r = coalesce_rules(t)
    assert list(r) == list_after(t, "output_columns")
    assert r["policy_bk"] == all_t
    assert r["policy_classification__classification_type_ck"] == all_t
    assert r["policy_classification__classification_value"] == all_t
    assert r["policy_classification__classification_type"] == ["t0"]
    assert macro_args(t) == {
        "unique_key": "policy_classification_pk",
        "target_sat": "sat_policy_classification",
    }


# ---------------- link ----------------
def test_link_agreement_channel_v01():
    t = read("stitch_lk_agreement_channel__v01")
    common_part_checks(t)
    s = source_blocks(t)
    assert len(s) == 1
    assert s[0]["model"] == "stg_health__bjaz_hm_hospital_master_extn"
    assert s[0]["key_column"] == "hosid || '|' || distribution_partner"
    assert s[0]["source_tag"] == "OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN"
    assert s[0]["columns"] == [
        ("hosid", "agreement_bk"),
        ("distribution_partner", "distribution_channel_bk"),
    ]
    assert list_after(t, "output_columns") == ["agreement_bk", "distribution_channel_bk"]
    assert coalesce_rules(t) == {"agreement_bk": ["t0"], "distribution_channel_bk": ["t0"]}
    assert macro_args(t) == {"unique_key": "agreement_channel_lk", "target_sat": "lnk_agreement_channel"}


# ---------------- consumer view ----------------
def test_consumer_view_v22_policy():
    t = read("stitch_v22_policy")
    assert "stitch_incremental(" not in t
    assert t.lstrip().startswith("{{ config(materialized='view') }}")
    # original header comments are kept
    assert "-- CENTRAL VIEW v22_policy" in t
    expected_cols = [
        "ASSESSMENT_BK",
        "POLICY_BK",
        "ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY",
        "ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED",
        "ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS",
        "AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE",
        "AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE",
        "AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION",
        "POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK",
        "POLICY_CLASSIFICATION__CLASSIFICATION_TYPE",
        "POLICY_CLASSIFICATION__CLASSIFICATION_VALUE",
    ]
    body = t[t.index("\nselect"):]
    branches = re.split(r"\n\s*union all\s*\n", body)
    assert [re.findall(r"from \{\{ ref\('([^']+)'\) \}\}", b)[0] for b in branches] == [
        "stitch_assessment_underwriting",
        "stitch_aug_policy_classification",
        "stitch_aug_policy_contingency_scheme",
        "stitch_policy_classification",
    ]
    for b in branches:
        assert re.findall(r" as ([A-Z_]+),?\n", b + "\n") == expected_cols
    # BK legs come from the owning part's Key_Part_Column; others are null padded
    b0, b1, b2, b3 = branches
    assert "assessment_bk as ASSESSMENT_BK" in b0
    assert "cast(null as varchar) as POLICY_BK" in b0
    for b in (b1, b2, b3):
        assert "cast(null as varchar) as ASSESSMENT_BK" in b
        assert "policy_bk as POLICY_BK" in b
    # payload comes from the single owner part
    assert "assessment_underwriting__underwriting_remarks as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS" in b0
    assert "aug_policy_classification__classification_type_code as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE" in b1
    assert "aug_policy_contingency_scheme__scheme_version as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION" in b2
    assert "policy_classification__classification_type_ck as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK" in b3
    # every referenced part exists
    for name in re.findall(r"ref\('([^']+)'\)", t):
        assert (STITCHED / f"{name}.sql").exists()
