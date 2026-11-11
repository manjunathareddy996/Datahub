{{ config(materialized='view') }}
-- This part feeds SAT_AUG_COVERAGE_DEFINITION only. Original precedence comments are kept below (from stitch_v12_coverage).
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
-- depends_on: {{ ref('stg_health__ba_hcp_dt_premium') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_cover_mst') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_dt_premium',
      'alias': 't0',
      'key_column': 'hcp_seqno',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_PREMIUM',
      'columns': [
        {'src': 'self_covered_flag', 'tgt': 'aug_coverage_definition__self_covered_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_cover_mst',
      'alias': 't1',
      'key_column': "nullif(trim(cover_code),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_COVER_MST',
      'columns': [
        {'src': 'disp_order', 'tgt': 'aug_coverage_definition__catalogue_display_order'},
        {'src': 'checkbox_yn', 'tgt': 'aug_coverage_definition__independently_selectable_indicator'},
        {'src': 'rating_flag', 'tgt': 'aug_coverage_definition__rating_participation_indicator'},
        {'src': 'section_id', 'tgt': 'aug_coverage_definition__section_reference'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_coverage_definition__self_covered_indicator',
    'aug_coverage_definition__catalogue_display_order',
    'aug_coverage_definition__independently_selectable_indicator',
    'aug_coverage_definition__rating_participation_indicator',
    'aug_coverage_definition__section_reference'
] -%}
{%- set coalesce_rules = {
    'aug_coverage_definition__self_covered_indicator': ['t0'],
    'aug_coverage_definition__catalogue_display_order': ['t1'],
    'aug_coverage_definition__independently_selectable_indicator': ['t1'],
    'aug_coverage_definition__rating_participation_indicator': ['t1'],
    'aug_coverage_definition__section_reference': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='coverage_bk',
    target_sat='sat_aug_coverage_definition'
) }}
