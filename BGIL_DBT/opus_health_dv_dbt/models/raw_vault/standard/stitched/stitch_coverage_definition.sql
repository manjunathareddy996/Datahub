{{ config(materialized='view') }}
-- This part feeds SAT_COVERAGE_DEFINITION only. Original precedence comments are kept below (from stitch_v12_coverage).
-- CENTRAL VIEW v12_coverage -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_DT_PREMIUM (opus_health_legacy_v4)
--   BJAZ_GRP_TPA_EXTN (opus_health_legacy_v4)
--   BJAZ_STARPKG_COVER_MST (opus_health_delta3)
--   BJAZ_STARPKG_COV_PREM_MST (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_COVERAGE_DEFINITION
--   SAT_AUG_COVERAGE_PARAMETER
--   SAT_AUG_COVERAGE_PREMIUM_RATE_SLAB
--   SAT_COVERAGE_DEFINITION
--   SAT_POLICY_INSTALMENT_SCHEDULE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_PRODUCT_COVERAGE
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_starpkg_cover_mst') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_starpkg_cover_mst',
      'alias': 't0',
      'key_column': "nullif(trim(cover_code),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_COVER_MST',
      'columns': [
        {'src': 'cover_desc', 'tgt': 'coverage_definition__coverage_description'}
      ]
    }
] -%}
{%- set output_columns = [
    'coverage_definition__coverage_description'
] -%}
{%- set coalesce_rules = {
    'coverage_definition__coverage_description': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='coverage_bk',
    target_sat='sat_coverage_definition'
) }}
