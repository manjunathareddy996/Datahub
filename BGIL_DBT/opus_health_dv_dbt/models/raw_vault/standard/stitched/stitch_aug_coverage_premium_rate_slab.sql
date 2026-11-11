{{ config(materialized='view') }}
-- This part feeds SAT_AUG_COVERAGE_PREMIUM_RATE_SLAB only. Original precedence comments are kept below (from stitch_v12_coverage).
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
-- depends_on: {{ ref('stg_health__bjaz_starpkg_cov_prem_mst') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_starpkg_cov_prem_mst',
      'alias': 't0',
      'key_column': "nullif(trim(cover_code),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_COV_PREM_MST',
      'columns': [
        {'src': 'age_limit', 'tgt': 'aug_coverage_premium_rate_slab__age_limit_band'},
        {'src': 'sr_no', 'tgt': 'aug_coverage_premium_rate_slab__line_sequence_number'},
        {'src': 'plan_code', 'tgt': 'aug_coverage_premium_rate_slab__plan_reference'},
        {'src': 'prem_flag', 'tgt': 'aug_coverage_premium_rate_slab__premium_applicability_basis'},
        {'src': 'eff_date', 'tgt': 'aug_coverage_premium_rate_slab__rate_effective_date'},
        {'src': 'section_id', 'tgt': 'aug_coverage_premium_rate_slab__section_reference'},
        {'src': 'premium', 'tgt': 'aug_coverage_premium_rate_slab__slab_premium_rate'},
        {'src': 'total_si', 'tgt': 'aug_coverage_premium_rate_slab__sum_insured_slab_amount'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_coverage_premium_rate_slab__age_limit_band',
    'aug_coverage_premium_rate_slab__line_sequence_number',
    'aug_coverage_premium_rate_slab__plan_reference',
    'aug_coverage_premium_rate_slab__premium_applicability_basis',
    'aug_coverage_premium_rate_slab__rate_effective_date',
    'aug_coverage_premium_rate_slab__section_reference',
    'aug_coverage_premium_rate_slab__slab_premium_rate',
    'aug_coverage_premium_rate_slab__sum_insured_slab_amount'
] -%}
{%- set coalesce_rules = {
    'aug_coverage_premium_rate_slab__age_limit_band': ['t0'],
    'aug_coverage_premium_rate_slab__line_sequence_number': ['t0'],
    'aug_coverage_premium_rate_slab__plan_reference': ['t0'],
    'aug_coverage_premium_rate_slab__premium_applicability_basis': ['t0'],
    'aug_coverage_premium_rate_slab__rate_effective_date': ['t0'],
    'aug_coverage_premium_rate_slab__section_reference': ['t0'],
    'aug_coverage_premium_rate_slab__slab_premium_rate': ['t0'],
    'aug_coverage_premium_rate_slab__sum_insured_slab_amount': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='coverage_bk',
    target_sat='sat_aug_coverage_premium_rate_slab'
) }}
