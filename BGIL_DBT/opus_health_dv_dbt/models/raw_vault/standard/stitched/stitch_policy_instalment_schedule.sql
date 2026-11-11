{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_INSTALMENT_SCHEDULE only. Original precedence comments are kept below (from stitch_v12_coverage).
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

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_dt_premium',
      'alias': 't0',
      'key_column': "contract_id || '|' || coalesce(inst_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_PREMIUM',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'inst_no', 'tgt': 'policy_instalment_schedule__instalment_number_ck'},
        {'src': 'inst_date', 'tgt': 'policy_instalment_schedule__due_date'},
        {'src': 'next_inst_amt', 'tgt': 'policy_instalment_schedule__instalment_amount'},
        {'src': 'inst_no', 'tgt': 'policy_instalment_schedule__instalment_number'},
        {'src': 'inst_total_pending_amt', 'tgt': 'policy_instalment_schedule__outstanding_after_instalment'},
        {'src': 'inst_paid_amt', 'tgt': 'policy_instalment_schedule__paid_amount'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'policy_instalment_schedule__instalment_number_ck',
    'policy_instalment_schedule__due_date',
    'policy_instalment_schedule__instalment_amount',
    'policy_instalment_schedule__instalment_number',
    'policy_instalment_schedule__outstanding_after_instalment',
    'policy_instalment_schedule__paid_amount'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0'],
    'policy_instalment_schedule__instalment_number_ck': ['t0'],
    'policy_instalment_schedule__due_date': ['t0'],
    'policy_instalment_schedule__instalment_amount': ['t0'],
    'policy_instalment_schedule__instalment_number': ['t0'],
    'policy_instalment_schedule__outstanding_after_instalment': ['t0'],
    'policy_instalment_schedule__paid_amount': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_instalment_schedule_pk',
    target_sat='sat_policy_instalment_schedule'
) }}
