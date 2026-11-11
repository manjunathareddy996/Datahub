{{ config(materialized='view') }}
-- This part feeds SAT_PRODUCT_DEFINITION only. Original precedence comments are kept below (from stitch_v32_product).
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
-- depends_on: {{ ref('stg_health__bjaz_ctngy_gc_control') }}
-- depends_on: {{ ref('stg_health__bjaz_ctngy_scheme_plans') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_ctngy_scheme_mst') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hcs_plansi_mapp') }}
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_gc_control',
      'alias': 't0',
      'key_column': "nullif('PRODUCT:' || nullif(trim(product_code),''), 'PRODUCT:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_GC_CONTROL',
      'columns': [
        {'src': 'uin_no', 'tgt': 'product_definition__uin'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ctngy_scheme_plans',
      'alias': 't1',
      'key_column': "nullif('SCHEMEPLAN:' || nullif(trim(scheme_code),'') || '|' || nullif(trim(plan_id),''), 'SCHEMEPLAN:|')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_SCHEME_PLANS',
      'columns': [
        {'src': 'pdf_plan_desc', 'tgt': 'product_definition__product_display_name'},
        {'src': 'plan_desc', 'tgt': 'product_definition__product_name'},
        {'src': 'isactive', 'tgt': 'product_definition__product_status'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't2',
      'key_column': 'pd_product_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'plan_option', 'tgt': 'product_definition__product_display_name'},
        {'src': 'plan_name', 'tgt': 'product_definition__product_name'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't3',
      'key_column': 'pd_product_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'plan_option', 'tgt': 'product_definition__product_display_name'},
        {'src': 'plan_name', 'tgt': 'product_definition__product_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ctngy_scheme_mst',
      'alias': 't4',
      'key_column': 'scheme_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_SCHEME_MST',
      'columns': [
        {'src': 'health_product', 'tgt': 'product_definition__line_of_business'},
        {'src': 'scheme_desc', 'tgt': 'product_definition__product_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't5',
      'key_column': 'product',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'category', 'tgt': 'product_definition__product_category'},
        {'src': 'product_name', 'tgt': 'product_definition__product_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcs_plansi_mapp',
      'alias': 't6',
      'key_column': 'product_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCS_PLANSI_MAPP',
      'columns': [
        {'src': 'plan_name', 'tgt': 'product_definition__product_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't7',
      'key_column': 'product_4digit_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'plan_desc', 'tgt': 'product_definition__product_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't8',
      'key_column': 'product_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'plan_name', 'tgt': 'product_definition__product_name'}
      ]
    }
] -%}
{%- set output_columns = [
    'product_definition__uin',
    'product_definition__product_display_name',
    'product_definition__product_name',
    'product_definition__product_status',
    'product_definition__line_of_business',
    'product_definition__product_category',
    'product_definition__product_description'
] -%}
{%- set coalesce_rules = {
    'product_definition__uin': ['t0'],
    'product_definition__product_display_name': ['t1', 't2', 't3'],
    'product_definition__product_name': ['t1', 't2', 't3', 't4', 't5', 't6', 't8'],
    'product_definition__product_status': ['t1'],
    'product_definition__line_of_business': ['t4'],
    'product_definition__product_category': ['t5'],
    'product_definition__product_description': ['t7']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='product_bk',
    target_sat='sat_product_definition'
) }}
