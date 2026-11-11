{{ config(materialized='view') }}
-- This part feeds SAT_AUG_RISK_HEALTH_MEMBER_COVERAGE only. Original precedence comments are kept below (from stitch_v33_quote).
-- CENTRAL VIEW v33_quote -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_GC_CONTROL (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1 (opus_health_v2)
--   BJAZ_HM_MEMBER_HLTH_DTLS (opus_health_v2)
--   BJAZ_ECARD_POL_DTLS_CONFIG (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_PARTY_ORGANISATION_PROFILE
--   SAT_AUG_POLICY_GROUP
--   SAT_AUG_POLICY_GROUP_DOCUMENT_CONTROL
--   SAT_AUG_PROPOSAL_HEADER
--   SAT_AUG_PROPOSAL_UNDERWRITING
--   SAT_AUG_QUOTE_HEADER
--   SAT_AUG_QUOTE_PREMIUM_RATE_AGE_BAND
--   SAT_AUG_QUOTE_PREMIUM_RATE_SLAB
--   SAT_AUG_QUOTE_RATING
--   SAT_AUG_RISK_HEALTH_MEMBER_COVERAGE
--   SAT_POLICY_DOC_CHECKLIST
--   SAT_QUOTE_RATING_INPUT
--   SAT_RISK_HEALTH_PED_WAITING
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_member_hlth_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't0',
      'key_column': "nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': 'hc_benefit_opted', 'tgt': 'aug_risk_health_member_coverage__benefit_option_code'},
        {'src': 'remark_enrollment', 'tgt': 'aug_risk_health_member_coverage__enrolment_remarks'},
        {'src': 'hc_waiting_period', 'tgt': 'aug_risk_health_member_coverage__health_cover_benefit_waiting_period'},
        {'src': 'ihg_waiting_period', 'tgt': 'aug_risk_health_member_coverage__individual_health_product_waiting_period'},
        {'src': 'medical_report', 'tgt': 'aug_risk_health_member_coverage__medical_report_received_indicator'},
        {'src': 'inception_date', 'tgt': 'aug_risk_health_member_coverage__member_cover_inception_date'},
        {'src': 'hc_rate_status', 'tgt': 'aug_risk_health_member_coverage__member_rating_status'},
        {'src': 'gmc_metro', 'tgt': 'aug_risk_health_member_coverage__metro_classification'},
        {'src': 'hc_hospital', 'tgt': 'aug_risk_health_member_coverage__network_hospital_reference'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_risk_health_member_coverage__benefit_option_code',
    'aug_risk_health_member_coverage__enrolment_remarks',
    'aug_risk_health_member_coverage__health_cover_benefit_waiting_period',
    'aug_risk_health_member_coverage__individual_health_product_waiting_period',
    'aug_risk_health_member_coverage__medical_report_received_indicator',
    'aug_risk_health_member_coverage__member_cover_inception_date',
    'aug_risk_health_member_coverage__member_rating_status',
    'aug_risk_health_member_coverage__metro_classification',
    'aug_risk_health_member_coverage__network_hospital_reference'
] -%}
{%- set coalesce_rules = {
    'aug_risk_health_member_coverage__benefit_option_code': ['t0'],
    'aug_risk_health_member_coverage__enrolment_remarks': ['t0'],
    'aug_risk_health_member_coverage__health_cover_benefit_waiting_period': ['t0'],
    'aug_risk_health_member_coverage__individual_health_product_waiting_period': ['t0'],
    'aug_risk_health_member_coverage__medical_report_received_indicator': ['t0'],
    'aug_risk_health_member_coverage__member_cover_inception_date': ['t0'],
    'aug_risk_health_member_coverage__member_rating_status': ['t0'],
    'aug_risk_health_member_coverage__metro_classification': ['t0'],
    'aug_risk_health_member_coverage__network_hospital_reference': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='risk_object_bk',
    target_sat='sat_aug_risk_health_member_coverage'
) }}
