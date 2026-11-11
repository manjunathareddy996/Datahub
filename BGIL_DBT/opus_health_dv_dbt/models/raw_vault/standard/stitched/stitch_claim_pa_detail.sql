{{ config(materialized='view') }}
-- This part feeds SAT_CLAIM_PA_DETAIL only. Original precedence comments are kept below (from stitch_v08_claim).
-- CENTRAL VIEW v08_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HAT_DISC_SUMMARY_LST (opus_health_v2)
--   BJAZ_HAT_NON_PAYABLE_LST (opus_health_v2)
--   BJAZ_HAT_OCR_FINA_PERTICULARS (opus_health_v2)
--   BJAZ_HAT_RETURN_SUMMARY_LST (opus_health_v2)
--   BJAZ_HM_GPA_BILL_DTLS (opus_health_v2)
--   BJAZ_HM_BILL_CHARGE (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL_OCR (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_BILL_LINE
--   SAT_AUG_CLAIM_PROVIDER_BILLING
--   SAT_CLAIM_PA_DETAIL
--   SAT_CLAIM_PROVIDER_BILLING
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_gpa_bill_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': 'ptd_percentage', 'tgt': 'claim_pa_detail__disability_percentage'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_pa_detail__disability_percentage'
] -%}
{%- set coalesce_rules = {
    'claim_pa_detail__disability_percentage': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_claim_pa_detail'
) }}
