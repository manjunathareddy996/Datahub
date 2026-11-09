/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Batch task 5.1. Procedure: the stitch_01 pilot's 9-step REUSABLE PROCEDURE.
   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_risk_person_insured
   GRAIN DEVIATIONS (source has no spine-hub key; keyed on its real join col):
     - t29 (stg_ecard_membr_del_dtls): no HUB_POLICY key; key_column=HUB_PARTY_BK__EMP_CODE (real join key)
     - t30 (stg_hm_hcs_tech_assess_cov): no HUB_POLICY key; key_column=HUB_CLAIM_BK__CLAIM_ID (real join key)
     - t31 (stg_remedinet_patient_details): no HUB_POLICY key; key_column=HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID (real join key)
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_ba_ccp_insured_details',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'height', 'tgt': 'height'},
            {'src': 'insured_prem', 'tgt': 'insured_person_premium_amount'},
            {'src': 'pre_exist_reason', 'tgt': 'pre_existing_disease_description'},
            {'src': 'proposer_pre_exist', 'tgt': 'pre_existing_disease_indicator'},
            {'src': 'proposer_relation', 'tgt': 'relationship_to_proposer'},
            {'src': 'weight', 'tgt': 'weight'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(contract_id),''),'') || '|INSURED|' || coalesce(nullif(trim(first_name),''),'') || '|' || coalesce(nullif(trim(middle_name),''),'') || '|' || coalesce(nullif(trim(last_name),''),'') || '|' || coalesce(nullif(trim(to_char(date_of_birth)),''),''), '|INSURED||||'))))", 'tgt': 'HUB_PARTY_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(contract_id),''),'') || '|NOMINEE|' || coalesce(nullif(trim(nominee_name),''),''), '|NOMINEE|'))))", 'tgt': 'HUB_PARTY_BK__CONTRACT_ID_NOMINEE_NOMINEE_NAME'},
            {'src_expr': "nullif(trim(contract_id),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(contract_id),''),'') || '|INSURED|' || coalesce(nullif(trim(first_name),''),'') || '|' || coalesce(nullif(trim(middle_name),''),'') || '|' || coalesce(nullif(trim(last_name),''),'') || '|' || coalesce(nullif(trim(to_char(date_of_birth)),''),''), '|INSURED||||'))))", 'tgt': 'HUB_RISK_OBJECT_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BA_CCP_INSURED_DETAILS'
    },
    {
        'model': 'stg_hcp_port_wordings',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'cb_applicable', 'tgt': 'cumulative_bonus_applicable_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PORT_WORDINGS'
    },
    {
        'model': 'stg_hcp_prod_8428_gpg_loader',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_height_cm', 'tgt': 'height'},
            {'src': 'md_pre_exist_disease_dis_inf', 'tgt': 'pre_existing_disease_description'},
            {'src': 'md_relation', 'tgt': 'relationship_to_proposer'},
            {'src': 'md_weight_kg', 'tgt': 'weight'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number', 'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'mlac_emi_pc_loan_account_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO'},
            {'src_expr': 'pd_location_code', 'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id', 'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no', 'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code', 'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
            {'src_expr': 'md_seq_no', 'tgt': 'HUB_RISK_OBJECT_BK__MD_SEQ_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8428_GPG_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8432_ecp_loader',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_bmi', 'tgt': 'body_mass_index'},
            {'src': 'md_height_cm', 'tgt': 'height'},
            {'src': 'md_pre_exist_disease_dis_inf', 'tgt': 'pre_existing_disease_description'},
            {'src': 'md_smoker_tobacco_chewer', 'tgt': 'smoker_indicator'},
            {'src': 'md_weight_kg', 'tgt': 'weight'}
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
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_bmi', 'tgt': 'body_mass_index'},
            {'src': 'md_height_cm', 'tgt': 'height'},
            {'src': 'md_spcl_condtn_member_level', 'tgt': 'member_special_condition'},
            {'src': 'md_pre_exist_disease_dis_inf', 'tgt': 'pre_existing_disease_description'},
            {'src': 'md_smoker_tobacco_chewer', 'tgt': 'smoker_indicator'},
            {'src': 'md_weight_kg', 'tgt': 'weight'}
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
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_bmi', 'tgt': 'body_mass_index'},
            {'src': 'md_height_cm', 'tgt': 'height'},
            {'src': 'md_relation', 'tgt': 'relationship_to_proposer'},
            {'src': 'md_weight_kg', 'tgt': 'weight'}
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
        'model': 'stg_bgil_gmc_final_instl_data',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'relation', 'tgt': 'relationship_to_proposer'}
        ],
        'hub_key_columns': [
            {'src_expr': 'emp_code', 'tgt': 'HUB_PARTY_BK__EMP_CODE'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BGIL_GMC_FINAL_INSTL_DATA'
    },
    {
        'model': 'stg_bandhan_medi_clam',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'preexisting_disease', 'tgt': 'pre_existing_disease_description'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'reference_id', 'tgt': 'HUB_CLAIM_BK__REFERENCE_ID'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'customer_id', 'tgt': 'HUB_PARTY_BK__CUSTOMER_ID'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'plan_id', 'tgt': 'HUB_PRODUCT_BK__PLAN_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_BANDHAN_MEDI_CLAM'
    },
    {
        'model': 'stg_card_dtls',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'relation', 'tgt': 'relationship_to_proposer'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'card_no', 'tgt': 'HUB_DOCUMENT_BK__CARD_NO'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_CARD_DTLS'
    },
    {
        'model': 'stg_ec_mem_dtls_extn',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'height_cm', 'tgt': 'height'},
            {'src': 'disease_dtls', 'tgt': 'pre_existing_disease_description'},
            {'src': 'relation', 'tgt': 'relationship_to_proposer'},
            {'src': 'smoker_yn', 'tgt': 'smoker_indicator'},
            {'src': 'weight_kg', 'tgt': 'weight'}
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
        'model': 'stg_gp_hospital_cash',
        'alias': 't10',
        'key_column': 'HUB_POLICY_BK__MASTER_POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'height', 'tgt': 'height'},
            {'src': 'preexisting_disease', 'tgt': 'pre_existing_disease_description'},
            {'src': 'relation', 'tgt': 'relationship_to_proposer'},
            {'src': 'weight', 'tgt': 'weight'}
        ],
        'hub_key_columns': [
            {'src_expr': 'imd_code', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 's_account_number', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER'},
            {'src_expr': 'user_id', 'tgt': 'HUB_PARTY_BK__USER_ID'},
            {'src_expr': 'master_policy_no', 'tgt': 'HUB_POLICY_BK__MASTER_POLICY_NO'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 'kgc_proposal_number', 'tgt': 'HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER'},
            {'src_expr': 'reference_id', 'tgt': 'HUB_PROPOSAL_BK__REFERENCE_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GP_HOSPITAL_CASH'
    },
    {
        'model': 'stg_hat_id_mem_detls',
        'alias': 't11',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'id_card_no', 'tgt': 'health_card_number'},
            {'src': 'relation', 'tgt': 'relationship_to_proposer'}
        ],
        'hub_key_columns': [
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HAT_ID_MEM_DETLS'
    },
    {
        'model': 'stg_hcf_member_dtls',
        'alias': 't12',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'load_per', 'tgt': 'member_risk_loading_percentage'},
            {'src': 'preexist_dicease', 'tgt': 'pre_existing_disease_description'},
            {'src': 'relation', 'tgt': 'relationship_to_proposer'},
            {'src': 'smoker_flag', 'tgt': 'smoker_indicator'}
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
        'model': 'stg_hc_part_extn',
        'alias': 't13',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'load_amt', 'tgt': 'member_loading_amount'},
            {'src': 'load_rate', 'tgt': 'member_risk_loading_percentage'},
            {'src': 'disease_dtls', 'tgt': 'pre_existing_disease_description'},
            {'src': 'relation', 'tgt': 'relationship_to_proposer'}
        ],
        'hub_key_columns': [
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_hdfc_sec_fhpp',
        'alias': 't14',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'height', 'tgt': 'height'},
            {'src': 'preexisting_disease', 'tgt': 'pre_existing_disease_description'},
            {'src': 'relation', 'tgt': 'relationship_to_proposer'},
            {'src': 'weight', 'tgt': 'weight'}
        ],
        'hub_key_columns': [
            {'src_expr': 'imd_code', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 's_account_number', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER'},
            {'src_expr': 'client_id', 'tgt': 'HUB_PARTY_BK__CLIENT_ID'},
            {'src_expr': 'reference_id', 'tgt': 'HUB_POLICY_BK__REFERENCE_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 'ba_lead_no', 'tgt': 'HUB_PROPOSAL_BK__BA_LEAD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HDFC_SEC_FHPP'
    },
    {
        'model': 'stg_hg_pol_dtls',
        'alias': 't15',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'risk_class', 'tgt': 'occupation_risk_class'}
        ],
        'hub_key_columns': [
            {'src_expr': 'cover_code', 'tgt': 'HUB_COVERAGE_BK__COVER_CODE'},
            {'src_expr': 'business_source', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE'},
            {'src_expr': 'company_org_unit', 'tgt': 'HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
            {'src_expr': 'department_code', 'tgt': 'HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'product_4digit_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE'},
            {'src_expr': 'quote_ref_no', 'tgt': 'HUB_PROPOSAL_BK__QUOTE_REF_NO'},
            {'src_expr': 'quote_ref_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_REF_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HG_POL_DTLS'
    },
    {
        'model': 'stg_hlt_ensure_mem_dtls',
        'alias': 't16',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pre_disease', 'tgt': 'pre_existing_disease_description'},
            {'src': 'relation', 'tgt': 'relationship_to_proposer'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HLT_ENSURE_MEM_DTLS'
    },
    {
        'model': 'stg_hm_cashless_inward',
        'alias': 't17',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'card_number', 'tgt': 'health_card_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'hospital_id', 'tgt': 'HUB_PARTY_BK__HOSPITAL_ID'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_CASHLESS_INWARD'
    },
    {
        'model': 'stg_hm_coinsu_clm_dtls',
        'alias': 't18',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'id_card_no', 'tgt': 'health_card_number'},
            {'src': 'member_flag', 'tgt': 'member_type'},
            {'src': 'relation', 'tgt': 'relationship_to_proposer'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'ldr_pid', 'tgt': 'HUB_PARTY_BK__LDR_PID'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'prod_cd', 'tgt': 'HUB_PRODUCT_BK__PROD_CD'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_COINSU_CLM_DTLS'
    },
    {
        'model': 'stg_hm_gmc_ahc',
        'alias': 't19',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'id_card_no', 'tgt': 'health_card_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_GMC_AHC'
    },
    {
        'model': 'stg_hm_inward_dtls',
        'alias': 't20',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'id_card_no', 'tgt': 'health_card_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'inward_id', 'tgt': 'HUB_DOCUMENT_BK__INWARD_ID'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode', 'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc', 'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'claim_id', 'tgt': 'HUB_LOSS_EVENT_BK__CLAIM_ID'},
            {'src_expr': 'courier_id', 'tgt': 'HUB_PARTY_BK__COURIER_ID'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_INWARD_DTLS'
    },
    {
        'model': 'stg_hm_member_dtls',
        'alias': 't21',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'id_card_no', 'tgt': 'health_card_number'},
            {'src': 'load_amt', 'tgt': 'member_risk_loading_amount'},
            {'src': 'load_rate', 'tgt': 'member_risk_loading_percentage'},
            {'src': 'member_flag', 'tgt': 'member_type'},
            {'src': 'risk_class', 'tgt': 'occupation_risk_class'},
            {'src': 'relation', 'tgt': 'relationship_to_proposer'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'bank_ac_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
            {'src_expr': 'member_id', 'tgt': 'HUB_PARTY_BK__MEMBER_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_hm_member_hlth_dtls',
        'alias': 't22',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age_proof', 'tgt': 'age_proof_submitted_indicator'},
            {'src': 'body_mas_indes', 'tgt': 'body_mass_index'},
            {'src': 'claim_history', 'tgt': 'declared_claim_history_detail'},
            {'src': 'amount_claimed', 'tgt': 'declared_prior_claim_amount'},
            {'src': 'gmc_family_hist_details', 'tgt': 'family_medical_history_detail'},
            {'src': 'gmc_family_hist', 'tgt': 'family_medical_history_indicator'},
            {'src': 'height_cm', 'tgt': 'height'},
            {'src': 'gmc_load_flag', 'tgt': 'member_loading_applied_indicator'},
            {'src': 'ihg_clm_load', 'tgt': 'member_risk_loading_percentage'},
            {'src': 'other_hlt_dtls', 'tgt': 'other_health_declaration_detail'},
            {'src': 'pre_existing_diseases', 'tgt': 'pre_existing_disease_description'},
            {'src': 'prev_sum_insured', 'tgt': 'previous_sum_insured'},
            {'src': 'smoker_yn', 'tgt': 'smoker_indicator'},
            {'src': 'weight_kg', 'tgt': 'weight'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(HAT_ID_CITY),''),'') || '|' || coalesce(nullif(trim(HAT_ID_STATE),''),''), '|'))))", 'tgt': 'HUB_LOCATION_BK__HAT_ID_CITY_HAT_ID_STATE'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('MEMBER:' || coalesce(nullif(trim(CONTRACT_ID),''),'') || '#' || coalesce(nullif(trim(MEMBER_ID),''),''), 'MEMBER:#')", 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_CONTRACT_ID_MEMBER_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_MEMBER_HLTH_DTLS'
    },
    {
        'model': 'stg_hm_orphan_reg',
        'alias': 't23',
        'key_column': 'HUB_POLICY_BK__POLICY_NUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'idcardno', 'tgt': 'health_card_number'},
            {'src': 'relation', 'tgt': 'relationship_to_proposer'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode', 'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc', 'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'policy_number', 'tgt': 'HUB_POLICY_BK__POLICY_NUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_ORPHAN_REG'
    },
    {
        'model': 'stg_ihg_mem_dtls_extn',
        'alias': 't24',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'body_mas_indx', 'tgt': 'body_mass_index'},
            {'src': 'height_cm', 'tgt': 'height'},
            {'src': 'load_rate', 'tgt': 'member_risk_loading_percentage'},
            {'src': 'other_hlt_dtls', 'tgt': 'other_health_details'},
            {'src': 'disease_dtls', 'tgt': 'pre_existing_disease_description'},
            {'src': 'relation', 'tgt': 'relationship_to_proposer'},
            {'src': 'smoker_yn', 'tgt': 'smoker_indicator'},
            {'src': 'weight_kg', 'tgt': 'weight'}
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
        'model': 'stg_illness_bases_extn',
        'alias': 't25',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'relation', 'tgt': 'relationship_to_proposer'}
        ],
        'hub_key_columns': [
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ILLNESS_BASES_EXTN'
    },
    {
        'model': 'stg_pmsby_data_web_service',
        'alias': 't26',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'card_number', 'tgt': 'health_card_number'},
            {'src': 'card_status', 'tgt': 'health_card_status'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(USER_TRANS_KEY_NO),'')", 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO'},
            {'src_expr': "md5(normalise(upper(nullif(trim( coalesce(ADDRESS_1,'') || ' ' || coalesce(ADDRESS_2,'') || ' ' || coalesce(PINCODE,'') ),''))))", 'tgt': 'HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(POLICY_REF),''),'') || '|NOMINEE|' || coalesce(nullif(trim(NOMINEENAME),''),''), '|NOMINEE|'))))", 'tgt': 'HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME'},
            {'src_expr': "nullif(trim(CUST_ID),'')", 'tgt': 'HUB_PARTY_BK__CUST_ID'},
            {'src_expr': "nullif(trim(POLICY_REF),'')", 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': "nullif('CUSTID:' || nullif(trim(CUST_ID),''), 'CUSTID:')", 'tgt': 'HUB_RISK_OBJECT_BK__CUSTID_CUST_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_PMSBY_DATA_WEB_SERVICE'
    },
    {
        'model': 'stg_sh_mem_dtls_extn',
        'alias': 't27',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'load_rate', 'tgt': 'member_risk_loading_percentage'},
            {'src': 'disease_dtls', 'tgt': 'pre_existing_disease_description'},
            {'src': 'relation', 'tgt': 'relationship_to_proposer'},
            {'src': 'smoker_yn', 'tgt': 'smoker_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't28',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'relation', 'tgt': 'relationship_to_proposer'}
        ],
        'hub_key_columns': [
            {'src_expr': 'bjaz_claim_id', 'tgt': 'HUB_CLAIM_BK__BJAZ_CLAIM_ID'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'tpa_trans_key', 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY'},
            {'src_expr': 'tpa_claim_no', 'tgt': 'HUB_LOSS_EVENT_BK__TPA_CLAIM_NO'},
            {'src_expr': 'controlling_office', 'tgt': 'HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
            {'src_expr': 'operating_office', 'tgt': 'HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
            {'src_expr': 'customer_id', 'tgt': 'HUB_PARTY_BK__CUSTOMER_ID'},
            {'src_expr': 'hospital_code', 'tgt': 'HUB_PARTY_BK__HOSPITAL_CODE'},
            {'src_expr': 'cheque_no', 'tgt': 'HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_TPA_CLAIM_DETAILS_WS'
    },
    {
        'model': 'stg_ecard_membr_del_dtls',
        'alias': 't29',
        'key_column': 'HUB_PARTY_BK__EMP_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'relation', 'tgt': 'relationship_to_proposer'}
        ],
        'hub_key_columns': [
            {'src_expr': 'emp_code', 'tgt': 'HUB_PARTY_BK__EMP_CODE'},
            {'src_expr': 'quote_ref', 'tgt': 'HUB_QUOTE_BK__QUOTE_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ECARD_MEMBR_DEL_DTLS'
    },
    {
        'model': 'stg_hm_hcs_tech_assess_cov',
        'alias': 't30',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'id_card_no', 'tgt': 'health_card_number'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': "nullif('HEALTHCARD:' || nullif(trim(ID_CARD_NO),''), 'HEALTHCARD:')", 'tgt': 'HUB_RISK_OBJECT_BK__HEALTHCARD_ID_CARD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_HCS_TECH_ASSESS_COV'
    },
    {
        'model': 'stg_remedinet_patient_details',
        'alias': 't31',
        'key_column': 'HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'relationship_name', 'tgt': 'relationship_to_proposer'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('REMEDINET_REQ:' || nullif(trim(REQUESTID),''), 'REMEDINET_REQ:')", 'tgt': 'HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(ADDRESS1),''),'') || '|' || coalesce(nullif(trim(ADDRESS2),''),'') || '|' || coalesce(nullif(trim(ADDRESS3),''),'') || '|' || coalesce(nullif(trim(CITY),''),'') || '|' || coalesce(nullif(trim(STATE),''),'') || '|' || coalesce(nullif(trim(PIN_CODE),''),''), '|||||'))))", 'tgt': 'HUB_LOCATION_BK__ADDRESS1_ADDRESS2_ADDRESS3_CITY'},
            {'src_expr': "nullif('MEMBER:' || nullif(trim(MEMBER_NO),''), 'MEMBER:')", 'tgt': 'HUB_PARTY_BK__MEMBER_MEMBER_NO'},
            {'src_expr': "nullif('MEMBER:' || nullif(trim(MEMBER_NO),''), 'MEMBER:')", 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_REMEDINET_PATIENT_DETAILS'
    }
] -%}

{%- set output_columns = [
    'age_proof_submitted_indicator', 'body_mass_index', 'cumulative_bonus_applicable_indicator', 'declared_claim_history_detail', 'declared_prior_claim_amount', 'family_medical_history_detail', 'family_medical_history_indicator', 'health_card_number', 'health_card_status', 'height', 'insured_person_premium_amount', 'member_loading_amount', 'member_loading_applied_indicator', 'member_risk_loading_amount', 'member_risk_loading_percentage', 'member_special_condition', 'member_type', 'occupation_risk_class', 'other_health_declaration_detail', 'other_health_details', 'pre_existing_disease_description', 'pre_existing_disease_indicator', 'previous_sum_insured', 'relationship_to_proposer', 'smoker_indicator', 'weight'
] -%}

{%- set coalesce_rules = {
    'age_proof_submitted_indicator': ['t22'],
    'body_mass_index': ['t22', 't3', 't4', 't5', 't24'],
    'cumulative_bonus_applicable_indicator': ['t1'],
    'declared_claim_history_detail': ['t22'],
    'declared_prior_claim_amount': ['t22'],
    'family_medical_history_detail': ['t22'],
    'family_medical_history_indicator': ['t22'],
    'health_card_number': ['t30', 't26', 't11', 't17', 't18', 't19', 't20', 't21', 't23'],
    'health_card_status': ['t26'],
    'height': ['t22', 't2', 't3', 't4', 't5', 't9', 't10', 't14', 't24', 't0'],
    'insured_person_premium_amount': ['t0'],
    'member_loading_amount': ['t13'],
    'member_loading_applied_indicator': ['t22'],
    'member_risk_loading_amount': ['t21'],
    'member_risk_loading_percentage': ['t22', 't12', 't13', 't21', 't24', 't27'],
    'member_special_condition': ['t4'],
    'member_type': ['t18', 't21'],
    'occupation_risk_class': ['t15', 't21'],
    'other_health_declaration_detail': ['t22'],
    'other_health_details': ['t24'],
    'pre_existing_disease_description': ['t22', 't2', 't3', 't4', 't7', 't9', 't10', 't12', 't13', 't14', 't16', 't24', 't27', 't0'],
    'pre_existing_disease_indicator': ['t0'],
    'previous_sum_insured': ['t22'],
    'relationship_to_proposer': ['t2', 't5', 't6', 't8', 't29', 't9', 't10', 't11', 't12', 't13', 't14', 't16', 't18', 't21', 't23', 't24', 't25', 't27', 't28', 't0', 't31'],
    'smoker_indicator': ['t22', 't3', 't4', 't9', 't12', 't24', 't27'],
    'weight': ['t22', 't2', 't3', 't4', 't5', 't9', 't10', 't14', 't24', 't0']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t1.HUB_ASSESSMENT_BK__SCRUTINY_NO, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t3.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t4.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t5.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t7.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t7.HUB_CLAIM_BK__REFERENCE_ID, t17.HUB_CLAIM_BK__CLAIM_ID, t18.HUB_CLAIM_BK__CLAIM_ID, t20.HUB_CLAIM_BK__CLAIM_ID, t23.HUB_CLAIM_BK__CLAIM_ID, t28.HUB_CLAIM_BK__BJAZ_CLAIM_ID, t30.HUB_CLAIM_BK__CLAIM_ID, t31.HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 't15.HUB_COVERAGE_BK__COVER_CODE'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t1.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t8.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t9.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t10.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t12.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t14.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t15.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t16.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t21.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t24.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t26.HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO, t27.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t28.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t8.HUB_DOCUMENT_BK__CARD_NO, t9.HUB_DOCUMENT_BK__MEDICAL_REPORT, t20.HUB_DOCUMENT_BK__INWARD_ID, t24.HUB_DOCUMENT_BK__MEDICAL_REPORT, t27.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t2.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t3.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t4.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t5.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t10.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER, t14.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER, t21.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 't28.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY'},
    {'name': 'HUB_LOCATION_BK', 'expr': 'coalesce(t7.HUB_LOCATION_BK__LOCATION_CODE, t22.HUB_LOCATION_BK__HAT_ID_CITY_HAT_ID_STATE, t26.HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE, t31.HUB_LOCATION_BK__ADDRESS1_ADDRESS2_ADDRESS3_CITY)'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t20.HUB_LOSS_EVENT_BK__CLAIM_ID, t28.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t3.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t4.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t5.HUB_ORG_UNIT_BK__PD_LOCATION_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t6.HUB_PARTY_BK__EMP_CODE, t7.HUB_PARTY_BK__CUSTOMER_ID, t9.HUB_PARTY_BK__MEMBER_NO, t10.HUB_PARTY_BK__USER_ID, t11.HUB_PARTY_BK__MEMBER_NO, t12.HUB_PARTY_BK__MEMBER_NO, t13.HUB_PARTY_BK__PART_ID, t14.HUB_PARTY_BK__CLIENT_ID, t15.HUB_PARTY_BK__PART_ID, t16.HUB_PARTY_BK__MEMBER_NO, t17.HUB_PARTY_BK__HOSPITAL_ID, t18.HUB_PARTY_BK__LDR_PID, t20.HUB_PARTY_BK__COURIER_ID, t21.HUB_PARTY_BK__MEMBER_ID, t24.HUB_PARTY_BK__MEMBER_NO, t27.HUB_PARTY_BK__MEMBER_NO, t29.HUB_PARTY_BK__EMP_CODE, t31.HUB_PARTY_BK__MEMBER_MEMBER_NO)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 't28.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__CONTRACT_ID, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__POL_SERIAL_NO, t4.HUB_POLICY_BK__POL_SERIAL_NO, t5.HUB_POLICY_BK__POL_SERIAL_NO, t6.HUB_POLICY_BK__POLICY_NO, t7.HUB_POLICY_BK__POLICY_REF, t8.HUB_POLICY_BK__POLICY_REF, t9.HUB_POLICY_BK__CONTRACT_ID, t10.HUB_POLICY_BK__MASTER_POLICY_NO, t11.HUB_POLICY_BK__CONTRACT_ID, t12.HUB_POLICY_BK__CONTRACT_ID, t13.HUB_POLICY_BK__CONTRACT_ID, t14.HUB_POLICY_BK__REFERENCE_ID, t15.HUB_POLICY_BK__CONTRACT_ID, t16.HUB_POLICY_BK__CONTRACT_ID, t17.HUB_POLICY_BK__POLICY_REF, t18.HUB_POLICY_BK__POLICY_REF, t19.HUB_POLICY_BK__POLICY_NO, t20.HUB_POLICY_BK__POLICY_REF, t21.HUB_POLICY_BK__CONTRACT_ID, t22.HUB_POLICY_BK__CONTRACT_ID, t23.HUB_POLICY_BK__POLICY_NUMBER, t24.HUB_POLICY_BK__CONTRACT_ID, t25.HUB_POLICY_BK__CONTRACT_ID, t26.HUB_POLICY_BK__POLICY_REF, t27.HUB_POLICY_BK__CONTRACT_ID, t28.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t3.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t4.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t5.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t10.HUB_PRODUCT_BK__PRODUCT_CODE, t14.HUB_PRODUCT_BK__PRODUCT_CODE, t15.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t18.HUB_PRODUCT_BK__PROD_CD, t21.HUB_PRODUCT_BK__PRODUCT_CODE)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t14.HUB_PROPOSAL_BK__BA_LEAD_NO, t15.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t15.HUB_QUOTE_BK__QUOTE_REF_NO, t29.HUB_QUOTE_BK__QUOTE_REF)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t0.HUB_RISK_OBJECT_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME, t2.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t4.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t9.HUB_RISK_OBJECT_BK__MEMBER_NO, t12.HUB_RISK_OBJECT_BK__MEMBER_NO, t22.HUB_RISK_OBJECT_BK__MEMBER_CONTRACT_ID_MEMBER_ID, t26.HUB_RISK_OBJECT_BK__CUSTID_CUST_ID, t30.HUB_RISK_OBJECT_BK__HEALTHCARD_ID_CARD_NO, t31.HUB_RISK_OBJECT_BK__MEMBER_MEMBER_NO)'},
    {'name': 'T0__HUB_PARTY_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME', 'expr': 't0.HUB_PARTY_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME'},
    {'name': 'T0__HUB_PARTY_BK__CONTRACT_ID_NOMINEE_NOMINEE_NAME', 'expr': 't0.HUB_PARTY_BK__CONTRACT_ID_NOMINEE_NOMINEE_NAME'},
    {'name': 'T2__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't2.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T3__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't3.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T3__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't3.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T3__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't3.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T4__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't4.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T4__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't4.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T4__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't4.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T5__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't5.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T5__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't5.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T5__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't5.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T7__HUB_PRODUCT_BK__PLAN_ID', 'expr': 't7.HUB_PRODUCT_BK__PLAN_ID'},
    {'name': 'T7__HUB_PRODUCT_BK__PRODUCT_CODE', 'expr': 't7.HUB_PRODUCT_BK__PRODUCT_CODE'},
    {'name': 'T10__HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER', 'expr': 't10.HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER'},
    {'name': 'T10__HUB_PROPOSAL_BK__REFERENCE_ID', 'expr': 't10.HUB_PROPOSAL_BK__REFERENCE_ID'},
    {'name': 'T15__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't15.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T15__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't15.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T20__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't20.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T20__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't20.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T20__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't20.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T20__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't20.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T20__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't20.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T23__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't23.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T23__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't23.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T23__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't23.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T23__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't23.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T23__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't23.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T26__HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME', 'expr': 't26.HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME'},
    {'name': 'T26__HUB_PARTY_BK__CUST_ID', 'expr': 't26.HUB_PARTY_BK__CUST_ID'},
    {'name': 'T28__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't28.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T28__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't28.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T28__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't28.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T28__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't28.HUB_PARTY_BK__HOSPITAL_CODE'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_risk_person_insured'
) }}
