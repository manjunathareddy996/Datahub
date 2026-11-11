{{ config(materialized='view') }}
-- This part feeds SAT_PROPOSAL_QUESTIONNAIRE only. Original precedence comments are kept below (from stitch_v32_product).
-- CENTRAL VIEW v32_product -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_GC_CONTROL (opus_health_v2)
--   BJAZ_CTNGY_SCHEME_PLANS (opus_health_v2)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_CTNGY_SCHEME_MST (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_IMD_DTLS (opus_health_legacy_v4)
--   BJAZ_HCS_PLANSI_MAPP (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_PRODUCT_DEFINITION
--   SAT_AUG_PRODUCT_HEALTH_MEMBERSHIP_RULES
--   SAT_AUG_PRODUCT_TERMS
--   SAT_PRODUCT_DEFINITION
--   SAT_PROPOSAL_QUESTIONNAIRE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CHANNEL_ORG_UNIT
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_ORG_UNIT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_PRODUCT_COVERAGE
--   LNK_PROPOSAL_PARTY
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_PRODUCT
--   LNK_QUOTE_PARTY
--   LNK_QUOTE_PRODUCT
--   LNK_QUOTE_PROPOSAL
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't0',
      'key_column': 'quote_ref_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'prev_accident_yn', 'tgt': 'proposal_questionnaire__response_value'},
        {'src': "'PREV_ACCIDENT'", 'tgt': 'proposal_questionnaire__question_code_ck'}
      ]
    }
] -%}
{%- set output_columns = [
    'proposal_questionnaire__response_value',
    'proposal_questionnaire__question_code_ck'
] -%}
{%- set coalesce_rules = {
    'proposal_questionnaire__response_value': ['t0'],
    'proposal_questionnaire__question_code_ck': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='proposal_bk',
    target_sat='sat_proposal_questionnaire'
) }}
