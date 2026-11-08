"""Unit tests for dvgen.naming, checked against Template_Project names."""
from __future__ import annotations

import pytest

from dvgen.naming import (
    NamingError, bridge_model, ck_column, hkey, hub_model, link_model,
    payload_column, record_source, ref_model, sat_model, source_tag,
    stg1_model, stg2_model, stitch_model, watermark_for,
)


def test_hkey_matches_template():
    assert hkey("HUB_LOCATION") == "LOCATION_HKEY"
    assert hkey("HUB_CLAIM") == "CLAIM_HKEY"
    assert hkey("LNK_POLICY_PARTY") == "POLICY_PARTY_HKEY"
    assert hkey("lnk_claim_party") == "CLAIM_PARTY_HKEY"


@pytest.mark.parametrize("bad", ["SAT_CLAIM", "CLAIM", "HUB_", "", "  "])
def test_hkey_rejects_non_hub_link_codes(bad):
    with pytest.raises(NamingError):
        hkey(bad)


def test_vault_model_names():
    assert hub_model("HUB_CLAIM") == "hub_claim"
    assert link_model("LNK_CLAIM_POLICY") == "lnk_claim_policy"
    assert link_model("LNK_POLICY_PARTY") == "lnk_policy_party"
    assert sat_model("SAT_CLAIM_BENEFIT_HEAD", "standard") == "sat_claim_benefit_head"
    assert sat_model("SAT_CLAIM_BENEFIT_HEAD", "augmented") == "sat_aug_claim_benefit_head"
    assert sat_model("SAT_LOCATION", "augmented") == "sat_aug_location"
    assert ref_model("REF_BANK_BRANCH_IFSC") == "ref_bank_branch_ifsc"


def test_sat_model_rejects_other_tracks():
    with pytest.raises(NamingError):
        sat_model("SAT_X", "reference")


def test_staging_model_names_match_template():
    assert stg1_model("bjaz_hm_gpa_bill_dtls") == "stg_health__bjaz_hm_gpa_bill_dtls"
    assert stg2_model("hub", "clm_suppliers", "HUB_LOCATION") == "stg2_hub_clm_suppliers__location"
    assert (stg2_model("link", "bjaz_hm_member_dtls", "LNK_POLICY_PARTY")
            == "stg2_link_bjaz_hm_member_dtls__policy_party")
    assert (stg2_model("sat", "azbj_partner_extn", "SAT_COMMON_CONTACT")
            == "stg2_sat_azbj_partner_extn__common_contact")
    assert (stg2_model("sat", "t", "SAT_X", branch="Permanent")
            == "stg2_sat_t__x__permanent")
    assert stg2_model("aug", "cp_partners", "SAT_LOCATION") == "stg2_aug_cp_partners__location"
    # An augmented satellite model name reduces to the same target.
    assert stg2_model("aug", "cp_partners", "sat_aug_location") == "stg2_aug_cp_partners__location"


def test_stg2_model_rejects_bad_kind_and_hub_branch():
    with pytest.raises(NamingError):
        stg2_model("ref", "t", "REF_X")
    with pytest.raises(NamingError):
        stg2_model("hub", "t", "HUB_X", branch="b")


def test_bridge_and_stitch_names():
    assert bridge_model("claim_note", "HUB_CLAIM") == "bridge_claim_note__claim"
    assert stitch_model("SAT_COMMON_ADDRESS") == "stitch_common_address"
    assert stitch_model("sat_common_address") == "stitch_common_address"


def test_payload_and_childkey_columns():
    assert payload_column("Alternate Email Address") == "ALTERNATEEMAILADDRESS"
    assert payload_column("Room_Rent-Amt (INR)") == "ROOMRENTAMTINR"
    assert ck_column("Benefit Head Code") == "BENEFITHEADCODE"
    with pytest.raises(NamingError):
        payload_column(" _-")


def test_record_source_and_source_tag():
    assert record_source("OPUS_", "bjaz_hm_gpa_bill_dtls") == "!OPUS_BJAZ_HM_GPA_BILL_DTLS"
    assert record_source("MAXIMUS_", "CLAIM_HDR") == "!MAXIMUS_CLAIM_HDR"
    assert source_tag("OPUS_PARTNER_", "AZBJ_PARTNER_EXTN") == "OPUS_PARTNER_AZBJ_PARTNER_EXTN"
    assert record_source("OPUS_", "T") == "!" + source_tag("OPUS_", "T")


def test_watermark_for_override_else_default():
    overrides = {"CLAIM_HDR": "rec_refresh_at"}
    assert watermark_for("claim_hdr", "inc_job_updated_at", overrides) == "rec_refresh_at"
    assert watermark_for("OTHER", "inc_job_updated_at", overrides) == "inc_job_updated_at"
    assert watermark_for("CLAIM_HDR", "inc_job_updated_at", {}) == "inc_job_updated_at"


def test_names_do_not_depend_on_project():
    # Only record_source and source_tag take a project prefix.
    import inspect
    import dvgen.naming as naming

    for name in naming.__all__:
        fn = getattr(naming, name)
        if not inspect.isfunction(fn):
            continue
        params = set(inspect.signature(fn).parameters)
        assert "project" not in params, name
        if name not in ("record_source", "source_tag"):
            assert "prefix" not in params, name
