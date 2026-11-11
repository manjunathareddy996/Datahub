{{ config(materialized='view') }}
-- This part feeds LNK_POLICY_PRODUCT only. Original precedence comments are kept below (from stitch_v28_policy).
-- CENTRAL VIEW v28_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_GC_CONTROL (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BJAZ_ECARD_POL_DTLS_CONFIG (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_CUST_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_MATERNITY_DTLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_GRP_HLT_COVERAGE_DTLS (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_TERMS
--   SAT_POLICY_EXCESS_STRUCTURE
--   SAT_POLICY_SUM_INSURED_BREAKUP
--   SAT_PROPOSAL_HEADER
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_FINTXN_POLICY
--   LNK_PARTY_CHANNEL
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PROPOSAL_ASSESSMENT
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_PRODUCT
--   LNK_QUOTE_PRODUCT
--   LNK_QUOTE_PROPOSAL
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_ctngy_gc_control') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_cust_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_coverage_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_gc_control',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(policy_ref),''))) || '|' || trim(to_varchar(nullif('PRODUCT:' || nullif(trim(product_code),''), 'PRODUCT:')))",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_GC_CONTROL',
      'columns': [
        {'src': "nullif(trim(policy_ref),'')", 'tgt': 'policy_bk'},
        {'src': "nullif('PRODUCT:' || nullif(trim(product_code),''), 'PRODUCT:')", 'tgt': 'product_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_cust_dtls',
      'alias': 't1',
      'key_column': "reg_no || '|' || product",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_CUST_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': 'product', 'tgt': 'product_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't2',
      'key_column': "reg_no || '|' || product",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': 'product', 'tgt': 'product_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't3',
      'key_column': "reg_no || '|' || product",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': 'product', 'tgt': 'product_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_coverage_dtls',
      'alias': 't4',
      'key_column': "trim(to_varchar(nullif(trim(reg_no),''))) || '|' || trim(to_varchar(nullif('PRODUCT:' || nullif(trim(product),''), 'PRODUCT:')))",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_COVERAGE_DTLS',
      'columns': [
        {'src': "nullif(trim(reg_no),'')", 'tgt': 'policy_bk'},
        {'src': "nullif('PRODUCT:' || nullif(trim(product),''), 'PRODUCT:')", 'tgt': 'product_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_pol_dtls',
      'alias': 't5',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || trim(to_varchar(nullif('PRODUCT:' || nullif(trim(prod_code),''), 'PRODUCT:')))",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_POL_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "nullif('PRODUCT:' || nullif(trim(prod_code),''), 'PRODUCT:')", 'tgt': 'product_bk'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'product_bk'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0', 't1', 't2', 't3', 't4', 't5'],
    'product_bk': ['t0', 't1', 't2', 't3', 't4', 't5']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_product_lk',
    target_sat='lnk_policy_product'
) }}
