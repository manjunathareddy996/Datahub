{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_CONVERSION_EVENT only. Original precedence comments are kept below (from stitch_v06_claim).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_claim_conversion') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_claim_conversion',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(conv_id, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_CLAIM_CONVERSION',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'conv_id', 'tgt': 'aug_claim_conversion_event__conversion_reference_ck'},
        {'src': 'coalesce(convert_date, updated_on)', 'tgt': 'aug_claim_conversion_event__conversion_date'},
        {'src': 'conv_id', 'tgt': 'aug_claim_conversion_event__conversion_reference'},
        {'src': 'conv_type', 'tgt': 'aug_claim_conversion_event__conversion_type_code'},
        {'src': 'updated_by', 'tgt': 'aug_claim_conversion_event__converted_by_user_identifier'},
        {'src': 'prev_claim_id', 'tgt': 'aug_claim_conversion_event__superseded_claim_reference'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_bk',
    'aug_claim_conversion_event__conversion_reference_ck',
    'aug_claim_conversion_event__conversion_date',
    'aug_claim_conversion_event__conversion_reference',
    'aug_claim_conversion_event__conversion_type_code',
    'aug_claim_conversion_event__converted_by_user_identifier',
    'aug_claim_conversion_event__superseded_claim_reference'
] -%}
{%- set coalesce_rules = {
    'claim_bk': ['t0'],
    'aug_claim_conversion_event__conversion_reference_ck': ['t0'],
    'aug_claim_conversion_event__conversion_date': ['t0'],
    'aug_claim_conversion_event__conversion_reference': ['t0'],
    'aug_claim_conversion_event__conversion_type_code': ['t0'],
    'aug_claim_conversion_event__converted_by_user_identifier': ['t0'],
    'aug_claim_conversion_event__superseded_claim_reference': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='aug_claim_conversion_event_pk',
    target_sat='sat_aug_claim_conversion_event'
) }}
