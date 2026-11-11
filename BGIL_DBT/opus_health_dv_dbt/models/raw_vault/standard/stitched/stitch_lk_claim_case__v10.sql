{{ config(materialized='view') }}
-- This part feeds LNK_CLAIM_CASE only. Original precedence comments are kept below (from stitch_v10_claim).
-- CENTRAL VIEW v10_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_GPA_BILL_DTLS (opus_health_v2)
--   BJAZ_HM_HCS_TECH_ASSESS_COV (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_HM_BILL_DETAIL (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL_OCR (opus_health_legacy_v4)
--   BJAZ_HM_CASHLESS_INWARD (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_DOCTOR_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_DOCTOR_MULTI_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_AUTOALLOCATION (opus_health_legacy_v4)
--   BJAZ_HM_PREAUTH_ENHANCE (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_REMEDINET_PATIENT_DETAILS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_HEALTH_DETAIL
--   SAT_AUG_CLAIM_TPA_INTERACTION
--   SAT_CLAIM_HEALTH_DETAIL
--   SAT_CLAIM_TPA_INTERACTION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CASE_DOCUMENT
--   LNK_CASE_PARTY
--   LNK_CLAIM_CASE
--   LNK_CLAIM_DOCUMENT
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_POLICY
--   LNK_PARTY_DOCUMENT
--   LNK_POLICY_PARTY
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_preauth_enhance') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_preauth_enhance',
      'alias': 't0',
      'key_column': "enhance_ref_id || '|' || clid",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_ENHANCE',
      'columns': [
        {'src': 'enhance_ref_id', 'tgt': 'case_bk'},
        {'src': 'clid', 'tgt': 'claim_bk'}
      ]
    }
] -%}
{%- set output_columns = [
    'case_bk',
    'claim_bk'
] -%}
{%- set coalesce_rules = {
    'case_bk': ['t0'],
    'claim_bk': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_case_lk',
    target_sat='lnk_claim_case'
) }}
