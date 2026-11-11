{{ config(materialized='view') }}
-- This part feeds LNK_POLICY_PRODUCT only. Original precedence comments are kept below (from stitch_v21_party).
-- CENTRAL VIEW v21_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_PARTY_FINANCIAL_PROFILE
--   SAT_PARTY_POLICY_HISTORY
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_DOCUMENT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_DOCUMENT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_RISK_OBJECT_DOCUMENT
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't0',
      'key_column': "contract_id || '|' || product_code",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'product_code', 'tgt': 'product_bk'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'product_bk'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0'],
    'product_bk': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_product_lk',
    target_sat='lnk_policy_product'
) }}
