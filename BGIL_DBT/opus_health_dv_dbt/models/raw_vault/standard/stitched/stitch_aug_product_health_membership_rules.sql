{{ config(materialized='view') }}
-- This part feeds SAT_AUG_PRODUCT_HEALTH_MEMBERSHIP_RULES only. Original precedence comments are kept below (from stitch_v32_product).
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
-- depends_on: {{ ref('stg_health__bjaz_ctngy_scheme_plans') }}
-- depends_on: {{ ref('stg_health__bjaz_ctngy_scheme_mst') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_scheme_plans',
      'alias': 't0',
      'key_column': "nullif('SCHEMEPLAN:' || nullif(trim(scheme_code),'') || '|' || nullif(trim(plan_id),''), 'SCHEMEPLAN:|')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_SCHEME_PLANS',
      'columns': [
        {'src': 'pin_code_val_yn', 'tgt': 'aug_product_health_membership_rules__member_pin_code_validation_required_indicator'},
        {'src': 'self_exclude', 'tgt': 'aug_product_health_membership_rules__self_member_exclusion_allowed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ctngy_scheme_mst',
      'alias': 't1',
      'key_column': 'scheme_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_SCHEME_MST',
      'columns': [
        {'src': 'ff_dtls_only', 'tgt': 'aug_product_health_membership_rules__family_floater_details_only_indicator'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_product_health_membership_rules__member_pin_code_validation_required_indicator',
    'aug_product_health_membership_rules__self_member_exclusion_allowed_indicator',
    'aug_product_health_membership_rules__family_floater_details_only_indicator'
] -%}
{%- set coalesce_rules = {
    'aug_product_health_membership_rules__member_pin_code_validation_required_indicator': ['t0'],
    'aug_product_health_membership_rules__self_member_exclusion_allowed_indicator': ['t0'],
    'aug_product_health_membership_rules__family_floater_details_only_indicator': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='product_bk',
    target_sat='sat_aug_product_health_membership_rules'
) }}
