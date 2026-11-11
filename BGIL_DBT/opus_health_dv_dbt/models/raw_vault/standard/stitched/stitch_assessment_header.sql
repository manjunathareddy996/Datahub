{{ config(materialized='view') }}
-- This part feeds SAT_ASSESSMENT_HEADER only. Original precedence comments are kept below (from stitch_v02_assessment).
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
-- depends_on: {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_pro_assessment') }}
-- depends_on: {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(scrutiny_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': 'inserted_by', 'tgt': 'assessment_header__assessor_reference'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_pp_mem_dtls',
      'alias': 't1',
      'key_column': 'scrutiny_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PP_MEM_DTLS',
      'columns': [
        {'src': 'appointment_code', 'tgt': 'assessment_header__assessment_reference_number'},
        {'src': 'status_code', 'tgt': 'assessment_header__assessment_status'},
        {'src': 'type_of_checkup', 'tgt': 'assessment_header__assessment_type'},
        {'src': 'checkup_amt', 'tgt': 'assessment_header__cost_of_assessment'},
        {'src': 'remarks', 'tgt': 'assessment_header__outcome_summary'},
        {'src': 'priority_flag', 'tgt': 'assessment_header__priority'},
        {'src': 'app_date', 'tgt': 'assessment_header__scheduled_date'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't2',
      'key_column': 'pd_scrutiny_number',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'plc_medical_test_alrdy_con', 'tgt': 'assessment_header__assessment_status'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_pro_assessment',
      'alias': 't3',
      'key_column': 'assess_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PRO_ASSESSMENT',
      'columns': [
        {'src': 'assessment_edate', 'tgt': 'assessment_header__completed_date'},
        {'src': 'assessment_sdate', 'tgt': 'assessment_header__conducted_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_scr_hlth_portable_dtls',
      'alias': 't4',
      'key_column': 'scrutiny_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_SCR_HLTH_PORTABLE_DTLS',
      'columns': [
        {'src': 'status', 'tgt': 'assessment_header__assessment_status'}
      ]
    }
] -%}
{%- set output_columns = [
    'assessment_header__assessor_reference',
    'assessment_header__assessment_reference_number',
    'assessment_header__assessment_status',
    'assessment_header__assessment_type',
    'assessment_header__cost_of_assessment',
    'assessment_header__outcome_summary',
    'assessment_header__priority',
    'assessment_header__scheduled_date',
    'assessment_header__completed_date',
    'assessment_header__conducted_date'
] -%}
{%- set coalesce_rules = {
    'assessment_header__assessor_reference': ['t0'],
    'assessment_header__assessment_reference_number': ['t1'],
    'assessment_header__assessment_status': ['t1', 't2', 't4'],
    'assessment_header__assessment_type': ['t1'],
    'assessment_header__cost_of_assessment': ['t1'],
    'assessment_header__outcome_summary': ['t1'],
    'assessment_header__priority': ['t1'],
    'assessment_header__scheduled_date': ['t1'],
    'assessment_header__completed_date': ['t3'],
    'assessment_header__conducted_date': ['t3']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='assessment_bk',
    target_sat='sat_assessment_header'
) }}
