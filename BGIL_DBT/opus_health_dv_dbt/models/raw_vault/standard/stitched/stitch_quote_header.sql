{{ config(materialized='view') }}
-- This part feeds SAT_QUOTE_HEADER only. Original precedence comments are kept below (from stitch_v02_assessment).
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
-- depends_on: {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ecard_pol_dtls_config') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_coverage_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_mem_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(quotation_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': 'record_date', 'tgt': 'quote_header__quote_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ecard_pol_dtls_config',
      'alias': 't1',
      'key_column': 'quote_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ECARD_POL_DTLS_CONFIG',
      'columns': [
        {'src': 'quote_status', 'tgt': 'quote_header__quote_status'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't2',
      'key_column': 'quote_sub_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'register_date', 'tgt': 'quote_header__quote_date'},
        {'src': 'remarks', 'tgt': 'quote_header__quote_remarks'},
        {'src': 'quote_status', 'tgt': 'quote_header__quote_status'},
        {'src': 'start_date', 'tgt': 'quote_header__requested_cover_start_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't3',
      'key_column': 'quote_ref_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'quote_status', 'tgt': 'quote_header__quote_status'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_coverage_dtls',
      'alias': 't4',
      'key_column': "nullif(trim(quote_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_COVERAGE_DTLS',
      'columns': [
        {'src': 'quote_sub_no', 'tgt': 'quote_header__quote_version'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_mem_dtls',
      'alias': 't5',
      'key_column': "nullif(trim(quote_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MEM_DTLS',
      'columns': [
        {'src': 'quote_sub_no', 'tgt': 'quote_header__quote_version'}
      ]
    }
] -%}
{%- set output_columns = [
    'quote_header__quote_date',
    'quote_header__quote_status',
    'quote_header__quote_remarks',
    'quote_header__requested_cover_start_date',
    'quote_header__quote_version'
] -%}
{%- set coalesce_rules = {
    'quote_header__quote_date': ['t0', 't2'],
    'quote_header__quote_status': ['t1', 't2', 't3'],
    'quote_header__quote_remarks': ['t2'],
    'quote_header__requested_cover_start_date': ['t2'],
    'quote_header__quote_version': ['t4', 't5']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='quote_bk',
    target_sat='sat_quote_header'
) }}
