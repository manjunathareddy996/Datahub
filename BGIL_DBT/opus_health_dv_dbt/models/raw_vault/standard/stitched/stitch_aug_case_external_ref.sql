{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CASE_EXTERNAL_REF only. Original precedence comments are kept below (from stitch_v04_case).
-- CENTRAL VIEW v04_case -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_INWARD_OMNI_MAPPING (opus_health_v2)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CASE_EXTERNAL_REF
--   SAT_CASE_EXTERNAL_REF
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_inward_omni_mapping') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_inward_omni_mapping',
      'alias': 't0',
      'key_column': "nullif(trim(cashless_in_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_INWARD_OMNI_MAPPING',
      'columns': [
        {'src': 'redirect_flag', 'tgt': 'aug_case_external_ref__redirect_indicator'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_case_external_ref__redirect_indicator'
] -%}
{%- set coalesce_rules = {
    'aug_case_external_ref__redirect_indicator': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='case_bk',
    target_sat='sat_aug_case_external_ref'
) }}
