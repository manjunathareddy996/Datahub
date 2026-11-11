{{ config(materialized='view') }}
-- This part feeds SAT_CLAIM_REPUDIATION only. Original precedence comments are kept below (from stitch_v07_claim).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_hcs_tech_assess_cov') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_pro_assessment') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': 'repud_date', 'tgt': 'claim_repudiation__repudiation_date'},
        {'src': 'repud_remarks', 'tgt': 'claim_repudiation__repudiation_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't1',
      'key_column': 'clid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'repudiation_dt', 'tgt': 'claim_repudiation__repudiation_date'},
        {'src': 'repudiation_reason', 'tgt': 'claim_repudiation__repudiation_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_pro_assessment',
      'alias': 't2',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PRO_ASSESSMENT',
      'columns': [
        {'src': 'repudi_date', 'tgt': 'claim_repudiation__repudiation_date'},
        {'src': 'repudi_remark', 'tgt': 'claim_repudiation__repudiation_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't3',
      'key_column': 'bjaz_claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'rejection_reason', 'tgt': 'claim_repudiation__repudiation_reason'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_repudiation__repudiation_date',
    'claim_repudiation__repudiation_reason'
] -%}
{%- set coalesce_rules = {
    'claim_repudiation__repudiation_date': ['t0', 't1', 't2'],
    'claim_repudiation__repudiation_reason': ['t0', 't1', 't2', 't3']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_claim_repudiation'
) }}
