{{ config(materialized='view') }}
-- This part feeds SAT_AUG_POLICY_HEADER only. Original precedence comments are kept below (from stitch_v24_policy).
-- CENTRAL VIEW v24_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_BASES_EXTN (opus_health_v2)
--   BJAZ_CTNGY_COVERS_EXT (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_PORT_WORDINGS (opus_health_legacy_v4)
--   BJAZ_ECARD_POL_DTLS_CONFIG (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BA_CCP_INSURED_DETAILS (opus_health_delta3)
--   BA_CCP_SUB_MATER_DTLS (opus_health_delta3)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_GRP_HLT_COVERAGE_DTLS (opus_health_delta3)
--   BJAZ_GRP_HLT_MEM_DTLS (opus_health_delta3)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_POLICY_SUMMARY (opus_health_delta3)
--   BJAZ_STARPKG_COVER_DTLS (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
--   BJAZ_VERSIONS_EXTN (opus_health_delta3)
--   OCP_INTERESTED_PARTIES (opus_health_delta3)
--   OCP_POLICY_COVERS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_COINSURANCE
--   SAT_AUG_POLICY_COVERAGE_PARAMETER
--   SAT_AUG_POLICY_GROUP_RELATION_ELIGIBILITY
--   SAT_AUG_POLICY_HEADER
--   SAT_AUG_POLICY_LIFECYCLE
--   SAT_AUG_POLICY_TAX_BREAKUP
--   SAT_COMMON_BUSINESS_AUDIT
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_PRODUCT
--   LNK_PRODUCT_COVERAGE
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_ctngy_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_ctngy_covers_ext') }}
-- depends_on: {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
-- depends_on: {{ ref('stg_health__ba_hcp_port_wordings') }}
-- depends_on: {{ ref('stg_health__bjaz_ecard_pol_dtls_config') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__ba_ccp_insured_details') }}
-- depends_on: {{ ref('stg_health__ba_ccp_sub_mater_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_gmc_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_coverage_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_mem_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_summary') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_cover_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_versions_extn') }}
-- depends_on: {{ ref('stg_health__ocp_interested_parties') }}
-- depends_on: {{ ref('stg_health__ocp_policy_covers') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_bases_extn',
      'alias': 't0',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_BASES_EXTN',
      'columns': [
        {'src': 'scheme_version', 'tgt': 'aug_policy_header__product_version_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ctngy_covers_ext',
      'alias': 't1',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_COVERS_EXT',
      'columns': [
        {'src': 'partition_no', 'tgt': 'aug_policy_header__contract_partition_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't2',
      'key_column': "nullif(trim(policy_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': 'other_remarks', 'tgt': 'aug_policy_header__additional_remarks'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't3',
      'key_column': "nullif(trim(policy_ref),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': 'coalesce(dateofsubmission, entry_date)', 'tgt': 'aug_policy_header__application_submission_date'},
        {'src': 'policy_issued_yn', 'tgt': 'aug_policy_header__policy_issued_indicator'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_port_wordings',
      'alias': 't4',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PORT_WORDINGS',
      'columns': [
        {'src': 'pol_version_no', 'tgt': 'aug_policy_header__policy_version_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ecard_pol_dtls_config',
      'alias': 't5',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ECARD_POL_DTLS_CONFIG',
      'columns': [
        {'src': 'short_period_date', 'tgt': 'aug_policy_header__short_period_end_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't6',
      'key_column': 'reg_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'policy_issuance_confirmation', 'tgt': 'aug_policy_header__policy_issuance_confirmation_indicator'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_insured_details',
      'alias': 't7',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_INSURED_DETAILS',
      'columns': [
        {'src': 'co_app_cover_req', 'tgt': 'aug_policy_header__co_applicant_cover_requested_indicator'},
        {'src': 'no_of_coapp', 'tgt': 'aug_policy_header__loan_co_applicant_count'},
        {'src': 'version_no', 'tgt': 'aug_policy_header__policy_version_number'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't8',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': 'customer_comm', 'tgt': 'aug_policy_header__customer_communication_text'},
        {'src': 'version_no', 'tgt': 'aug_policy_header__policy_version_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gmc_bases_extn',
      'alias': 't9',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GMC_BASES_EXTN',
      'columns': [
        {'src': 'comments', 'tgt': 'aug_policy_header__additional_remarks'},
        {'src': 'version_no', 'tgt': 'aug_policy_header__policy_version_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_coverage_dtls',
      'alias': 't10',
      'key_column': "nullif(trim(reg_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_COVERAGE_DTLS',
      'columns': [
        {'src': 'version_no', 'tgt': 'aug_policy_header__policy_version_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_mem_dtls',
      'alias': 't11',
      'key_column': "nullif(trim(reg_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MEM_DTLS',
      'columns': [
        {'src': 'version_no', 'tgt': 'aug_policy_header__policy_version_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't12',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': 'comments', 'tgt': 'aug_policy_header__additional_remarks'},
        {'src': 'i_track_no', 'tgt': 'aug_policy_header__internal_tracking_number'},
        {'src': 'version_no', 'tgt': 'aug_policy_header__policy_version_number'},
        {'src': 'calculation_period', 'tgt': 'aug_policy_header__premium_calculation_period'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't13',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': 'version_no', 'tgt': 'aug_policy_header__policy_version_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_cover_dtls',
      'alias': 't14',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_COVER_DTLS',
      'columns': [
        {'src': 'partition_no', 'tgt': 'aug_policy_header__contract_partition_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_pol_dtls',
      'alias': 't15',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_POL_DTLS',
      'columns': [
        {'src': 'version_no', 'tgt': 'aug_policy_header__policy_version_number'},
        {'src': 'uw_flag', 'tgt': 'aug_policy_header__underwriting_review_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_versions_extn',
      'alias': 't16',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_VERSIONS_EXTN',
      'columns': [
        {'src': 'version_no', 'tgt': 'aug_policy_header__policy_version_number'}
      ]
    },
    {
      'model': 'stg_health__ocp_interested_parties',
      'alias': 't17',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_OCP_INTERESTED_PARTIES',
      'columns': [
        {'src': 'version_no', 'tgt': 'aug_policy_header__policy_version_number'}
      ]
    },
    {
      'model': 'stg_health__ocp_policy_covers',
      'alias': 't18',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_OCP_POLICY_COVERS',
      'columns': [
        {'src': 'partition_no', 'tgt': 'aug_policy_header__contract_partition_number'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_policy_header__product_version_applied',
    'aug_policy_header__contract_partition_number',
    'aug_policy_header__additional_remarks',
    'aug_policy_header__application_submission_date',
    'aug_policy_header__policy_issued_indicator',
    'aug_policy_header__policy_version_number',
    'aug_policy_header__short_period_end_date',
    'aug_policy_header__policy_issuance_confirmation_indicator',
    'aug_policy_header__co_applicant_cover_requested_indicator',
    'aug_policy_header__loan_co_applicant_count',
    'aug_policy_header__customer_communication_text',
    'aug_policy_header__internal_tracking_number',
    'aug_policy_header__premium_calculation_period',
    'aug_policy_header__underwriting_review_indicator'
] -%}
{%- set coalesce_rules = {
    'aug_policy_header__product_version_applied': ['t0'],
    'aug_policy_header__contract_partition_number': ['t1', 't14', 't18'],
    'aug_policy_header__additional_remarks': ['t2', 't9', 't12'],
    'aug_policy_header__application_submission_date': ['t3'],
    'aug_policy_header__policy_issued_indicator': ['t3'],
    'aug_policy_header__policy_version_number': ['t4', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't15', 't16', 't17'],
    'aug_policy_header__short_period_end_date': ['t5'],
    'aug_policy_header__policy_issuance_confirmation_indicator': ['t6'],
    'aug_policy_header__co_applicant_cover_requested_indicator': ['t7'],
    'aug_policy_header__loan_co_applicant_count': ['t7'],
    'aug_policy_header__customer_communication_text': ['t8'],
    'aug_policy_header__internal_tracking_number': ['t12'],
    'aug_policy_header__premium_calculation_period': ['t12'],
    'aug_policy_header__underwriting_review_indicator': ['t15']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_aug_policy_header'
) }}
