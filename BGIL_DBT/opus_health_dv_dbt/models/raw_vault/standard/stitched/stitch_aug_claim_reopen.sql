{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_REOPEN only. Original precedence comments are kept below (from stitch_v07_claim).
-- CENTRAL VIEW v07_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_CLAIM_CLOSE (opus_health_v2)
--   BJAZ_HM_CLAIM_REOPEN (opus_health_v2)
--   BJAZ_HM_CLAIM_TRACKER (opus_health_v2)
--   BJAZ_HM_GPA_BILL_DTLS (opus_health_v2)
--   BJAZ_HM_HCS_TECH_ASSESS_COV (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_HAT_OCR_FINA_DTLS_LST (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_RISK_TRANS_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_BENEFIT_HEAD
--   SAT_AUG_CLAIM_REOPEN
--   SAT_CLAIM_BENEFIT_HEAD
--   SAT_CLAIM_HEADER
--   SAT_CLAIM_REPUDIATION
--   SAT_CLAIM_SETTLEMENT
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_claim_reopen') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_claim_reopen',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_CLAIM_REOPEN',
      'columns': [
        {'src': 'updated_by', 'tgt': 'aug_claim_reopen__reopened_by_user_reference'},
        {'src': 'coalesce(reopen_date, updated_on)', 'tgt': 'aug_claim_reopen__reopen_date'},
        {'src': 'reopen_remark', 'tgt': 'aug_claim_reopen__reopen_reason'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_claim_reopen__reopened_by_user_reference',
    'aug_claim_reopen__reopen_date',
    'aug_claim_reopen__reopen_reason'
] -%}
{%- set coalesce_rules = {
    'aug_claim_reopen__reopened_by_user_reference': ['t0'],
    'aug_claim_reopen__reopen_date': ['t0'],
    'aug_claim_reopen__reopen_reason': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_aug_claim_reopen'
) }}
