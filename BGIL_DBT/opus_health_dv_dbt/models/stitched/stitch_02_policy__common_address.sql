/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Batch task 5.1. Procedure: the stitch_01 pilot's 9-step REUSABLE PROCEDURE.
   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_common_address
   GRAIN DEVIATIONS (source has no spine-hub key; keyed on its real join col):
     - t24 (stg_bot_utilization_dtls): no HUB_POLICY key; key_column=HUB_DISTRIBUTION_CHANNEL_BK__CHATBOT_CHATBOT_ID (real join key)
     - t25 (stg_branch_master): no HUB_POLICY key; key_column=HUB_LOCATION_BK__ADD_LINE1_ADD_LINE2_ADD_LINE3_ADD_LINE4 (real join key)
     - t26 (stg_hm_hospital_master): no HUB_POLICY key; key_column=HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID (real join key)
     - t27 (stg_hm_hospital_master_extn): no HUB_POLICY key; key_column=HUB_AGREEMENT_BK__HOSID (real join key)
     - t28 (stg_hm_hosp_master_extn1): no HUB_POLICY key; key_column=HUB_AGREEMENT_BK__HOSID (real join key)
     - t29 (stg_neft_ifsc_master): no HUB_POLICY key; key_column=HUB_LOCATION_BK__BRANCH_ADDRESS (real join key)
     - t30 (stg_neft_partner_dtls): no HUB_POLICY key; key_column=HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE (real join key)
     - t31 (stg_remedinet_patient_details): no HUB_POLICY key; key_column=HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID (real join key)
   SAME-ALIAS PAYLOAD DROPS (macro emits one col per alias per tgt; secondary dropped):
     - address_line_1: kept t7.address_line1, dropped-secondary t7.ph_address
     - address_line_1: kept t7.address_line1, dropped-secondary t7.pp_address
     - address_line_1: kept t5.m_address_line_1, dropped-secondary t5.p_address_line_1
     - address_line_1: kept t12.address_line1, dropped-secondary t12.disp_address_line1
     - address_line_1: kept t14.add1, dropped-secondary t14.patient_address
     - address_line_1: kept t23.address, dropped-secondary t23.payee_address
     - address_line_1: kept t21.address, dropped-secondary t21.insured_address
     - address_line_2: kept t5.m_address_line_2, dropped-secondary t5.p_address_line_2
     - address_line_2: kept t12.address_line2, dropped-secondary t12.disp_address_line2
     - city: kept t5.m_city, dropped-secondary t5.p_city
     - city: kept t12.city, dropped-secondary t12.disp_city
     - city: kept t23.city, dropped-secondary t23.hospital_city
     - city: kept t23.city, dropped-secondary t23.ins_city
     - locality: kept t12.area, dropped-secondary t12.disp_area
     - postal_code: kept t5.m_pincode, dropped-secondary t5.p_pincode
     - postal_code: kept t12.curr_pincode, dropped-secondary t12.mailing_pincode
     - postal_code: kept t12.curr_pincode, dropped-secondary t12.postcode
     - postal_code: kept t21.mailing_pincode, dropped-secondary t21.pincode
     - state_code: kept t5.m_state, dropped-secondary t5.p_state
     - state_name: kept t12.disp_state, dropped-secondary t12.state
     - state_name: kept t23.hospital_state, dropped-secondary t23.ins_state
     - state_name: kept t23.hospital_state, dropped-secondary t23.state
     - village: kept t12.disp_other_area, dropped-secondary t12.other_area
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_pp_mem_dtls',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'dc_address', 'tgt': 'address_line_1'},
            {'src': 'dc_city', 'tgt': 'city'},
            {'src': 'dc_location', 'tgt': 'locality'},
            {'src': 'dc_pincode', 'tgt': 'postal_code'},
            {'src': 'dc_state', 'tgt': 'state_name'}
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
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_address_line_1', 'tgt': 'address_line_1'},
            {'src': 'pd_address_line_2', 'tgt': 'address_line_2'},
            {'src': 'pd_city', 'tgt': 'city'},
            {'src': 'pd_country', 'tgt': 'country_name'},
            {'src': 'pd_area_as_per_pf', 'tgt': 'locality'},
            {'src': 'pd_area_post_office', 'tgt': 'post_office_name'},
            {'src': 'pd_pin_code', 'tgt': 'postal_code'},
            {'src': 'pd_state', 'tgt': 'state_name'}
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
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_address_line_1', 'tgt': 'address_line_1'},
            {'src': 'pd_address_line_2', 'tgt': 'address_line_2'},
            {'src': 'pd_city', 'tgt': 'city'},
            {'src': 'pd_country', 'tgt': 'country_name'},
            {'src': 'pd_area_as_per_pf', 'tgt': 'locality'},
            {'src': 'pd_area_post_office', 'tgt': 'post_office_name'},
            {'src': 'pd_pin_code', 'tgt': 'postal_code'},
            {'src': 'pd_state', 'tgt': 'state_name'}
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
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_address_line_1', 'tgt': 'address_line_1'},
            {'src': 'pd_address_line_2', 'tgt': 'address_line_2'},
            {'src': 'pd_city', 'tgt': 'city'},
            {'src': 'pd_country', 'tgt': 'country_name'},
            {'src': 'pd_area_as_per_pf', 'tgt': 'locality'},
            {'src': 'pd_area_post_office', 'tgt': 'post_office_name'},
            {'src': 'pd_pin_code', 'tgt': 'postal_code'},
            {'src': 'pd_state', 'tgt': 'state_name'}
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
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_address_line_1', 'tgt': 'address_line_1'},
            {'src': 'pd_address_line_2', 'tgt': 'address_line_2'},
            {'src': 'pd_city', 'tgt': 'city'},
            {'src': 'pd_country', 'tgt': 'country_name'},
            {'src': 'pd_area_as_per_pf', 'tgt': 'locality'},
            {'src': 'pd_area_post_office', 'tgt': 'post_office_name'},
            {'src': 'pd_pin_code', 'tgt': 'postal_code'},
            {'src': 'pd_state', 'tgt': 'state_name'}
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
        'model': 'stg_bandhan_medi_clam',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'm_address_line_1', 'tgt': 'address_line_1'},
            {'src': 'm_address_line_2', 'tgt': 'address_line_2'},
            {'src': 'm_city', 'tgt': 'city'},
            {'src': 'm_pincode', 'tgt': 'postal_code'},
            {'src': 'm_state', 'tgt': 'state_code'}
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
        'model': 'stg_ehh_pol_dtls',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address_line1', 'tgt': 'address_line_1'},
            {'src': 'address_line2', 'tgt': 'address_line_2'},
            {'src': 'city', 'tgt': 'city'},
            {'src': 'area', 'tgt': 'locality'},
            {'src': 'postcode', 'tgt': 'postal_code'},
            {'src': 'state', 'tgt': 'state_name'}
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
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address_line1', 'tgt': 'address_line_1'},
            {'src': 'corp_city', 'tgt': 'city'},
            {'src': 'corp_pin', 'tgt': 'postal_code'}
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
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'building', 'tgt': 'building_name'},
            {'src': 'city', 'tgt': 'city'},
            {'src': 'country', 'tgt': 'country_name'},
            {'src': 'pincode', 'tgt': 'postal_code'},
            {'src': 'state', 'tgt': 'state_name'},
            {'src': 'streetname', 'tgt': 'street_name'}
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
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'mailing_pincode', 'tgt': 'postal_code'}
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
        'model': 'stg_grp_hlt_cust_dtls',
        'alias': 't10',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address_line_1', 'tgt': 'address_line_1'},
            {'src': 'address_line_2', 'tgt': 'address_line_2'},
            {'src': 'city', 'tgt': 'city'},
            {'src': 'pin_code', 'tgt': 'postal_code'},
            {'src': 'state', 'tgt': 'state_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'reg_no', 'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product', 'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_CUST_DTLS'
    },
    {
        'model': 'stg_hat_id_mem_detls',
        'alias': 't11',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'addline1', 'tgt': 'address_line_1'},
            {'src': 'addline2', 'tgt': 'address_line_2'},
            {'src': 'city', 'tgt': 'city'},
            {'src': 'pin', 'tgt': 'postal_code'},
            {'src': 'state', 'tgt': 'state_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HAT_ID_MEM_DETLS'
    },
    {
        'model': 'stg_hg_pol_dtls',
        'alias': 't12',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address_line1', 'tgt': 'address_line_1'},
            {'src': 'address_line2', 'tgt': 'address_line_2'},
            {'src': 'city', 'tgt': 'city'},
            {'src': 'country_code', 'tgt': 'country_code'},
            {'src': 'area', 'tgt': 'locality'},
            {'src': 'curr_pincode', 'tgt': 'postal_code'},
            {'src': 'disp_state', 'tgt': 'state_name'},
            {'src': 'disp_other_area', 'tgt': 'village'}
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
        'model': 'stg_hm_coinsu_clm_dtls',
        'alias': 't13',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'network_city', 'tgt': 'city'},
            {'src': 'state', 'tgt': 'state_name'}
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
        'model': 'stg_hm_hcm_extract',
        'alias': 't14',
        'key_column': 'HUB_POLICY_BK__POLICY',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'add1', 'tgt': 'address_line_1'},
            {'src': 'add2', 'tgt': 'address_line_2'},
            {'src': 'city', 'tgt': 'city'},
            {'src': 'pin', 'tgt': 'postal_code'},
            {'src': 'state', 'tgt': 'state_name'}
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
        'alias': 't15',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'city_name', 'tgt': 'city'},
            {'src': 'pin_code', 'tgt': 'postal_code'},
            {'src': 'state_name', 'tgt': 'state_name'}
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
        'alias': 't16',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address', 'tgt': 'address_line_1'},
            {'src': 'city', 'tgt': 'city'},
            {'src': 'pin', 'tgt': 'postal_code'},
            {'src': 'state', 'tgt': 'state_name'}
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
        'alias': 't17',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'hat_id_city', 'tgt': 'city'},
            {'src': 'hat_id_state', 'tgt': 'state_name'}
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
        'alias': 't18',
        'key_column': 'HUB_POLICY_BK__POLICY_NUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address', 'tgt': 'address_line_1'}
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
        'model': 'stg_pmsby_data_web_service',
        'alias': 't19',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address_1', 'tgt': 'address_line_1'},
            {'src': 'address_2', 'tgt': 'address_line_2'},
            {'src': 'pincode', 'tgt': 'postal_code'}
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
        'model': 'stg_policy_bases_extn',
        'alias': 't20',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'prev_insurer_add', 'tgt': 'address_line_1'},
            {'src': 'mailing_pincode', 'tgt': 'postal_code'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('TXN:' || nullif(trim(TRANSACTION_ID),''), 'TXN:')", 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID'},
            {'src_expr': "md5(normalise(upper(nullif(trim(MAILING_PINCODE),''))))", 'tgt': 'HUB_LOCATION_BK__MAILING_PINCODE'},
            {'src_expr': "md5(normalise(upper(nullif(trim(PREV_INSURER_ADD),''))))", 'tgt': 'HUB_LOCATION_BK__PREV_INSURER_ADD'},
            {'src_expr': "nullif(trim(DEPARTMENT_CODE),'')", 'tgt': 'HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(PRODUCT_4DIGIT_CODE),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT_PRODUCT_4DIGIT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_POLICY_BASES_EXTN'
    },
    {
        'model': 'stg_policy_summary',
        'alias': 't21',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address', 'tgt': 'address_line_1'},
            {'src': 'city', 'tgt': 'city'},
            {'src': 'city_code', 'tgt': 'city_code'},
            {'src': 'mailing_pincode', 'tgt': 'postal_code'}
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
        'model': 'stg_sh_mem_dtls_extn',
        'alias': 't22',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address', 'tgt': 'address_line_1'}
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
        'alias': 't23',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address', 'tgt': 'address_line_1'},
            {'src': 'city', 'tgt': 'city'},
            {'src': 'area', 'tgt': 'locality'},
            {'src': 'pincode', 'tgt': 'postal_code'},
            {'src': 'hospital_state', 'tgt': 'state_name'}
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
        'model': 'stg_bot_utilization_dtls',
        'alias': 't24',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__CHATBOT_CHATBOT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pincode', 'tgt': 'postal_code'}
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
        'model': 'stg_branch_master',
        'alias': 't25',
        'key_column': 'HUB_LOCATION_BK__ADD_LINE1_ADD_LINE2_ADD_LINE3_ADD_LINE4',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'add_line1', 'tgt': 'address_line_1'},
            {'src': 'add_line2', 'tgt': 'address_line_2'},
            {'src': 'add_line3', 'tgt': 'address_line_3'},
            {'src': 'add_remarks', 'tgt': 'address_remarks'},
            {'src': 'city', 'tgt': 'city'},
            {'src': 'add_line4', 'tgt': 'locality'},
            {'src': 'pincode', 'tgt': 'postal_code'},
            {'src': 'state_code', 'tgt': 'state_code'},
            {'src': 'state', 'tgt': 'state_name'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(trim( coalesce(ADD_LINE1,'') || '|' || coalesce(ADD_LINE2,'') || '|' || coalesce(ADD_LINE3,'') || '|' || coalesce(ADD_LINE4,'') || '|' || coalesce(CITY,'') || '|' || coalesce(STATE,'') || '|' || coalesce(STATE_CODE,'') || '|' || coalesce(PINCODE,'') ), '|||||||'))))", 'tgt': 'HUB_LOCATION_BK__ADD_LINE1_ADD_LINE2_ADD_LINE3_ADD_LINE4'},
            {'src_expr': "nullif(trim(BRANCH_CODE),'')", 'tgt': 'HUB_ORG_UNIT_BK__BRANCH_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_BRANCH_MASTER'
    },
    {
        'model': 'stg_hm_hospital_master',
        'alias': 't26',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address1', 'tgt': 'address_line_1'},
            {'src': 'address2', 'tgt': 'address_line_2'},
            {'src': 'city_name', 'tgt': 'city'},
            {'src': 'pin_code', 'tgt': 'postal_code'},
            {'src': 'state_name', 'tgt': 'state_name'}
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
        'alias': 't27',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'country_name', 'tgt': 'country_name'},
            {'src': 'landmark_1', 'tgt': 'landmark'},
            {'src': 'landmark_2', 'tgt': 'secondary_landmark'}
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
        'alias': 't28',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'area', 'tgt': 'locality'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSP_MASTER_EXTN1'
    },
    {
        'model': 'stg_neft_ifsc_master',
        'alias': 't29',
        'key_column': 'HUB_LOCATION_BK__BRANCH_ADDRESS',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'branch_address', 'tgt': 'address_line_1'},
            {'src': 'district', 'tgt': 'district'},
            {'src': 'state', 'tgt': 'state_name'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(trim(BRANCH_ADDRESS),''))))", 'tgt': 'HUB_LOCATION_BK__BRANCH_ADDRESS'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_NEFT_IFSC_MASTER'
    },
    {
        'model': 'stg_neft_partner_dtls',
        'alias': 't30',
        'key_column': 'HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'city', 'tgt': 'city'},
            {'src': 'mandate_address', 'tgt': 'full_address_text'},
            {'src': 'area', 'tgt': 'locality'},
            {'src': 'pincode', 'tgt': 'postal_code'},
            {'src': 'address_id', 'tgt': 'source_system_address_identifier'},
            {'src': 'state', 'tgt': 'state_name'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(trim(MANDATE_ADDRESS),'') || '|' || coalesce(trim(AREA),'') || '|' || coalesce(trim(CITY),'') || '|' || coalesce(trim(STATE),'') || '|' || coalesce(trim(to_char(PINCODE)),''), '||||'))))", 'tgt': 'HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE'},
            {'src_expr': "nullif('PARTID:' || nullif(trim(PART_ID),''), 'PARTID:')", 'tgt': 'HUB_PARTY_BK__PARTID_PART_ID'},
            {'src_expr': "nullif(trim(INTERMEDIARY_ID),'')", 'tgt': 'HUB_PARTY_BK__INTERMEDIARY_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_NEFT_PARTNER_DTLS'
    },
    {
        'model': 'stg_remedinet_patient_details',
        'alias': 't31',
        'key_column': 'HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address1', 'tgt': 'address_line_1'},
            {'src': 'address2', 'tgt': 'address_line_2'},
            {'src': 'address3', 'tgt': 'address_line_3'},
            {'src': 'city', 'tgt': 'city'},
            {'src': 'pin_code', 'tgt': 'postal_code'},
            {'src': 'state', 'tgt': 'state_name'}
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
    'address_line_1', 'address_line_2', 'address_line_3', 'address_remarks', 'building_name', 'city', 'city_code', 'country_code', 'country_name', 'district', 'full_address_text', 'landmark', 'locality', 'post_office_name', 'postal_code', 'secondary_landmark', 'source_system_address_identifier', 'state_code', 'state_name', 'street_name', 'village'
] -%}

{%- set coalesce_rules = {
    'address_line_1': ['t25', 't7', 't29', 't19', 't0', 't1', 't2', 't3', 't4', 't5', 't6', 't10', 't11', 't12', 't14', 't26', 't16', 't18', 't22', 't23', 't20', 't21', 't31'],
    'address_line_2': ['t25', 't19', 't1', 't2', 't3', 't4', 't5', 't6', 't10', 't11', 't12', 't14', 't26', 't31'],
    'address_line_3': ['t25', 't31'],
    'address_remarks': ['t25'],
    'building_name': ['t8'],
    'city': ['t25', 't7', 't17', 't30', 't0', 't1', 't2', 't3', 't4', 't5', 't6', 't8', 't10', 't11', 't12', 't13', 't14', 't26', 't15', 't16', 't23', 't21', 't31'],
    'city_code': ['t21'],
    'country_code': ['t12'],
    'country_name': ['t1', 't2', 't3', 't4', 't8', 't27'],
    'district': ['t29'],
    'full_address_text': ['t30'],
    'landmark': ['t27'],
    'locality': ['t25', 't30', 't0', 't1', 't2', 't3', 't4', 't6', 't12', 't28', 't23'],
    'post_office_name': ['t1', 't2', 't3', 't4'],
    'postal_code': ['t25', 't7', 't30', 't19', 't0', 't1', 't2', 't3', 't4', 't5', 't6', 't8', 't9', 't10', 't11', 't12', 't14', 't26', 't15', 't16', 't23', 't24', 't20', 't21', 't31'],
    'secondary_landmark': ['t27'],
    'source_system_address_identifier': ['t30'],
    'state_code': ['t25', 't5'],
    'state_name': ['t25', 't17', 't29', 't30', 't0', 't1', 't2', 't3', 't4', 't6', 't8', 't10', 't11', 't12', 't13', 't14', 't26', 't15', 't16', 't23', 't31'],
    'street_name': ['t8'],
    'village': ['t12']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 'coalesce(t26.HUB_AGREEMENT_BK__HOSID, t27.HUB_AGREEMENT_BK__HOSID, t28.HUB_AGREEMENT_BK__HOSID)'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__SCRUTINY_NO, t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t3.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t4.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t5.HUB_ASSESSMENT_BK__SCRUTINY_NO, t6.HUB_ASSESSMENT_BK__SCRUTINY_NO, t9.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t5.HUB_CLAIM_BK__REFERENCE_ID, t13.HUB_CLAIM_BK__CLAIM_ID, t14.HUB_CLAIM_BK__CLID, t15.HUB_CLAIM_BK__CLAIM_ID, t18.HUB_CLAIM_BK__CLAIM_ID, t23.HUB_CLAIM_BK__BJAZ_CLAIM_ID, t31.HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 't12.HUB_COVERAGE_BK__COVER_CODE'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t8.HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID, t9.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t12.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t14.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t16.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t19.HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO, t22.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t23.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t24.HUB_DISTRIBUTION_CHANNEL_BK__CHATBOT_CHATBOT_ID, t26.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t27.HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t15.HUB_DOCUMENT_BK__INWARD_ID, t22.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t1.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t2.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t3.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t4.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t9.HUB_FINANCIAL_ACCOUNT_BK__LMS_NO, t14.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO, t16.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t14.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t20.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID, t23.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 'coalesce(t5.HUB_LOCATION_BK__LOCATION_CODE, t17.HUB_LOCATION_BK__HAT_ID_CITY_HAT_ID_STATE, t19.HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE, t24.HUB_LOCATION_BK__PINCODE, t25.HUB_LOCATION_BK__ADD_LINE1_ADD_LINE2_ADD_LINE3_ADD_LINE4, t26.HUB_LOCATION_BK__PIN_CODE, t29.HUB_LOCATION_BK__BRANCH_ADDRESS, t30.HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE, t31.HUB_LOCATION_BK__ADDRESS1_ADDRESS2_ADDRESS3_CITY)'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t14.HUB_LOSS_EVENT_BK__CLAIM_NO, t15.HUB_LOSS_EVENT_BK__CLAIM_ID, t23.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t3.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t4.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t6.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT, t9.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT, t20.HUB_ORG_UNIT_BK__DEPARTMENT_CODE, t24.HUB_ORG_UNIT_BK__BRANCH_CODE, t25.HUB_ORG_UNIT_BK__BRANCH_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__ALLOTED_TO, t5.HUB_PARTY_BK__CUSTOMER_ID, t11.HUB_PARTY_BK__MEMBER_NO, t12.HUB_PARTY_BK__PART_ID, t13.HUB_PARTY_BK__LDR_PID, t14.HUB_PARTY_BK__HOSPITAL_ID, t15.HUB_PARTY_BK__COURIER_ID, t16.HUB_PARTY_BK__MEMBER_ID, t22.HUB_PARTY_BK__MEMBER_NO, t26.HUB_PARTY_BK__HOSID, t27.HUB_PARTY_BK__HOSID, t28.HUB_PARTY_BK__HOSID, t31.HUB_PARTY_BK__MEMBER_MEMBER_NO)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t14.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t23.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__POL_SERIAL_NO, t4.HUB_POLICY_BK__POL_SERIAL_NO, t5.HUB_POLICY_BK__POLICY_REF, t6.HUB_POLICY_BK__POLICY_REF, t7.HUB_POLICY_BK__POLICY_NO, t8.HUB_POLICY_BK__PMASTERPOLICYNUMBER, t9.HUB_POLICY_BK__REFERENCE_ID, t10.HUB_POLICY_BK__REG_NO, t11.HUB_POLICY_BK__CONTRACT_ID, t12.HUB_POLICY_BK__CONTRACT_ID, t13.HUB_POLICY_BK__POLICY_REF, t14.HUB_POLICY_BK__POLICY, t15.HUB_POLICY_BK__POLICY_REF, t16.HUB_POLICY_BK__CONTRACT_ID, t17.HUB_POLICY_BK__CONTRACT_ID, t18.HUB_POLICY_BK__POLICY_NUMBER, t19.HUB_POLICY_BK__POLICY_REF, t20.HUB_POLICY_BK__CONTRACT_ID, t21.HUB_POLICY_BK__CONTRACT_ID, t22.HUB_POLICY_BK__CONTRACT_ID, t23.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t3.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t4.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t6.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t9.HUB_PRODUCT_BK__PRODUCT_CODE, t10.HUB_PRODUCT_BK__PRODUCT, t12.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t13.HUB_PRODUCT_BK__PROD_CD, t16.HUB_PRODUCT_BK__PRODUCT_CODE, t20.HUB_PRODUCT_BK__PRODUCT_PRODUCT_4DIGIT_CODE, t21.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t24.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t0.HUB_PROPOSAL_BK__HI_CONTROL_NUMBER, t7.HUB_PROPOSAL_BK__SCRUTINY_NO, t12.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t7.HUB_QUOTE_BK__QUOTATION_NO, t10.HUB_QUOTE_BK__QUOTE_SUB_NO, t12.HUB_QUOTE_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_REINSURANCE_TREATY_BK', 'expr': 't9.HUB_REINSURANCE_TREATY_BK__RE_INSU'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t1.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t3.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t17.HUB_RISK_OBJECT_BK__MEMBER_CONTRACT_ID_MEMBER_ID, t19.HUB_RISK_OBJECT_BK__CUSTID_CUST_ID, t31.HUB_RISK_OBJECT_BK__MEMBER_MEMBER_NO)'},
    {'name': 'T1__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't1.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T2__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't2.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T3__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't3.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T3__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't3.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T3__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't3.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T4__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't4.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T4__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't4.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T4__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't4.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T5__HUB_PRODUCT_BK__PLAN_ID', 'expr': 't5.HUB_PRODUCT_BK__PLAN_ID'},
    {'name': 'T5__HUB_PRODUCT_BK__PRODUCT_CODE', 'expr': 't5.HUB_PRODUCT_BK__PRODUCT_CODE'},
    {'name': 'T6__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't6.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T6__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't6.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T6__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't6.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T6__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't6.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T6__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't6.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T7__HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN', 'expr': 't7.HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN'},
    {'name': 'T7__HUB_LOCATION_BK__PH_ADDRESS', 'expr': 't7.HUB_LOCATION_BK__PH_ADDRESS'},
    {'name': 'T7__HUB_LOCATION_BK__PP_ADDRESS', 'expr': 't7.HUB_LOCATION_BK__PP_ADDRESS'},
    {'name': 'T7__HUB_PARTY_BK__EMP_RM_CODE', 'expr': 't7.HUB_PARTY_BK__EMP_RM_CODE'},
    {'name': 'T7__HUB_PARTY_BK__CORPORATE_ID', 'expr': 't7.HUB_PARTY_BK__CORPORATE_ID'},
    {'name': 'T7__HUB_PARTY_BK__IMD_CODE', 'expr': 't7.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T7__HUB_PARTY_BK__PH_ID', 'expr': 't7.HUB_PARTY_BK__PH_ID'},
    {'name': 'T7__HUB_PARTY_BK__PP_ID', 'expr': 't7.HUB_PARTY_BK__PP_ID'},
    {'name': 'T7__HUB_PARTY_BK__SUBIMD_CODE', 'expr': 't7.HUB_PARTY_BK__SUBIMD_CODE'},
    {'name': 'T8__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't8.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T8__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't8.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T8__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't8.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T8__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't8.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T8__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't8.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T8__HUB_PRODUCT_BK__PLANID', 'expr': 't8.HUB_PRODUCT_BK__PLANID'},
    {'name': 'T8__HUB_PRODUCT_BK__SCHEMECODE', 'expr': 't8.HUB_PRODUCT_BK__SCHEMECODE'},
    {'name': 'T9__HUB_PARTY_BK__BAGIC_E_CODE', 'expr': 't9.HUB_PARTY_BK__BAGIC_E_CODE'},
    {'name': 'T9__HUB_PARTY_BK__BAGIC_RM_E_CODE', 'expr': 't9.HUB_PARTY_BK__BAGIC_RM_E_CODE'},
    {'name': 'T9__HUB_PARTY_BK__IMD_CODE', 'expr': 't9.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T9__HUB_PARTY_BK__SUB_IMD_CODE', 'expr': 't9.HUB_PARTY_BK__SUB_IMD_CODE'},
    {'name': 'T12__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't12.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T12__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't12.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T14__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't14.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T14__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't14.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T14__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't14.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T14__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't14.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T14__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't14.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T15__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't15.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T15__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't15.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T15__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't15.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T15__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't15.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T15__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't15.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T18__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't18.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T18__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't18.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T18__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't18.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T18__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't18.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T18__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't18.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T19__HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME', 'expr': 't19.HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME'},
    {'name': 'T19__HUB_PARTY_BK__CUST_ID', 'expr': 't19.HUB_PARTY_BK__CUST_ID'},
    {'name': 'T20__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't20.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T20__HUB_LOCATION_BK__PREV_INSURER_ADD', 'expr': 't20.HUB_LOCATION_BK__PREV_INSURER_ADD'},
    {'name': 'T21__HUB_LOCATION_BK__ADDRESS_CITY_REGION', 'expr': 't21.HUB_LOCATION_BK__ADDRESS_CITY_REGION'},
    {'name': 'T21__HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE', 'expr': 't21.HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE'},
    {'name': 'T21__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't21.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T21__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't21.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T21__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't21.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T21__HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME', 'expr': 't21.HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME'},
    {'name': 'T21__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't21.HUB_PARTY_BK__PARTID_PART_ID'},
    {'name': 'T23__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't23.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T23__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't23.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T23__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't23.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T23__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't23.HUB_PARTY_BK__HOSPITAL_CODE'},
    {'name': 'T24__HUB_PARTY_BK__CUST_NAME', 'expr': 't24.HUB_PARTY_BK__CUST_NAME'},
    {'name': 'T24__HUB_PARTY_BK__USER_NAME', 'expr': 't24.HUB_PARTY_BK__USER_NAME'},
    {'name': 'T30__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't30.HUB_PARTY_BK__PARTID_PART_ID'},
    {'name': 'T30__HUB_PARTY_BK__INTERMEDIARY_ID', 'expr': 't30.HUB_PARTY_BK__INTERMEDIARY_ID'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_common_address'
) }}
