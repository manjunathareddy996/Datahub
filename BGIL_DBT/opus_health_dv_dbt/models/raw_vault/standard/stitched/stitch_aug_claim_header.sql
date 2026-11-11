{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_HEADER only. Original precedence comments are kept below (from stitch_v05_claim).
-- CENTRAL VIEW v05_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_CLAIM_CLOSE (opus_health_v2)
--   BJAZ_HM_HCS_TECH_ASSESS_COV (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_AUTOALLOCATION (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_HM_PREAUTH_QUERY (opus_health_legacy_v4)
--   BJAZ_RISK_TRANS_DTLS (opus_health_delta3)
--   NG_FAX_INWARD_DETAILS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CASE_HEADER
--   SAT_AUG_CLAIM_COVER_SECTION_ASSESSMENT
--   SAT_AUG_CLAIM_DISABILITY_HEAD
--   SAT_AUG_CLAIM_HEADER
--   SAT_AUG_CLAIM_HOSPITAL_DAY_LIMIT
--   SAT_AUG_CLAIM_PA_DETAIL
--   SAT_AUG_CLAIM_QUALITY_AUDIT
--   SAT_AUG_CLAIM_SLA_TRACKING
--   SAT_AUG_CLAIM_TRANSPORT_LEG
--   SAT_CASE_HEADER
--   SAT_CLAIM_RESERVE_HEAD
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CASE_DOCUMENT
--   LNK_CASE_PARTY
--   LNK_CLAIM_CASE
--   LNK_CLAIM_DOCUMENT
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_POLICY
--   LNK_CLAIM_RISK_OBJECT
--   LNK_PARTY_DOCUMENT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_claim_close') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcs_tech_assess_cov') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_preauth_request') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_inward_autoallocation') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_orphan_reg') }}
-- depends_on: {{ ref('stg_health__bjaz_risk_trans_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_claim_close',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_CLAIM_CLOSE',
      'columns': [
        {'src': 'updated_by', 'tgt': 'aug_claim_header__closed_by_user_reference'},
        {'src': 'approval_date', 'tgt': 'aug_claim_header__closure_approval_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't1',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': 'inward_id', 'tgt': 'aug_claim_header__inward_registration_reference'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_preauth_request',
      'alias': 't2',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_REQUEST',
      'columns': [
        {'src': 'clid_hpms', 'tgt': 'aug_claim_header__external_claim_reference'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_coinsu_clm_dtls',
      'alias': 't3',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_COINSU_CLM_DTLS',
      'columns': [
        {'src': 'reeported_amt', 'tgt': 'aug_claim_header__reported_claim_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't4',
      'key_column': 'clid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'orphan_claimno', 'tgt': 'aug_claim_header__orphan_claim_number'},
        {'src': 'orphan_intimation_dt', 'tgt': 'aug_claim_header__orphan_intimation_date'},
        {'src': 'orphan_remark', 'tgt': 'aug_claim_header__orphan_remark'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_inward_autoallocation',
      'alias': 't5',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_INWARD_AUTOALLOCATION',
      'columns': [
        {'src': 'omni_inward_no', 'tgt': 'aug_claim_header__omni_inward_reference'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_orphan_reg',
      'alias': 't6',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_ORPHAN_REG',
      'columns': [
        {'src': 'orphan_close_yn', 'tgt': 'aug_claim_header__claim_closed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_risk_trans_dtls',
      'alias': 't7',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_RISK_TRANS_DTLS',
      'columns': [
        {'src': 'clid_hpms', 'tgt': 'aug_claim_header__external_claim_reference'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_claim_header__closed_by_user_reference',
    'aug_claim_header__closure_approval_date',
    'aug_claim_header__inward_registration_reference',
    'aug_claim_header__external_claim_reference',
    'aug_claim_header__reported_claim_amount',
    'aug_claim_header__orphan_claim_number',
    'aug_claim_header__orphan_intimation_date',
    'aug_claim_header__orphan_remark',
    'aug_claim_header__omni_inward_reference',
    'aug_claim_header__claim_closed_indicator'
] -%}
{%- set coalesce_rules = {
    'aug_claim_header__closed_by_user_reference': ['t0'],
    'aug_claim_header__closure_approval_date': ['t0'],
    'aug_claim_header__inward_registration_reference': ['t1'],
    'aug_claim_header__external_claim_reference': ['t2', 't7'],
    'aug_claim_header__reported_claim_amount': ['t3'],
    'aug_claim_header__orphan_claim_number': ['t4'],
    'aug_claim_header__orphan_intimation_date': ['t4'],
    'aug_claim_header__orphan_remark': ['t4'],
    'aug_claim_header__omni_inward_reference': ['t5'],
    'aug_claim_header__claim_closed_indicator': ['t6']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_aug_claim_header'
) }}
