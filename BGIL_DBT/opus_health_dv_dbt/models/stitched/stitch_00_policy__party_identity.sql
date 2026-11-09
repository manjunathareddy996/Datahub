/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Batch task 5.1. Procedure: the stitch_01 pilot's 9-step REUSABLE PROCEDURE.
   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_party_identity
   GRAIN DEVIATIONS (source has no spine-hub key; keyed on its real join col):
     - t44 (stg_bot_utilization_dtls): no HUB_POLICY key; key_column=HUB_DISTRIBUTION_CHANNEL_BK__CHATBOT_CHATBOT_ID (real join key)
     - t46 (stg_hat_ocr_fina_dtls_lst): no HUB_POLICY key; key_column=HUB_CLAIM_BK__CASE_ID (real join key)
     - t47 (stg_hm_hospital_master): no HUB_POLICY key; key_column=HUB_AGREEMENT_BK__HOSID (real join key)
     - t48 (stg_hm_hospital_master_extn): no HUB_POLICY key; key_column=HUB_AGREEMENT_BK__HOSID (real join key)
     - t49 (stg_hm_hosp_master_extn1): no HUB_POLICY key; key_column=HUB_AGREEMENT_BK__HOSID (real join key)
     - t50 (stg_hm_preauth_request): no HUB_POLICY key; key_column=HUB_CLAIM_BK__CLAIM_ID (real join key)
     - t51 (stg_intermediary): no HUB_POLICY key; key_column=HUB_PARTY_BK__INTERMEDIARY_ID (real join key)
     - t52 (stg_remedinet_patient_details): no HUB_POLICY key; key_column=HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID (real join key)
     - t53 (stg_scr_hlth_portable_dtls): no HUB_POLICY key; key_column=HUB_ASSESSMENT_BK__SCRUTINY_NO (real join key)
   SAME-ALIAS PAYLOAD DROPS (macro emits one col per alias per tgt; secondary dropped):
     - date_of_birth: kept t25.date_of_birth, dropped-secondary t25.date_of_birth_m
     - party_full_name: kept t17.imd_name, dropped-secondary t17.ph_name
     - party_full_name: kept t17.imd_name, dropped-secondary t17.pp_name
     - party_full_name: kept t17.imd_name, dropped-secondary t17.rm_contact_detls
     - party_full_name: kept t17.imd_name, dropped-secondary t17.rm_name
     - party_full_name: kept t17.imd_name, dropped-secondary t17.subimd_name
     - party_full_name: kept t38.accountholdername, dropped-secondary t38.nomineename
     - party_full_name: kept t4.imd_name, dropped-secondary t4.member_name
     - party_full_name: kept t6.dc_name, dropped-secondary t6.member_name
     - party_full_name: kept t8.md_nominee, dropped-secondary t8.pd_bagic_rm_name
     - party_full_name: kept t8.md_nominee, dropped-secondary t8.pd_imd_rm_name
     - party_full_name: kept t9.md_nominee, dropped-secondary t9.pd_bagic_rm_name
     - party_full_name: kept t9.md_nominee, dropped-secondary t9.pd_imd_rm_name
     - party_full_name: kept t10.md_nominee, dropped-secondary t10.plc_name_of_assignee
     - party_full_name: kept t10.md_nominee, dropped-secondary t10.plc_name_of_assignor
     - party_full_name: kept t12.customer_name, dropped-secondary t12.nominee_name
     - party_full_name: kept t15.assignee, dropped-secondary t15.name
     - party_full_name: kept t19.bagic_rm_name, dropped-secondary t19.imd_name
     - party_full_name: kept t19.bagic_rm_name, dropped-secondary t19.sub_imd_name
     - party_full_name: kept t20.customer_name, dropped-secondary t20.nominee_name
     - party_full_name: kept t21.beneficiary, dropped-secondary t21.contact_person
     - party_full_name: kept t45.alternate_responsible, dropped-secondary t45.beneficiary
     - party_full_name: kept t45.alternate_responsible, dropped-secondary t45.originator
     - party_full_name: kept t45.alternate_responsible, dropped-secondary t45.person_resp
     - party_full_name: kept t45.alternate_responsible, dropped-secondary t45.stake_holder_name
     - party_full_name: kept t45.alternate_responsible, dropped-secondary t45.user_name
     - party_full_name: kept t22.imd_name, dropped-secondary t22.rm_name
     - party_full_name: kept t22.imd_name, dropped-secondary t22.sub_imd_name
     - party_full_name: kept t23.assignee, dropped-secondary t23.emp_name
     - party_full_name: kept t24.assignee, dropped-secondary t24.insured_name
     - party_full_name: kept t25.assignee_name, dropped-secondary t25.hospital
     - party_full_name: kept t25.assignee_name, dropped-secondary t25.member_name
     - party_full_name: kept t26.customer_name, dropped-secondary t26.nominee_name
     - party_full_name: kept t28.assignee, dropped-secondary t28.name
     - party_full_name: kept t30.emp_name, dropped-secondary t30.name
     - party_full_name: kept t30.emp_name, dropped-secondary t30.name_of_hospital
     - party_full_name: kept t31.ben_name, dropped-secondary t31.hospital_name
     - party_full_name: kept t32.employee_name, dropped-secondary t32.hospital
     - party_full_name: kept t32.employee_name, dropped-secondary t32.insured
     - party_full_name: kept t32.employee_name, dropped-secondary t32.name_dr
     - party_full_name: kept t32.employee_name, dropped-secondary t32.patient
     - party_full_name: kept t48.admission_person, dropped-secondary t48.auth_signatory
     - party_full_name: kept t48.admission_person, dropped-secondary t48.billing_person
     - party_full_name: kept t48.admission_person, dropped-secondary t48.closure_by
     - party_full_name: kept t48.admission_person, dropped-secondary t48.initiated_by
     - party_full_name: kept t48.admission_person, dropped-secondary t48.referral_by
     - party_full_name: kept t33.member_name, dropped-secondary t33.proposer_name
     - party_full_name: kept t33.member_name, dropped-secondary t33.sender_name
     - party_full_name: kept t34.assignee_name, dropped-secondary t34.member_name
     - party_full_name: kept t35.employee_name, dropped-secondary t35.patient_name
     - party_full_name: kept t36.assignee, dropped-secondary t36.name
     - party_full_name: kept t40.corporate_name, dropped-secondary t40.insurance_company
     - party_full_name: kept t40.corporate_name, dropped-secondary t40.payer_name
     - party_full_name: kept t40.corporate_name, dropped-secondary t40.provider_name
     - party_full_name: kept t41.assignee, dropped-secondary t41.doctor_name
     - party_full_name: kept t41.assignee, dropped-secondary t41.name
     - party_full_name: kept t42.claim_payable_beneficiary, dropped-secondary t42.hospital_name
     - party_full_name: kept t42.claim_payable_beneficiary, dropped-secondary t42.insurance_company
     - party_full_name: kept t42.claim_payable_beneficiary, dropped-secondary t42.patient_name
     - party_full_name: kept t42.claim_payable_beneficiary, dropped-secondary t42.proposer_name
     - party_full_name: kept t44.cust_name, dropped-secondary t44.user_name
     - party_legal_name: kept t21.institition, dropped-secondary t21.name_of_corporate
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_ba_ccp_insured_details',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'first_name', 'tgt': 'first_name'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'last_name', 'tgt': 'last_name'},
            {'src': 'middle_name', 'tgt': 'middle_name'},
            {'src': 'nominee_name', 'tgt': 'party_full_name'}
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
        'model': 'stg_hcp_dt_mem',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno', 'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_MEM'
    },
    {
        'model': 'stg_hcp_dt_mem_cov',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno', 'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_MEM_COV'
    },
    {
        'model': 'stg_hcp_dt_pol_cov',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno', 'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_POL_COV'
    },
    {
        'model': 'stg_hcp_pol_mst',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'imd_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'child_loc_code', 'tgt': 'HUB_LOCATION_BK__CHILD_LOC_CODE'},
            {'src_expr': 'user_id', 'tgt': 'HUB_PARTY_BK__USER_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_POL_MST'
    },
    {
        'model': 'stg_hcp_port_wordings',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'mem_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PORT_WORDINGS'
    },
    {
        'model': 'stg_hcp_pp_mem_dtls',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'dc_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'alloted_to', 'tgt': 'HUB_PARTY_BK__ALLOTED_TO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'hi_control_number', 'tgt': 'HUB_PROPOSAL_BK__HI_CONTROL_NUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PP_MEM_DTLS'
    },
    {
        'model': 'stg_hcp_prod_8428_gpg_loader',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'md_first_name', 'tgt': 'first_name'},
            {'src': 'md_gender', 'tgt': 'gender_code'},
            {'src': 'md_last_name', 'tgt': 'last_name'},
            {'src': 'md_middle_name', 'tgt': 'middle_name'},
            {'src': 'md_nominee', 'tgt': 'party_full_name'}
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
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'md_first_name', 'tgt': 'first_name'},
            {'src': 'md_gender', 'tgt': 'gender_code'},
            {'src': 'md_last_name', 'tgt': 'last_name'},
            {'src': 'md_middle_name', 'tgt': 'middle_name'},
            {'src': 'md_nominee', 'tgt': 'party_full_name'}
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
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'md_first_name', 'tgt': 'first_name'},
            {'src': 'md_gender', 'tgt': 'gender_code'},
            {'src': 'md_last_name', 'tgt': 'last_name'},
            {'src': 'md_middle_name', 'tgt': 'middle_name'},
            {'src': 'md_nominee', 'tgt': 'party_full_name'},
            {'src': 'plc_institution_name', 'tgt': 'party_legal_name'}
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
        'alias': 't10',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'md_first_name', 'tgt': 'first_name'},
            {'src': 'md_gender', 'tgt': 'gender_code'},
            {'src': 'md_last_name', 'tgt': 'last_name'},
            {'src': 'md_middle_name', 'tgt': 'middle_name'},
            {'src': 'md_nominee', 'tgt': 'party_full_name'}
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
        'alias': 't11',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'emp_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'emp_code', 'tgt': 'HUB_PARTY_BK__EMP_CODE'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BGIL_GMC_FINAL_INSTL_DATA'
    },
    {
        'model': 'stg_bandhan_medi_clam',
        'alias': 't12',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'first_name', 'tgt': 'first_name'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'last_name', 'tgt': 'last_name'},
            {'src': 'middle_name', 'tgt': 'middle_name'},
            {'src': 'customer_name', 'tgt': 'party_full_name'}
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
        'alias': 't13',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'member_name', 'tgt': 'party_full_name'},
            {'src': 'company_name', 'tgt': 'party_legal_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'card_no', 'tgt': 'HUB_DOCUMENT_BK__CARD_NO'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_CARD_DTLS'
    },
    {
        'model': 'stg_ecard_pol_dtls_config',
        'alias': 't14',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'corporate_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'quote_ref', 'tgt': 'HUB_QUOTE_BK__QUOTE_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ECARD_POL_DTLS_CONFIG'
    },
    {
        'model': 'stg_ec_mem_dtls_extn',
        'alias': 't15',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'assignee', 'tgt': 'party_full_name'}
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
        'model': 'stg_ehh_pol_dtls',
        'alias': 't16',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'first_name', 'tgt': 'first_name'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'last_name', 'tgt': 'last_name'},
            {'src': 'middle_name', 'tgt': 'middle_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode', 'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc', 'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'company_org_unit', 'tgt': 'HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'product_4digit_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_EHH_POL_DTLS'
    },
    {
        'model': 'stg_enroll_pol_dtls',
        'alias': 't17',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'imd_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(trim( coalesce(ADDRESS_LINE1,'') || '|' || coalesce(CORP_CITY,'') || '|' || coalesce(CORP_PIN,'') ), '||'))))", 'tgt': 'HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN'},
            {'src_expr': "md5(normalise(upper(nullif(trim( coalesce(PH_ADDRESS,'') ), ''))))", 'tgt': 'HUB_LOCATION_BK__PH_ADDRESS'},
            {'src_expr': "md5(normalise(upper(nullif(trim( coalesce(PP_ADDRESS,'') ), ''))))", 'tgt': 'HUB_LOCATION_BK__PP_ADDRESS'},
            {'src_expr': "nullif('EMP:' || nullif(trim(RM_CODE),''), 'EMP:')", 'tgt': 'HUB_PARTY_BK__EMP_RM_CODE'},
            {'src_expr': "nullif(trim(CORPORATE_ID),'')", 'tgt': 'HUB_PARTY_BK__CORPORATE_ID'},
            {'src_expr': "nullif(trim(IMD_CODE),'')", 'tgt': 'HUB_PARTY_BK__IMD_CODE'},
            {'src_expr': "nullif(trim(PH_ID),'')", 'tgt': 'HUB_PARTY_BK__PH_ID'},
            {'src_expr': "nullif(trim(PP_ID),'')", 'tgt': 'HUB_PARTY_BK__PP_ID'},
            {'src_expr': "nullif(trim(SUBIMD_CODE),'')", 'tgt': 'HUB_PARTY_BK__SUBIMD_CODE'},
            {'src_expr': "nullif(trim(POLICY_NO),'')", 'tgt': 'HUB_POLICY_BK__POLICY_NO'},
            {'src_expr': "nullif(trim(SCRUTINY_NO),'')", 'tgt': 'HUB_PROPOSAL_BK__SCRUTINY_NO'},
            {'src_expr': "nullif(trim(QUOTATION_NO),'')", 'tgt': 'HUB_QUOTE_BK__QUOTATION_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_ENROLL_POL_DTLS'
    },
    {
        'model': 'stg_generic_loader_log_table',
        'alias': 't18',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dateofbirth', 'tgt': 'date_of_birth'},
            {'src': 'firstname', 'tgt': 'first_name'},
            {'src': 'sex', 'tgt': 'gender_code'},
            {'src': 'surname', 'tgt': 'last_name'},
            {'src': 'middlename', 'tgt': 'middle_name'},
            {'src': 'assignee', 'tgt': 'party_full_name'},
            {'src': 'companyname', 'tgt': 'party_legal_name'},
            {'src': 'title', 'tgt': 'salutation'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partnerid', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode', 'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc', 'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'pmasterpolicynumber', 'tgt': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER'},
            {'src_expr': 'planid', 'tgt': 'HUB_PRODUCT_BK__PLANID'},
            {'src_expr': 'schemecode', 'tgt': 'HUB_PRODUCT_BK__SCHEMECODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GENERIC_LOADER_LOG_TABLE'
    },
    {
        'model': 'stg_gpg_pol_dtls',
        'alias': 't19',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'bagic_rm_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'imd_code', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'lms_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__LMS_NO'},
            {'src_expr': 'company_org_unit', 'tgt': 'HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
            {'src_expr': 'bagic_e_code', 'tgt': 'HUB_PARTY_BK__BAGIC_E_CODE'},
            {'src_expr': 'bagic_rm_e_code', 'tgt': 'HUB_PARTY_BK__BAGIC_RM_E_CODE'},
            {'src_expr': 'imd_code', 'tgt': 'HUB_PARTY_BK__IMD_CODE'},
            {'src_expr': 'sub_imd_code', 'tgt': 'HUB_PARTY_BK__SUB_IMD_CODE'},
            {'src_expr': 'reference_id', 'tgt': 'HUB_POLICY_BK__REFERENCE_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 're_insu', 'tgt': 'HUB_REINSURANCE_TREATY_BK__RE_INSU'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GPG_POL_DTLS'
    },
    {
        'model': 'stg_gp_hospital_cash',
        'alias': 't20',
        'key_column': 'HUB_POLICY_BK__MASTER_POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'customer_name', 'tgt': 'party_full_name'},
            {'src': 'customer_type', 'tgt': 'party_type_code'}
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
        'model': 'stg_grp_hlt_cust_dtls',
        'alias': 't21',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'first_name', 'tgt': 'first_name'},
            {'src': 'last_name', 'tgt': 'last_name'},
            {'src': 'middle_name', 'tgt': 'middle_name'},
            {'src': 'beneficiary', 'tgt': 'party_full_name'},
            {'src': 'institition', 'tgt': 'party_legal_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'reg_no', 'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product', 'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_CUST_DTLS'
    },
    {
        'model': 'stg_grp_hlt_imd_dtls',
        'alias': 't22',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'imd_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'imd_code', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'imd_code', 'tgt': 'HUB_PARTY_BK__IMD_CODE'},
            {'src_expr': 'rm_code', 'tgt': 'HUB_PARTY_BK__RM_CODE'},
            {'src_expr': 'sub_imd_code', 'tgt': 'HUB_PARTY_BK__SUB_IMD_CODE'},
            {'src_expr': 'reg_no', 'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product', 'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_IMD_DTLS'
    },
    {
        'model': 'stg_hat_id_mem_detls',
        'alias': 't23',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'first_name', 'tgt': 'first_name'},
            {'src': 'sex', 'tgt': 'gender_code'},
            {'src': 'last_name', 'tgt': 'last_name'},
            {'src': 'middle_name', 'tgt': 'middle_name'},
            {'src': 'assignee', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HAT_ID_MEM_DETLS'
    },
    {
        'model': 'stg_hcf_member_dtls',
        'alias': 't24',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'assignee', 'tgt': 'party_full_name'},
            {'src': 'company_name', 'tgt': 'party_legal_name'}
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
        'alias': 't25',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'sex', 'tgt': 'gender_code'},
            {'src': 'assignee_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_hdfc_sec_fhpp',
        'alias': 't26',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'customer_name', 'tgt': 'party_full_name'},
            {'src': 'customer_type', 'tgt': 'party_type_code'}
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
        'alias': 't27',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'first_name', 'tgt': 'first_name'},
            {'src': 'last_name', 'tgt': 'last_name'},
            {'src': 'ind_national_card_holders', 'tgt': 'national_card_holder_indicator'}
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
        'alias': 't28',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'assignee', 'tgt': 'party_full_name'}
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
        'alias': 't29',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'patient_name', 'tgt': 'party_full_name'}
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
        'alias': 't30',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'sex', 'tgt': 'gender_code'},
            {'src': 'emp_name', 'tgt': 'party_full_name'},
            {'src': 'name_coinsr_co', 'tgt': 'party_legal_name'}
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
        'alias': 't31',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'ben_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_GMC_AHC'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't32',
        'key_column': 'HUB_POLICY_BK__POLICY',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'processor', 'tgt': 'party_display_name'},
            {'src': 'employee_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'clid', 'tgt': 'HUB_CLAIM_BK__CLID'},
            {'src_expr': 'imd_code', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'bank_ac_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
            {'src_expr': 'utr_no', 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__UTR_NO'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode', 'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc', 'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'claim_no', 'tgt': 'HUB_LOSS_EVENT_BK__CLAIM_NO'},
            {'src_expr': 'hospital_id', 'tgt': 'HUB_PARTY_BK__HOSPITAL_ID'},
            {'src_expr': 'cheque_no', 'tgt': 'HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
            {'src_expr': 'policy', 'tgt': 'HUB_POLICY_BK__POLICY'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HCM_EXTRACT'
    },
    {
        'model': 'stg_hm_inward_dtls',
        'alias': 't33',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_name', 'tgt': 'party_full_name'}
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
        'alias': 't34',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'old_member_no', 'tgt': 'legacy_member_number'},
            {'src': 'assignee_name', 'tgt': 'party_full_name'}
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
        'model': 'stg_hm_orphan_reg',
        'alias': 't35',
        'key_column': 'HUB_POLICY_BK__POLICY_NUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'employee_name', 'tgt': 'party_full_name'},
            {'src': 'company_name', 'tgt': 'party_legal_name'}
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
        'alias': 't36',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'assignee', 'tgt': 'party_full_name'},
            {'src': 'company_name', 'tgt': 'party_legal_name'}
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
        'alias': 't37',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'nominee_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ILLNESS_BASES_EXTN'
    },
    {
        'model': 'stg_pmsby_data_web_service',
        'alias': 't38',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'nomineeage', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'accountholdername', 'tgt': 'party_full_name'}
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
        'model': 'stg_policy_summary',
        'alias': 't39',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'insured_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(ADDRESS),''),'') || '|' || coalesce(nullif(trim(CITY),''),'') || '|' || coalesce(nullif(trim(REGION),''),''), '||'))))", 'tgt': 'HUB_LOCATION_BK__ADDRESS_CITY_REGION'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(INSURED_ADDRESS),''),'') || '|' || coalesce(nullif(trim(PINCODE),''),''), '|'))))", 'tgt': 'HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE'},
            {'src_expr': "md5(normalise(upper(nullif(trim(MAILING_PINCODE),''))))", 'tgt': 'HUB_LOCATION_BK__MAILING_PINCODE'},
            {'src_expr': "nullif(trim(BRANCH_CODE),'')", 'tgt': 'HUB_ORG_UNIT_BK__BRANCH_CODE'},
            {'src_expr': "nullif(trim(DEPARTMENT_CODE),'')", 'tgt': 'HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(CONTRACT_ID),''),'') || '|INSURED|' || coalesce(nullif(trim(INSURED_NAME),''),''), '|INSURED|'))))", 'tgt': 'HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME'},
            {'src_expr': "nullif('PARTID:' || nullif(trim(PART_ID),''), 'PARTID:')", 'tgt': 'HUB_PARTY_BK__PARTID_PART_ID'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(PRODUCT_CODE),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_POLICY_SUMMARY'
    },
    {
        'model': 'stg_remedinet_claim_details',
        'alias': 't40',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'corporate_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'remedinet_provider_code', 'tgt': 'HUB_AGREEMENT_BK__REMEDINET_PROVIDER_CODE'},
            {'src_expr': 'claim_no', 'tgt': 'HUB_CLAIM_BK__CLAIM_NO'},
            {'src_expr': 'omni_inward_no', 'tgt': 'HUB_DOCUMENT_BK__OMNI_INWARD_NO'},
            {'src_expr': 'payer_code', 'tgt': 'HUB_PARTY_BK__PAYER_CODE'},
            {'src_expr': 'remedinet_provider_code', 'tgt': 'HUB_PARTY_BK__REMEDINET_PROVIDER_CODE'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_REMEDINET_CLAIM_DETAILS'
    },
    {
        'model': 'stg_sh_mem_dtls_extn',
        'alias': 't41',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'assignee', 'tgt': 'party_full_name'},
            {'src': 'company_name', 'tgt': 'party_legal_name'}
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
        'alias': 't42',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'patient_age', 'tgt': 'age'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'claim_payable_beneficiary', 'tgt': 'party_full_name'}
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
        'model': 'stg_ocp_interested_parties',
        'alias': 't43',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'customer_name_text', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('ADDRID:' || nullif(trim(MAILING_ADDRESS_ID),''), 'ADDRID:')", 'tgt': 'HUB_LOCATION_BK__ADDRID_MAILING_ADDRESS_ID'},
            {'src_expr': "nullif('PARTNER:' || nullif(trim(PARTNER_ID),''), 'PARTNER:')", 'tgt': 'HUB_PARTY_BK__PARTNER_PARTNER_ID'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_OCP_INTERESTED_PARTIES'
    },
    {
        'model': 'stg_bot_utilization_dtls',
        'alias': 't44',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__CHATBOT_CHATBOT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'cust_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('CHATBOT:' || nullif(trim(chatbot_id),''), 'CHATBOT:')", 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__CHATBOT_CHATBOT_ID'},
            {'src_expr': "md5(normalise(upper(nullif(trim(pincode),''))))", 'tgt': 'HUB_LOCATION_BK__PINCODE'},
            {'src_expr': "nullif(trim(branch_code),'')", 'tgt': 'HUB_ORG_UNIT_BK__BRANCH_CODE'},
            {'src_expr': "md5(normalise(upper(nullif(trim(cust_name),''))))", 'tgt': 'HUB_PARTY_BK__CUST_NAME'},
            {'src_expr': "md5(normalise(upper(nullif(trim(user_name),''))))", 'tgt': 'HUB_PARTY_BK__USER_NAME'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(product_code),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_BOT_UTILIZATION_DTLS'
    },
    {
        'model': 'stg_grp_hlt_dtls',
        'alias': 't45',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'alternate_responsible', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'branch', 'tgt': 'HUB_ORG_UNIT_BK__BRANCH'},
            {'src_expr': 'department', 'tgt': 'HUB_ORG_UNIT_BK__DEPARTMENT'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'},
            {'src_expr': 'prev_pol_ref', 'tgt': 'HUB_POLICY_BK__PREV_POL_REF'},
            {'src_expr': 'reg_no', 'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product', 'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_ref_no', 'tgt': 'HUB_PROPOSAL_BK__QUOTE_REF_NO'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_DTLS'
    },
    {
        'model': 'stg_hat_ocr_fina_dtls_lst',
        'alias': 't46',
        'key_column': 'HUB_CLAIM_BK__CASE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'case_id', 'tgt': 'HUB_CLAIM_BK__CASE_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HAT_OCR_FINA_DTLS_LST'
    },
    {
        'model': 'stg_hm_hospital_master',
        'alias': 't47',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'hospital_name', 'tgt': 'party_full_name'},
            {'src': 'hosp_type', 'tgt': 'party_sub_type_code'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'pin_code', 'tgt': 'HUB_LOCATION_BK__PIN_CODE'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSPITAL_MASTER'
    },
    {
        'model': 'stg_hm_hospital_master_extn',
        'alias': 't48',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'admission_person', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'distribution_partner', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSPITAL_MASTER_EXTN'
    },
    {
        'model': 'stg_hm_hosp_master_extn1',
        'alias': 't49',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'delistedhosp', 'tgt': 'party_status'},
            {'src': 'delistedhospreason', 'tgt': 'party_status_reason'},
            {'src': 'hospcatg', 'tgt': 'party_sub_type_code'},
            {'src': 'pcatghosp', 'tgt': 'party_type_code'},
            {'src': 'reactidate', 'tgt': 'reactivation_date'},
            {'src': 'hosstatusremark', 'tgt': 'status_remark'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSP_MASTER_EXTN1'
    },
    {
        'model': 'stg_hm_preauth_request',
        'alias': 't50',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age_in_years', 'tgt': 'age'},
            {'src': 'age_in_mon', 'tgt': 'age_residual_months'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'patient_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': "nullif('FIR:' || nullif(trim(FIR_NO),''), 'FIR:')", 'tgt': 'HUB_DOCUMENT_BK__FIR_FIR_NO'},
            {'src_expr': "nullif('OMNI_INWARD:' || nullif(trim(OMNI_INWARD_NO),''), 'OMNI_INWARD:')", 'tgt': 'HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO'},
            {'src_expr': "nullif('HEALTHCARD:' || nullif(trim(INSURED_CARD_NO),''), 'HEALTHCARD:')", 'tgt': 'HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO'},
            {'src_expr': "nullif('HEALTHCARD:' || nullif(trim(PATIENT_ID_CARD),''), 'HEALTHCARD:')", 'tgt': 'HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD'},
            {'src_expr': "nullif('HOSPID:' || nullif(trim(HOS_ID),''), 'HOSPID:')", 'tgt': 'HUB_PARTY_BK__HOSPID_HOS_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_PREAUTH_REQUEST'
    },
    {
        'model': 'stg_intermediary',
        'alias': 't51',
        'key_column': 'HUB_PARTY_BK__INTERMEDIARY_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'intermediary_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(BUSINESS_CHANNEL),'')", 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL'},
            {'src_expr': "nullif(trim(NEW_BC),'')", 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC'},
            {'src_expr': "nullif(trim(INTERMEDIARY_ID),'')", 'tgt': 'HUB_PARTY_BK__INTERMEDIARY_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_INTERMEDIARY'
    },
    {
        'model': 'stg_remedinet_patient_details',
        'alias': 't52',
        'key_column': 'HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age_year', 'tgt': 'age'},
            {'src': 'age_day', 'tgt': 'age_days_component'},
            {'src': 'age_month', 'tgt': 'age_months_component'},
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'first_name', 'tgt': 'first_name'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'last_name', 'tgt': 'last_name'},
            {'src': 'middle_name', 'tgt': 'middle_name'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('REMEDINET_REQ:' || nullif(trim(REQUESTID),''), 'REMEDINET_REQ:')", 'tgt': 'HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(ADDRESS1),''),'') || '|' || coalesce(nullif(trim(ADDRESS2),''),'') || '|' || coalesce(nullif(trim(ADDRESS3),''),'') || '|' || coalesce(nullif(trim(CITY),''),'') || '|' || coalesce(nullif(trim(STATE),''),'') || '|' || coalesce(nullif(trim(PIN_CODE),''),''), '|||||'))))", 'tgt': 'HUB_LOCATION_BK__ADDRESS1_ADDRESS2_ADDRESS3_CITY'},
            {'src_expr': "nullif('MEMBER:' || nullif(trim(MEMBER_NO),''), 'MEMBER:')", 'tgt': 'HUB_PARTY_BK__MEMBER_MEMBER_NO'},
            {'src_expr': "nullif('MEMBER:' || nullif(trim(MEMBER_NO),''), 'MEMBER:')", 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_REMEDINET_PATIENT_DETAILS'
    },
    {
        'model': 'stg_scr_hlth_portable_dtls',
        'alias': 't53',
        'key_column': 'HUB_ASSESSMENT_BK__SCRUTINY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'insured_dob', 'tgt': 'date_of_birth'},
            {'src': 'insured_gender', 'tgt': 'gender_code'},
            {'src': 'insured_name', 'tgt': 'party_full_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'request_no', 'tgt': 'HUB_CASE_BK__REQUEST_NO'},
            {'src_expr': 'member_identifier', 'tgt': 'HUB_PARTY_BK__MEMBER_IDENTIFIER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_SCR_HLTH_PORTABLE_DTLS'
    }
] -%}

{%- set output_columns = [
    'age', 'age_days_component', 'age_months_component', 'age_residual_months', 'date_of_birth', 'first_name', 'gender_code', 'last_name', 'legacy_member_number', 'middle_name', 'national_card_holder_indicator', 'party_display_name', 'party_full_name', 'party_legal_name', 'party_status', 'party_status_reason', 'party_sub_type_code', 'party_type_code', 'reactivation_date', 'salutation', 'status_remark'
] -%}

{%- set coalesce_rules = {
    'age': ['t50', 't38', 't6', 't11', 't12', 't13', 't15', 't18', 't20', 't23', 't24', 't25', 't26', 't28', 't30', 't32', 't34', 't35', 't36', 't53', 't41', 't42', 't0', 't52'],
    'age_days_component': ['t52'],
    'age_months_component': ['t52'],
    'age_residual_months': ['t50'],
    'date_of_birth': ['t50', 't38', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't15', 't16', 't18', 't20', 't23', 't24', 't25', 't26', 't27', 't28', 't30', 't34', 't36', 't53', 't41', 't0', 't52'],
    'first_name': ['t7', 't8', 't9', 't10', 't12', 't16', 't18', 't21', 't23', 't27', 't0', 't52'],
    'gender_code': ['t50', 't38', 't5', 't7', 't8', 't9', 't10', 't12', 't13', 't15', 't16', 't18', 't20', 't23', 't24', 't25', 't26', 't28', 't30', 't32', 't34', 't35', 't36', 't53', 't41', 't42', 't0', 't52'],
    'last_name': ['t7', 't8', 't9', 't10', 't12', 't16', 't18', 't21', 't23', 't27', 't0', 't52'],
    'legacy_member_number': ['t34'],
    'middle_name': ['t7', 't8', 't9', 't10', 't12', 't16', 't18', 't21', 't23', 't0', 't52'],
    'national_card_holder_indicator': ['t27'],
    'party_display_name': ['t32'],
    'party_full_name': ['t17', 't50', 't51', 't38', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't18', 't19', 't20', 't21', 't45', 't22', 't23', 't46', 't24', 't25', 't26', 't28', 't29', 't30', 't31', 't32', 't47', 't48', 't33', 't34', 't35', 't36', 't37', 't40', 't53', 't41', 't42', 't0', 't44', 't39', 't43'],
    'party_legal_name': ['t9', 't13', 't18', 't21', 't24', 't30', 't35', 't36', 't41'],
    'party_status': ['t49'],
    'party_status_reason': ['t49'],
    'party_sub_type_code': ['t47', 't49'],
    'party_type_code': ['t20', 't26', 't49'],
    'reactivation_date': ['t49'],
    'salutation': ['t18'],
    'status_remark': ['t49']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 'coalesce(t40.HUB_AGREEMENT_BK__REMEDINET_PROVIDER_CODE, t47.HUB_AGREEMENT_BK__HOSID, t48.HUB_AGREEMENT_BK__HOSID, t49.HUB_AGREEMENT_BK__HOSID)'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t5.HUB_ASSESSMENT_BK__SCRUTINY_NO, t6.HUB_ASSESSMENT_BK__SCRUTINY_NO, t7.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t8.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t9.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t10.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t12.HUB_ASSESSMENT_BK__SCRUTINY_NO, t16.HUB_ASSESSMENT_BK__SCRUTINY_NO, t19.HUB_ASSESSMENT_BK__SCRUTINY_NO, t45.HUB_ASSESSMENT_BK__SCRUTINY_NO, t53.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CASE_BK', 'expr': 't53.HUB_CASE_BK__REQUEST_NO'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t12.HUB_CLAIM_BK__REFERENCE_ID, t29.HUB_CLAIM_BK__CLAIM_ID, t30.HUB_CLAIM_BK__CLAIM_ID, t32.HUB_CLAIM_BK__CLID, t33.HUB_CLAIM_BK__CLAIM_ID, t35.HUB_CLAIM_BK__CLAIM_ID, t40.HUB_CLAIM_BK__CLAIM_NO, t42.HUB_CLAIM_BK__BJAZ_CLAIM_ID, t46.HUB_CLAIM_BK__CASE_ID, t50.HUB_CLAIM_BK__CLAIM_ID, t52.HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 'coalesce(t1.HUB_COVERAGE_BK__HCP_SEQNO, t2.HUB_COVERAGE_BK__HCP_SEQNO, t3.HUB_COVERAGE_BK__HCP_SEQNO, t27.HUB_COVERAGE_BK__COVER_CODE)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t4.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t8.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t9.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t10.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t12.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t13.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t15.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t16.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t18.HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID, t19.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t20.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t22.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t24.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t26.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t27.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t28.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t32.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t34.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t36.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t38.HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO, t41.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t42.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t44.HUB_DISTRIBUTION_CHANNEL_BK__CHATBOT_CHATBOT_ID, t47.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t48.HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t13.HUB_DOCUMENT_BK__CARD_NO, t15.HUB_DOCUMENT_BK__MEDICAL_REPORT, t33.HUB_DOCUMENT_BK__INWARD_ID, t36.HUB_DOCUMENT_BK__MEDICAL_REPORT, t40.HUB_DOCUMENT_BK__OMNI_INWARD_NO, t41.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t7.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t8.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t9.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t10.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t19.HUB_FINANCIAL_ACCOUNT_BK__LMS_NO, t20.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER, t26.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER, t32.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO, t34.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t32.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t42.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 'coalesce(t4.HUB_LOCATION_BK__CHILD_LOC_CODE, t12.HUB_LOCATION_BK__LOCATION_CODE, t38.HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE, t43.HUB_LOCATION_BK__ADDRID_MAILING_ADDRESS_ID, t44.HUB_LOCATION_BK__PINCODE, t47.HUB_LOCATION_BK__PIN_CODE, t52.HUB_LOCATION_BK__ADDRESS1_ADDRESS2_ADDRESS3_CITY)'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t32.HUB_LOSS_EVENT_BK__CLAIM_NO, t33.HUB_LOSS_EVENT_BK__CLAIM_ID, t42.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t7.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t8.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t9.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t10.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t16.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT, t19.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT, t44.HUB_ORG_UNIT_BK__BRANCH_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t1.HUB_PARTY_BK__PART_ID, t2.HUB_PARTY_BK__PART_ID, t3.HUB_PARTY_BK__PART_ID, t4.HUB_PARTY_BK__USER_ID, t6.HUB_PARTY_BK__ALLOTED_TO, t11.HUB_PARTY_BK__EMP_CODE, t12.HUB_PARTY_BK__CUSTOMER_ID, t15.HUB_PARTY_BK__MEMBER_NO, t20.HUB_PARTY_BK__USER_ID, t23.HUB_PARTY_BK__MEMBER_NO, t24.HUB_PARTY_BK__MEMBER_NO, t25.HUB_PARTY_BK__PART_ID, t26.HUB_PARTY_BK__CLIENT_ID, t27.HUB_PARTY_BK__PART_ID, t28.HUB_PARTY_BK__MEMBER_NO, t29.HUB_PARTY_BK__HOSPITAL_ID, t30.HUB_PARTY_BK__LDR_PID, t32.HUB_PARTY_BK__HOSPITAL_ID, t33.HUB_PARTY_BK__COURIER_ID, t34.HUB_PARTY_BK__MEMBER_ID, t36.HUB_PARTY_BK__MEMBER_NO, t41.HUB_PARTY_BK__MEMBER_NO, t43.HUB_PARTY_BK__PARTNER_PARTNER_ID, t47.HUB_PARTY_BK__HOSID, t48.HUB_PARTY_BK__HOSID, t49.HUB_PARTY_BK__HOSID, t51.HUB_PARTY_BK__INTERMEDIARY_ID, t52.HUB_PARTY_BK__MEMBER_MEMBER_NO, t53.HUB_PARTY_BK__MEMBER_IDENTIFIER)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t32.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t42.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__CONTRACT_ID, t2.HUB_POLICY_BK__CONTRACT_ID, t3.HUB_POLICY_BK__CONTRACT_ID, t4.HUB_POLICY_BK__CONTRACT_ID, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__CONTRACT_ID, t7.HUB_POLICY_BK__POL_SERIAL_NO, t8.HUB_POLICY_BK__POL_SERIAL_NO, t9.HUB_POLICY_BK__POL_SERIAL_NO, t10.HUB_POLICY_BK__POL_SERIAL_NO, t11.HUB_POLICY_BK__POLICY_NO, t12.HUB_POLICY_BK__POLICY_REF, t13.HUB_POLICY_BK__POLICY_REF, t14.HUB_POLICY_BK__POLICY_REF, t15.HUB_POLICY_BK__CONTRACT_ID, t16.HUB_POLICY_BK__POLICY_REF, t17.HUB_POLICY_BK__POLICY_NO, t18.HUB_POLICY_BK__PMASTERPOLICYNUMBER, t19.HUB_POLICY_BK__REFERENCE_ID, t20.HUB_POLICY_BK__MASTER_POLICY_NO, t21.HUB_POLICY_BK__REG_NO, t22.HUB_POLICY_BK__REG_NO, t23.HUB_POLICY_BK__CONTRACT_ID, t24.HUB_POLICY_BK__CONTRACT_ID, t25.HUB_POLICY_BK__CONTRACT_ID, t26.HUB_POLICY_BK__REFERENCE_ID, t27.HUB_POLICY_BK__CONTRACT_ID, t28.HUB_POLICY_BK__CONTRACT_ID, t29.HUB_POLICY_BK__POLICY_REF, t30.HUB_POLICY_BK__POLICY_REF, t31.HUB_POLICY_BK__POLICY_NO, t32.HUB_POLICY_BK__POLICY, t33.HUB_POLICY_BK__POLICY_REF, t34.HUB_POLICY_BK__CONTRACT_ID, t35.HUB_POLICY_BK__POLICY_NUMBER, t36.HUB_POLICY_BK__CONTRACT_ID, t37.HUB_POLICY_BK__CONTRACT_ID, t38.HUB_POLICY_BK__POLICY_REF, t39.HUB_POLICY_BK__CONTRACT_ID, t40.HUB_POLICY_BK__POLICY_NO, t41.HUB_POLICY_BK__CONTRACT_ID, t42.HUB_POLICY_BK__POLICY_NO, t43.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t7.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t8.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t9.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t10.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t16.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t19.HUB_PRODUCT_BK__PRODUCT_CODE, t20.HUB_PRODUCT_BK__PRODUCT_CODE, t21.HUB_PRODUCT_BK__PRODUCT, t22.HUB_PRODUCT_BK__PRODUCT, t26.HUB_PRODUCT_BK__PRODUCT_CODE, t27.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t30.HUB_PRODUCT_BK__PROD_CD, t34.HUB_PRODUCT_BK__PRODUCT_CODE, t39.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t44.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t45.HUB_PRODUCT_BK__PRODUCT)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t6.HUB_PROPOSAL_BK__HI_CONTROL_NUMBER, t17.HUB_PROPOSAL_BK__SCRUTINY_NO, t26.HUB_PROPOSAL_BK__BA_LEAD_NO, t27.HUB_PROPOSAL_BK__QUOTE_REF_NO, t45.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t14.HUB_QUOTE_BK__QUOTE_REF, t17.HUB_QUOTE_BK__QUOTATION_NO, t21.HUB_QUOTE_BK__QUOTE_SUB_NO, t22.HUB_QUOTE_BK__QUOTE_SUB_NO, t27.HUB_QUOTE_BK__QUOTE_REF_NO, t45.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_REINSURANCE_TREATY_BK', 'expr': 't19.HUB_REINSURANCE_TREATY_BK__RE_INSU'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t0.HUB_RISK_OBJECT_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME, t7.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t9.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t15.HUB_RISK_OBJECT_BK__MEMBER_NO, t24.HUB_RISK_OBJECT_BK__MEMBER_NO, t38.HUB_RISK_OBJECT_BK__CUSTID_CUST_ID, t52.HUB_RISK_OBJECT_BK__MEMBER_MEMBER_NO)'},
    {'name': 'T0__HUB_PARTY_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME', 'expr': 't0.HUB_PARTY_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME'},
    {'name': 'T0__HUB_PARTY_BK__CONTRACT_ID_NOMINEE_NOMINEE_NAME', 'expr': 't0.HUB_PARTY_BK__CONTRACT_ID_NOMINEE_NOMINEE_NAME'},
    {'name': 'T7__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't7.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T7__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't7.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T7__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't7.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T8__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't8.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T8__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't8.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T8__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't8.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T9__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't9.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T9__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't9.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T9__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't9.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T10__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't10.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T10__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't10.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T10__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't10.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T12__HUB_PRODUCT_BK__PLAN_ID', 'expr': 't12.HUB_PRODUCT_BK__PLAN_ID'},
    {'name': 'T12__HUB_PRODUCT_BK__PRODUCT_CODE', 'expr': 't12.HUB_PRODUCT_BK__PRODUCT_CODE'},
    {'name': 'T16__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't16.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T16__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't16.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T16__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't16.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T16__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't16.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T16__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't16.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T17__HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN', 'expr': 't17.HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN'},
    {'name': 'T17__HUB_LOCATION_BK__PH_ADDRESS', 'expr': 't17.HUB_LOCATION_BK__PH_ADDRESS'},
    {'name': 'T17__HUB_LOCATION_BK__PP_ADDRESS', 'expr': 't17.HUB_LOCATION_BK__PP_ADDRESS'},
    {'name': 'T17__HUB_PARTY_BK__EMP_RM_CODE', 'expr': 't17.HUB_PARTY_BK__EMP_RM_CODE'},
    {'name': 'T17__HUB_PARTY_BK__CORPORATE_ID', 'expr': 't17.HUB_PARTY_BK__CORPORATE_ID'},
    {'name': 'T17__HUB_PARTY_BK__IMD_CODE', 'expr': 't17.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T17__HUB_PARTY_BK__PH_ID', 'expr': 't17.HUB_PARTY_BK__PH_ID'},
    {'name': 'T17__HUB_PARTY_BK__PP_ID', 'expr': 't17.HUB_PARTY_BK__PP_ID'},
    {'name': 'T17__HUB_PARTY_BK__SUBIMD_CODE', 'expr': 't17.HUB_PARTY_BK__SUBIMD_CODE'},
    {'name': 'T18__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't18.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T18__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't18.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T18__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't18.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T18__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't18.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T18__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't18.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T18__HUB_PRODUCT_BK__PLANID', 'expr': 't18.HUB_PRODUCT_BK__PLANID'},
    {'name': 'T18__HUB_PRODUCT_BK__SCHEMECODE', 'expr': 't18.HUB_PRODUCT_BK__SCHEMECODE'},
    {'name': 'T19__HUB_PARTY_BK__BAGIC_E_CODE', 'expr': 't19.HUB_PARTY_BK__BAGIC_E_CODE'},
    {'name': 'T19__HUB_PARTY_BK__BAGIC_RM_E_CODE', 'expr': 't19.HUB_PARTY_BK__BAGIC_RM_E_CODE'},
    {'name': 'T19__HUB_PARTY_BK__IMD_CODE', 'expr': 't19.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T19__HUB_PARTY_BK__SUB_IMD_CODE', 'expr': 't19.HUB_PARTY_BK__SUB_IMD_CODE'},
    {'name': 'T20__HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER', 'expr': 't20.HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER'},
    {'name': 'T20__HUB_PROPOSAL_BK__REFERENCE_ID', 'expr': 't20.HUB_PROPOSAL_BK__REFERENCE_ID'},
    {'name': 'T22__HUB_PARTY_BK__IMD_CODE', 'expr': 't22.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T22__HUB_PARTY_BK__RM_CODE', 'expr': 't22.HUB_PARTY_BK__RM_CODE'},
    {'name': 'T22__HUB_PARTY_BK__SUB_IMD_CODE', 'expr': 't22.HUB_PARTY_BK__SUB_IMD_CODE'},
    {'name': 'T27__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't27.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T27__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't27.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T32__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't32.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T32__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't32.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T32__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't32.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T32__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't32.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T32__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't32.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T33__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't33.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T33__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't33.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T33__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't33.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T33__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't33.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T33__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't33.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T35__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't35.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T35__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't35.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T35__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't35.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T35__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't35.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T35__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't35.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T38__HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME', 'expr': 't38.HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME'},
    {'name': 'T38__HUB_PARTY_BK__CUST_ID', 'expr': 't38.HUB_PARTY_BK__CUST_ID'},
    {'name': 'T39__HUB_LOCATION_BK__ADDRESS_CITY_REGION', 'expr': 't39.HUB_LOCATION_BK__ADDRESS_CITY_REGION'},
    {'name': 'T39__HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE', 'expr': 't39.HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE'},
    {'name': 'T39__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't39.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T39__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't39.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T39__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't39.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T39__HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME', 'expr': 't39.HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME'},
    {'name': 'T39__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't39.HUB_PARTY_BK__PARTID_PART_ID'},
    {'name': 'T40__HUB_PARTY_BK__PAYER_CODE', 'expr': 't40.HUB_PARTY_BK__PAYER_CODE'},
    {'name': 'T40__HUB_PARTY_BK__REMEDINET_PROVIDER_CODE', 'expr': 't40.HUB_PARTY_BK__REMEDINET_PROVIDER_CODE'},
    {'name': 'T42__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't42.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T42__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't42.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T42__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't42.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T42__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't42.HUB_PARTY_BK__HOSPITAL_CODE'},
    {'name': 'T44__HUB_PARTY_BK__CUST_NAME', 'expr': 't44.HUB_PARTY_BK__CUST_NAME'},
    {'name': 'T44__HUB_PARTY_BK__USER_NAME', 'expr': 't44.HUB_PARTY_BK__USER_NAME'},
    {'name': 'T45__HUB_ORG_UNIT_BK__BRANCH', 'expr': 't45.HUB_ORG_UNIT_BK__BRANCH'},
    {'name': 'T45__HUB_ORG_UNIT_BK__DEPARTMENT', 'expr': 't45.HUB_ORG_UNIT_BK__DEPARTMENT'},
    {'name': 'T45__HUB_POLICY_BK__POLICY_NO', 'expr': 't45.HUB_POLICY_BK__POLICY_NO'},
    {'name': 'T45__HUB_POLICY_BK__PREV_POL_REF', 'expr': 't45.HUB_POLICY_BK__PREV_POL_REF'},
    {'name': 'T45__HUB_POLICY_BK__REG_NO', 'expr': 't45.HUB_POLICY_BK__REG_NO'},
    {'name': 'T50__HUB_DOCUMENT_BK__FIR_FIR_NO', 'expr': 't50.HUB_DOCUMENT_BK__FIR_FIR_NO'},
    {'name': 'T50__HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO', 'expr': 't50.HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO'},
    {'name': 'T50__HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO', 'expr': 't50.HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO'},
    {'name': 'T50__HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD', 'expr': 't50.HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD'},
    {'name': 'T50__HUB_PARTY_BK__HOSPID_HOS_ID', 'expr': 't50.HUB_PARTY_BK__HOSPID_HOS_ID'},
    {'name': 'T51__HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL', 'expr': 't51.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL'},
    {'name': 'T51__HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC', 'expr': 't51.HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_party_identity'
) }}
