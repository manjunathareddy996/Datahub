{{ config(materialized='view') }}
-- This part feeds SAT_CLAIM_NOTE only. Original precedence comments are kept below (from stitch_v06_claim).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_bill_detail') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_orphan_reg') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_query_remark') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_bill_detail',
      'alias': 't0',
      'key_column': "claim_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_BILL_DETAIL',
      'columns': [
        {'src': 'claim_id', 'tgt': 'claim_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'claim_note__note_sequence_ck'},
        {'src': 'genral_remarks', 'tgt': 'claim_note__note_text'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_orphan_reg',
      'alias': 't1',
      'key_column': "claim_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_ORPHAN_REG',
      'columns': [
        {'src': 'claim_id', 'tgt': 'claim_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'claim_note__note_sequence_ck'},
        {'src': 'orphan_follow_flag', 'tgt': 'claim_note__follow_up_required_indicator'},
        {'src': 'orphan_close_remark', 'tgt': 'claim_note__note_text'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_query_remark',
      'alias': 't2',
      'key_column': "claim_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_QUERY_REMARK',
      'columns': [
        {'src': 'claim_id', 'tgt': 'claim_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'claim_note__note_sequence_ck'},
        {'src': 'query_remark', 'tgt': 'claim_note__note_text'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_bk',
    'claim_note__note_sequence_ck',
    'claim_note__note_text',
    'claim_note__follow_up_required_indicator'
] -%}
{%- set coalesce_rules = {
    'claim_bk': ['t0', 't1', 't2'],
    'claim_note__note_sequence_ck': ['t0', 't1', 't2'],
    'claim_note__note_text': ['t0', 't1', 't2'],
    'claim_note__follow_up_required_indicator': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_note_pk',
    target_sat='sat_claim_note'
) }}
