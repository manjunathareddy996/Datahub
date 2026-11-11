{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_CLASSIFICATION only. Original precedence comments are kept below (from stitch_v22_policy).
-- CENTRAL VIEW v22_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_NR_BASES_EXTN (opus_health_v2)
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BA_HCP_DT_PREMIUM (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_HEALTH_WEBSERVICE_INFO (opus_health_legacy_v4)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_UNDERWRITING
--   SAT_AUG_POLICY_CLASSIFICATION
--   SAT_AUG_POLICY_CONTINGENCY_SCHEME
--   SAT_POLICY_CLASSIFICATION
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_ctngy_nr_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
-- depends_on: {{ ref('stg_health__ba_hcp_dt_premium') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bgil_gmc_final_instl_data') }}
-- depends_on: {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
-- depends_on: {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_health_webservice_info') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_nr_bases_extn',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(param_ref, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_NR_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'param_ref', 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'param_ref', 'tgt': 'policy_classification__classification_type'},
        {'src': 'param_value', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'TRANSACTION_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'TRANSACTION_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'transaction_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'BUSINESS_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'BUSINESS_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'buiseness_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't3',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'CRC_APPLICABLE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'CRC_APPLICABLE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'crcapplicable_yn', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't4',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'ENROLLMENT_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'ENROLLMENT_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'enrollment_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_dt_premium',
      'alias': 't5',
      'key_column': "contract_id || '|' || 'BUSINESS_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_PREMIUM',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': "'BUSINESS_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'buss_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't6',
      'key_column': "pol_serial_no || '|' || 'BUSINESS_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pol_serial_no', 'tgt': 'policy_bk'},
        {'src': "'BUSINESS_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'pd_business_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't7',
      'key_column': "pol_serial_no || '|' || 'BUSINESS_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'pol_serial_no', 'tgt': 'policy_bk'},
        {'src': "'BUSINESS_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'pd_business_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't8',
      'key_column': "pol_serial_no || '|' || 'BUSINESS_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'pol_serial_no', 'tgt': 'policy_bk'},
        {'src': "'BUSINESS_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'pd_business_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't9',
      'key_column': "pol_serial_no || '|' || 'BUSINESS_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pol_serial_no', 'tgt': 'policy_bk'},
        {'src': "'BUSINESS_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'pd_business_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__bgil_gmc_final_instl_data',
      'alias': 't10',
      'key_column': "policy_no || '|' || 'GRADE_BUCKET'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BGIL_GMC_FINAL_INSTL_DATA',
      'columns': [
        {'src': 'policy_no', 'tgt': 'policy_bk'},
        {'src': "'GRADE_BUCKET'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'grade_bucket', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__bjaz_bandhan_medi_clam',
      'alias': 't11',
      'key_column': "policy_ref || '|' || 'BUSINESS_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BANDHAN_MEDI_CLAM',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': "'BUSINESS_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'business_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gpg_pol_dtls',
      'alias': 't12',
      'key_column': "reference_id || '|' || 'BUSINESS_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GPG_POL_DTLS',
      'columns': [
        {'src': 'reference_id', 'tgt': 'policy_bk'},
        {'src': "'BUSINESS_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'business_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't13',
      'key_column': "reg_no || '|' || 'INDUSTRY_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'INDUSTRY_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'industry_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't14',
      'key_column': "reg_no || '|' || 'BUSINESS_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'BUSINESS_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'business_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__bjaz_health_webservice_info',
      'alias': 't15',
      'key_column': "policy_ref || '|' || 'BUSINESS_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HEALTH_WEBSERVICE_INFO',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': "'BUSINESS_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'business_type', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't16',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'BUSINESS_SOURCE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'BUSINESS_SOURCE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'business_source', 'tgt': 'policy_classification__classification_value'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_pol_dtls',
      'alias': 't17',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'BUSINESS_TYPE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_POL_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'BUSINESS_TYPE'", 'tgt': 'policy_classification__classification_type_ck'},
        {'src': 'buss_type', 'tgt': 'policy_classification__classification_value'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'policy_classification__classification_type_ck',
    'policy_classification__classification_type',
    'policy_classification__classification_value'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17'],
    'policy_classification__classification_type_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17'],
    'policy_classification__classification_type': ['t0'],
    'policy_classification__classification_value': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_classification_pk',
    target_sat='sat_policy_classification'
) }}
