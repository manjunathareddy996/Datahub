{{ config(materialized='view') }}
-- This part feeds LNK_POLICY_PARTY only. Original precedence comments are kept below (from stitch_v12_coverage).
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
-- depends_on: {{ ref('stg_health__bjaz_grp_tpa_extn') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_dt_premium',
      'alias': 't0',
      'key_column': "user_id || '|' || contract_id",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_PREMIUM',
      'columns': [
        {'src': 'user_id', 'tgt': 'party_bk'},
        {'src': 'contract_id', 'tgt': 'policy_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_tpa_extn',
      'alias': 't1',
      'key_column': "tpa_code || '|' || contract_id",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_TPA_EXTN',
      'columns': [
        {'src': 'tpa_code', 'tgt': 'party_bk'},
        {'src': 'contract_id', 'tgt': 'policy_bk'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_bk',
    'policy_bk'
] -%}
{%- set coalesce_rules = {
    'party_bk': ['t0', 't1'],
    'policy_bk': ['t0', 't1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_party_lk',
    target_sat='lnk_policy_party'
) }}
