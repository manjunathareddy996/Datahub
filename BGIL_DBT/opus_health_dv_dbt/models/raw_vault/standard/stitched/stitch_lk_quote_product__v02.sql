{{ config(materialized='view') }}
-- This part feeds LNK_QUOTE_PRODUCT only. Original precedence comments are kept below (from stitch_v02_assessment).
-- CENTRAL VIEW v02_assessment -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BA_HCP_PP_MEM_DTLS (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_ECARD_POL_DTLS_CONFIG (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
--   BJAZ_SCR_HLTH_PORTABLE_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_COVERAGE_DTLS (opus_health_delta3)
--   BJAZ_GRP_HLT_MEM_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_HEADER
--   SAT_QUOTE_HEADER
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_ASSESSMENT_PARTY
--   LNK_CASE_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_QUOTE_PRODUCT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_mem_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_grp_hlt_mem_dtls',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif('PRODUCT:' || nullif(trim(product),''), 'PRODUCT:'))) || '|' || trim(to_varchar(nullif(trim(quote_no),'')))",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MEM_DTLS',
      'columns': [
        {'src': "nullif('PRODUCT:' || nullif(trim(product),''), 'PRODUCT:')", 'tgt': 'product_bk'},
        {'src': "nullif(trim(quote_no),'')", 'tgt': 'quote_bk'}
      ]
    }
] -%}
{%- set output_columns = [
    'product_bk',
    'quote_bk'
] -%}
{%- set coalesce_rules = {
    'product_bk': ['t0'],
    'quote_bk': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='quote_product_lk',
    target_sat='lnk_quote_product'
) }}
