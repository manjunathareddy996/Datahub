/* RESHAPED (Option C), ONE STITCH PER SATELLITE, from hcon4 central view 25.
   Batch task 7.1 -- applies the pilot procedure (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_risk_health_member_medical
   payload           : 17 output column(s), this satellite's stage hashdiff payload only.
   hub_keys          : the FULL final-SELECT hub-key set of the central view (19), verbatim,
                       so downstream hub/stage layers keep resolving every HUB_*_BK column.
   key_column rule   : each source's HUB_POLICY_BK__* column (spine-hub grain key).
   GRAIN DEVIATIONS  : none.
   SAME-ALIAS DROPS (macro emits one column per alias per attr; secondary raw col dropped):
       disclosed_indicator: kept t6.asthma_yn; dropped diabetes_yn, gmc_ihd, hypertension_yn, renal_problem
       disclosed_indicator: kept t0.md_asthma; dropped md_cholesterol_disorders, md_diabetes, md_heart_diseases, md_hypertension, md_obesity
       disclosed_indicator: kept t1.md_asthma; dropped md_cholesterol_disorders, md_diabetes, md_heart_diseases, md_hypertension, md_obesity
       disclosed_indicator: kept t2.md_cholesterol_disorders; dropped md_diabetes, md_heart_diseases, md_hypertension, md_obesity
       disclosed_indicator: kept t3.asthma_yn; dropped diabetes_yn, hypertension_yn, pregnant_yn
       disclosed_indicator: kept t4.diabetes; dropped hypertention, ihd, renal_problem
       disclosed_indicator: kept t5.asthma_flag; dropped bmi_flag, diabetes_flag, heart_flag, height_flag, hipertension_flag, holesterol_flag, hyperlipide_flag, obesity_flag, other_risk_flag, weight_flag
       disclosed_indicator: kept t7.asthma_yn; dropped diabetes_yn, hypertension_yn
       disclosed_indicator: kept t8.asthma_yn; dropped diabetes_yn, hypertension_yn
       condition_name: kept t6.disease_dtls; dropped gmc_disease_to_be_excluded
       condition_name: kept t3.past_4yr_illness; dropped prior_4yr_illness
       condition_name: kept t4.disease_to_be_excluded; dropped other_diseases
       treatment_description: kept t3.past_4yr_treatment; dropped prior_4yr_treatment
       last_treatment_date: kept t3.past_4yr_treat_date; dropped prior_4yr_treat_date
       underwriting_loading_percentage: kept t5.bmi_load; dropped diabetes_load, hyperlipidemia_load, hypertens_load, obesity_load, other_risk_load
   SOURCES OMITTED   : none.
   merge order       : R8 precedence (v2 > legacy > delta3) preserved from the central view COALESCE order.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_prod_8432_ecp_loader',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_asthma', 'tgt': 'disclosed_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number', 'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'pd_bank_ref_no1_lac_sac', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC'},
            {'src_expr': 'pd_location_code', 'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id', 'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no', 'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code', 'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8432_ECP_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8433_fhc_loader',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_asthma', 'tgt': 'disclosed_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number', 'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'pd_bank_ref_no1_lac_sac', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC'},
            {'src_expr': 'pd_location_code', 'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id', 'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no', 'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code', 'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
            {'src_expr': 'md_seq_no', 'tgt': 'HUB_RISK_OBJECT_BK__MD_SEQ_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8433_FHC_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8439_clh_loader',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_cholesterol_disorders', 'tgt': 'disclosed_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number', 'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'plc_loan_acc_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO'},
            {'src_expr': 'pd_location_code', 'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id', 'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no', 'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code', 'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8439_CLH_LOADER'
    },
    {
        'model': 'stg_ec_mem_dtls_extn',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'asthma_yn', 'tgt': 'disclosed_indicator'},
            {'src': 'pregnant_months', 'tgt': 'gestation_months'},
            {'src': 'fmly_hlth_complains', 'tgt': 'family_medical_history_detail'},
            {'src': 'illness_duration', 'tgt': 'illness_duration'},
            {'src': 'past_4yr_illness', 'tgt': 'condition_name'},
            {'src': 'past_4yr_treatment', 'tgt': 'treatment_description'},
            {'src': 'past_4yr_treat_date', 'tgt': 'last_treatment_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_hat_id_mem_detls',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'diabetes', 'tgt': 'disclosed_indicator'},
            {'src': 'disease_to_be_excluded', 'tgt': 'condition_name'},
            {'src': 'marriage_date', 'tgt': 'date_of_marriage'}
        ],
        'hub_key_columns': [
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HAT_ID_MEM_DETLS'
    },
    {
        'model': 'stg_hcf_member_dtls',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'asthma_flag', 'tgt': 'disclosed_indicator'},
            {'src': 'diabetes_type', 'tgt': 'condition_name'},
            {'src': 'decease_treatment_dtls', 'tgt': 'treatment_details_narrative'},
            {'src': 'bmi_load', 'tgt': 'underwriting_loading_percentage'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_hm_member_hlth_dtls',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'asthma_yn', 'tgt': 'disclosed_indicator'},
            {'src': 'disease_dtls', 'tgt': 'condition_name'},
            {'src': 'sh_period_of_insurance', 'tgt': 'declared_insurance_period'},
            {'src': 'sh_period_treatment', 'tgt': 'treatment_period'},
            {'src': 'sh_doctor_name', 'tgt': 'treating_doctor_name'},
            {'src': 'sh_comments', 'tgt': 'declared_health_remarks'},
            {'src': 'hc_prescription_details', 'tgt': 'prescription_detail'},
            {'src': 'remark_center', 'tgt': 'diagnostic_centre_remarks'},
            {'src': 'hc_prescription_yn', 'tgt': 'prescription_submitted_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(HAT_ID_CITY),''),'') || '|' || coalesce(nullif(trim(HAT_ID_STATE),''),''), '|'))))", 'tgt': 'HUB_LOCATION_BK__HAT_ID_CITY_HAT_ID_STATE'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('MEMBER:' || coalesce(nullif(trim(CONTRACT_ID),''),'') || '#' || coalesce(nullif(trim(MEMBER_ID),''),''), 'MEMBER:#')", 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_CONTRACT_ID_MEMBER_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_MEMBER_HLTH_DTLS'
    },
    {
        'model': 'stg_ihg_mem_dtls_extn',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'asthma_yn', 'tgt': 'disclosed_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_IHG_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_sh_mem_dtls_extn',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'asthma_yn', 'tgt': 'disclosed_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_SH_MEM_DTLS_EXTN'
    }
] -%}

{%- set output_columns = [
    'disclosed_indicator',
    'gestation_months',
    'family_medical_history_detail',
    'illness_duration',
    'condition_name',
    'treatment_description',
    'last_treatment_date',
    'date_of_marriage',
    'treatment_details_narrative',
    'underwriting_loading_percentage',
    'declared_insurance_period',
    'treatment_period',
    'treating_doctor_name',
    'declared_health_remarks',
    'prescription_detail',
    'diagnostic_centre_remarks',
    'prescription_submitted_indicator'
] -%}

{%- set coalesce_rules = {
    'disclosed_indicator': ['t6', 't0', 't1', 't2', 't3', 't4', 't5', 't7', 't8'],
    'gestation_months': ['t3'],
    'family_medical_history_detail': ['t3'],
    'illness_duration': ['t3'],
    'condition_name': ['t6', 't3', 't4', 't5'],
    'treatment_description': ['t3'],
    'last_treatment_date': ['t3'],
    'date_of_marriage': ['t4'],
    'treatment_details_narrative': ['t5'],
    'underwriting_loading_percentage': ['t5'],
    'declared_insurance_period': ['t6'],
    'treatment_period': ['t6'],
    'treating_doctor_name': ['t6'],
    'declared_health_remarks': ['t6'],
    'prescription_detail': ['t6'],
    'diagnostic_centre_remarks': ['t6'],
    'prescription_submitted_indicator': ['t6']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t8.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t3.HUB_DOCUMENT_BK__MEDICAL_REPORT, t7.HUB_DOCUMENT_BK__MEDICAL_REPORT, t8.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t0.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t1.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t2.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't6.HUB_LOCATION_BK__HAT_ID_CITY_HAT_ID_STATE'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t0.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t3.HUB_PARTY_BK__MEMBER_NO, t4.HUB_PARTY_BK__MEMBER_NO, t5.HUB_PARTY_BK__MEMBER_NO, t7.HUB_PARTY_BK__MEMBER_NO, t8.HUB_PARTY_BK__MEMBER_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__POL_SERIAL_NO, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__CONTRACT_ID, t4.HUB_POLICY_BK__CONTRACT_ID, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__CONTRACT_ID, t7.HUB_POLICY_BK__CONTRACT_ID, t8.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t1.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t3.HUB_RISK_OBJECT_BK__MEMBER_NO, t5.HUB_RISK_OBJECT_BK__MEMBER_NO, t6.HUB_RISK_OBJECT_BK__MEMBER_CONTRACT_ID_MEMBER_ID)'},
    {'name': 'T0__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't0.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T1__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't1.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T2__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't2.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_risk_health_member_medical'
) }}
