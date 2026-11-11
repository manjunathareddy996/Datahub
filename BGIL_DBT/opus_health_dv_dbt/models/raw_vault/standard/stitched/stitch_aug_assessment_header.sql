{{ config(materialized='view') }}
-- This part feeds SAT_AUG_ASSESSMENT_HEADER only. Original precedence comments are kept below (from stitch_v03_assessment).
-- CENTRAL VIEW v03_assessment -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PP_MEM_DTLS (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_HM_DOCTOR_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_DOCTOR_MULTI_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_PCS_MULTI_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
--   BJAZ_RISK_IDENTIFIERS_MASTER (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_MEDICAL
--   SAT_AUG_ASSESSMENT_HEADER
--   SAT_AUG_ASSESSMENT_MEDICAL
--   SAT_AUG_ASSESSMENT_RISK_RULE_DEFINITION
--   SAT_RISK_PERSON_MEMBER
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_ASSESSMENT_PARTY
--   LNK_CHANNEL_ORG_UNIT
--   LNK_CLAIM_ASSESSMENT
--   LNK_CLAIM_COVERAGE
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_ORG_UNIT
--   LNK_PARTY_ROLE
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PROPOSAL_ASSESSMENT
--   LNK_PROPOSAL_PARTY
--   LNK_PROPOSAL_POLICY
--   LNK_RISK_OBJECT_ASSESSMENT
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_pp_mem_dtls',
      'alias': 't0',
      'key_column': 'scrutiny_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PP_MEM_DTLS',
      'columns': [
        {'src': 'sub_status_code', 'tgt': 'aug_assessment_header__assessment_sub_status_code'},
        {'src': 'sub_status_desc', 'tgt': 'aug_assessment_header__assessment_sub_status_description'},
        {'src': 'reschedule_date', 'tgt': 'aug_assessment_header__rescheduled_date'},
        {'src': 'reschedule_time', 'tgt': 'aug_assessment_header__rescheduled_time'},
        {'src': 'app_time', 'tgt': 'aug_assessment_header__scheduled_time'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_assessment_header__assessment_sub_status_code',
    'aug_assessment_header__assessment_sub_status_description',
    'aug_assessment_header__rescheduled_date',
    'aug_assessment_header__rescheduled_time',
    'aug_assessment_header__scheduled_time'
] -%}
{%- set coalesce_rules = {
    'aug_assessment_header__assessment_sub_status_code': ['t0'],
    'aug_assessment_header__assessment_sub_status_description': ['t0'],
    'aug_assessment_header__rescheduled_date': ['t0'],
    'aug_assessment_header__rescheduled_time': ['t0'],
    'aug_assessment_header__scheduled_time': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='assessment_bk',
    target_sat='sat_aug_assessment_header'
) }}
