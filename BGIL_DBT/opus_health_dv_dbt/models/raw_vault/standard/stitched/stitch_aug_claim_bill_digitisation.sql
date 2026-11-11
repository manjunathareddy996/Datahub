{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_BILL_DIGITISATION only. Original precedence comments are kept below (from stitch_v06_claim).
-- CENTRAL VIEW v06_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_BFHL_DTLS (opus_health_v2)
--   BJAZ_HM_CLAIM_CONVERSION (opus_health_v2)
--   BJAZ_HM_ORPHAN_FOLLOW_DTLS (opus_health_v2)
--   BJAZ_HAT_OCR_BILL_DETAILS (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL_OCR (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_HM_QUERY_REMARK (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_ANOMALY_DETECTION
--   SAT_AUG_CLAIM_BILL_DIGITISATION
--   SAT_AUG_CLAIM_CONVERSION_EVENT
--   SAT_AUG_CLAIM_FOLLOW_UP_CHASE
--   SAT_CLAIM_BILL_DIGITISATION
--   SAT_CLAIM_NOTE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_LOCATION
--   LNK_CLAIM_POLICY
--   LNK_POLICY_LOCATION
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_bill_detail_ocr') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_bill_detail_ocr',
      'alias': 't0',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_BILL_DETAIL_OCR',
      'columns': [
        {'src': 'add_status', 'tgt': 'aug_claim_bill_digitisation__addendum_status'},
        {'src': 'ref_bill_id', 'tgt': 'aug_claim_bill_digitisation__referenced_bill_reference'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_claim_bill_digitisation__addendum_status',
    'aug_claim_bill_digitisation__referenced_bill_reference'
] -%}
{%- set coalesce_rules = {
    'aug_claim_bill_digitisation__addendum_status': ['t0'],
    'aug_claim_bill_digitisation__referenced_bill_reference': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_aug_claim_bill_digitisation'
) }}
