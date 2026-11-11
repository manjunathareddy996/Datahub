{{ config(materialized='view') }}
-- This part feeds SAT_AUG_ASSESSMENT_MEDICAL only. Original precedence comments are kept below (from stitch_v03_assessment).
-- CENTRAL VIEW v03_assessment -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PP_MEM_DTLS (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_HM_DOCTOR_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_DOCTOR_MULTI_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_PCS_MULTI_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
--   BJAZ_RISK_IDENTIFIERS_MASTER (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_MEDICAL
--   SAT_AUG_ASSESSMENT_HEADER
--   SAT_AUG_ASSESSMENT_MEDICAL
--   SAT_AUG_ASSESSMENT_RISK_RULE_DEFINITION
--   SAT_RISK_PERSON_MEMBER
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_ASSESSMENT_PARTY
--   LNK_CHANNEL_ORG_UNIT
--   LNK_CLAIM_ASSESSMENT
--   LNK_CLAIM_COVERAGE
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_ORG_UNIT
--   LNK_PARTY_ROLE
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PROPOSAL_ASSESSMENT
--   LNK_PROPOSAL_PARTY
--   LNK_PROPOSAL_POLICY
--   LNK_RISK_OBJECT_ASSESSMENT
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_doctor_assess') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_doctor_multi_assess') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_pro_assessment') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't0',
      'key_column': 'pd_scrutiny_number',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'plc_medical_test_alrdy_con', 'tgt': 'aug_assessment_medical__prior_medical_test_conducted_indicator'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't1',
      'key_column': 'pd_scrutiny_number',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'plc_waiver_of_medical_test', 'tgt': 'aug_assessment_medical__medical_test_waiver_indicator'},
        {'src': 'plc_medical_test_alrdy_con', 'tgt': 'aug_assessment_medical__prior_medical_test_conducted_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_doctor_assess',
      'alias': 't2',
      'key_column': 'docasess_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_DOCTOR_ASSESS',
      'columns': [
        {'src': 'diagnosis_id', 'tgt': 'aug_assessment_medical__diagnosis_code'},
        {'src': 'diagnosis_detail', 'tgt': 'aug_assessment_medical__diagnosis_description'},
        {'src': 'hlth_tips', 'tgt': 'aug_assessment_medical__health_advice_text'},
        {'src': 'icd_id', 'tgt': 'aug_assessment_medical__icd_code'},
        {'src': 'package_flag', 'tgt': 'aug_assessment_medical__package_applicable_indicator'},
        {'src': 'pcs_yn', 'tgt': 'aug_assessment_medical__pcs_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_doctor_multi_assess',
      'alias': 't3',
      'key_column': 'docasess_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_DOCTOR_MULTI_ASSESS',
      'columns': [
        {'src': 'hlth_tips', 'tgt': 'aug_assessment_medical__health_advice_text'},
        {'src': 'package_flag', 'tgt': 'aug_assessment_medical__package_procedure_indicator'},
        {'src': 'pcs_yn', 'tgt': 'aug_assessment_medical__procedure_applicable_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_pro_assessment',
      'alias': 't4',
      'key_column': 'assess_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PRO_ASSESSMENT',
      'columns': [
        {'src': 'final_diagnosis', 'tgt': 'aug_assessment_medical__final_diagnosis'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_assessment_medical__prior_medical_test_conducted_indicator',
    'aug_assessment_medical__medical_test_waiver_indicator',
    'aug_assessment_medical__diagnosis_code',
    'aug_assessment_medical__diagnosis_description',
    'aug_assessment_medical__health_advice_text',
    'aug_assessment_medical__icd_code',
    'aug_assessment_medical__package_applicable_indicator',
    'aug_assessment_medical__pcs_indicator',
    'aug_assessment_medical__package_procedure_indicator',
    'aug_assessment_medical__procedure_applicable_indicator',
    'aug_assessment_medical__final_diagnosis'
] -%}
{%- set coalesce_rules = {
    'aug_assessment_medical__prior_medical_test_conducted_indicator': ['t0', 't1'],
    'aug_assessment_medical__medical_test_waiver_indicator': ['t1'],
    'aug_assessment_medical__diagnosis_code': ['t2'],
    'aug_assessment_medical__diagnosis_description': ['t2'],
    'aug_assessment_medical__health_advice_text': ['t2', 't3'],
    'aug_assessment_medical__icd_code': ['t2'],
    'aug_assessment_medical__package_applicable_indicator': ['t2'],
    'aug_assessment_medical__pcs_indicator': ['t2'],
    'aug_assessment_medical__package_procedure_indicator': ['t3'],
    'aug_assessment_medical__procedure_applicable_indicator': ['t3'],
    'aug_assessment_medical__final_diagnosis': ['t4']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='assessment_bk',
    target_sat='sat_aug_assessment_medical'
) }}
