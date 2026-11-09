/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Batch task 5.1. Procedure: the stitch_01 pilot's 9-step REUSABLE PROCEDURE.
   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_common_contact
   GRAIN DEVIATIONS (source has no spine-hub key; keyed on its real join col):
     - t22 (stg_hcp_transcript_url): no HUB_POLICY key; key_column=HUB_ASSESSMENT_BK__SCRUTINY_NO (real join key)
     - t23 (stg_hm_hospital_master): no HUB_POLICY key; key_column=HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID (real join key)
     - t24 (stg_hm_hospital_master_extn): no HUB_POLICY key; key_column=HUB_AGREEMENT_BK__HOSID (real join key)
     - t25 (stg_hm_hosp_master_extn1): no HUB_POLICY key; key_column=HUB_AGREEMENT_BK__HOSID (real join key)
     - t26 (stg_hm_preauth_request): no HUB_POLICY key; key_column=HUB_CLAIM_BK__CLAIM_ID (real join key)
     - t27 (stg_intermediary): no HUB_POLICY key; key_column=HUB_PARTY_BK__INTERMEDIARY_ID (real join key)
     - t28 (stg_neft_partner_dtls): no HUB_POLICY key; key_column=HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE (real join key)
     - t29 (stg_remedinet_patient_details): no HUB_POLICY key; key_column=HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID (real join key)
   SAME-ALIAS PAYLOAD DROPS (macro emits one col per alias per tgt; secondary dropped):
     - contact_point: kept t24.ins_dept_contact1, dropped-secondary t24.ins_dept_contact2
     - email_address: kept t8.auto_mailer_email, dropped-secondary t8.corp_email
     - email_address: kept t8.auto_mailer_email, dropped-secondary t8.rm_email
     - email_address: kept t28.email_id, dropped-secondary t28.email_id_2
     - email_address: kept t28.email_id, dropped-secondary t28.email_id_3
     - email_address: kept t2.pd_agent_email_id, dropped-secondary t2.pd_email
     - email_address: kept t3.pd_agent_email_id, dropped-secondary t3.pd_email
     - email_address: kept t4.pd_agent_email_id, dropped-secondary t4.pd_email
     - email_address: kept t5.pd_agent_email_id, dropped-secondary t5.pd_email
     - email_address: kept t25.adminemail, dropped-secondary t25.billingemail
     - email_address: kept t25.adminemail, dropped-secondary t25.ceoemail
     - email_address: kept t25.adminemail, dropped-secondary t25.meddiremail
     - email_address: kept t25.adminemail, dropped-secondary t25.medsupernameemail
     - email_address: kept t25.adminemail, dropped-secondary t25.mktheademail
     - email_address: kept t25.adminemail, dropped-secondary t25.tpaemail
     - email_address: kept t15.caller_email_id, dropped-secondary t15.email_id
     - email_address: kept t15.caller_email_id, dropped-secondary t15.insured_email_id
     - landline_number: kept t14.phone, dropped-secondary t14.telephone
     - mobile_number: kept t24.mobile_no, dropped-secondary t24.mob_fin_officer
     - mobile_number: kept t25.adminmobileno, dropped-secondary t25.billingmobileno
     - mobile_number: kept t25.adminmobileno, dropped-secondary t25.ceomobileno
     - mobile_number: kept t25.adminmobileno, dropped-secondary t25.meddirmob
     - mobile_number: kept t25.adminmobileno, dropped-secondary t25.medsupernamemobno
     - mobile_number: kept t25.adminmobileno, dropped-secondary t25.mktheadmobileno
     - mobile_number: kept t15.caller_contact_no, dropped-secondary t15.insured_contact_no
     - mobile_number: kept t15.caller_contact_no, dropped-secondary t15.mobile_no
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_port_wordings',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'email', 'tgt': 'email_address'}
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
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'dc_teleno', 'tgt': 'landline_number'}
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
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_agent_email_id', 'tgt': 'email_address'},
            {'src': 'pd_fax', 'tgt': 'fax_number'},
            {'src': 'pd_telephone', 'tgt': 'landline_number'},
            {'src': 'pd_mobile_number', 'tgt': 'mobile_number'}
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
            {'src': 'pd_agent_email_id', 'tgt': 'email_address'},
            {'src': 'pd_fax', 'tgt': 'fax_number'},
            {'src': 'pd_telephone', 'tgt': 'landline_number'},
            {'src': 'pd_mobile_number', 'tgt': 'mobile_number'}
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
            {'src': 'pd_agent_email_id', 'tgt': 'email_address'},
            {'src': 'pd_fax', 'tgt': 'fax_number'},
            {'src': 'pd_telephone', 'tgt': 'landline_number'},
            {'src': 'pd_mobile_number', 'tgt': 'mobile_number'}
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
            {'src': 'pd_agent_email_id', 'tgt': 'email_address'},
            {'src': 'pd_fax', 'tgt': 'fax_number'},
            {'src': 'pd_telephone', 'tgt': 'landline_number'},
            {'src': 'pd_mobile_number', 'tgt': 'mobile_number'}
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
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'm_email', 'tgt': 'alternate_email_address'},
            {'src': 'm_mobile', 'tgt': 'alternate_mobile_number'},
            {'src': 'p_email', 'tgt': 'email_address'},
            {'src': 'mobile', 'tgt': 'mobile_number'}
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
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'mobile2', 'tgt': 'alternate_mobile_number'},
            {'src': 'email', 'tgt': 'email_address'},
            {'src': 'mobile1', 'tgt': 'mobile_number'}
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
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'contact_person', 'tgt': 'contact_person_name'},
            {'src': 'auto_mailer_email', 'tgt': 'email_address'},
            {'src': 'contact_detail', 'tgt': 'mobile_number'}
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
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'email', 'tgt': 'email_address'},
            {'src': 'fax', 'tgt': 'fax_number'},
            {'src': 'telephone', 'tgt': 'landline_number'},
            {'src': 'mobilenumber', 'tgt': 'mobile_number'}
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
        'model': 'stg_grp_hlt_cust_dtls',
        'alias': 't10',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'e_mail_id', 'tgt': 'email_address'},
            {'src': 'phone_number', 'tgt': 'landline_number'},
            {'src': 'mobile', 'tgt': 'mobile_number'}
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
            {'src': 'email_id', 'tgt': 'email_address'},
            {'src': 'tel', 'tgt': 'landline_number'}
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
            {'src': 'email_cust', 'tgt': 'alternate_email_address'},
            {'src': 'email', 'tgt': 'email_address'},
            {'src': 'telephone', 'tgt': 'landline_number'},
            {'src': 'mobile_no', 'tgt': 'mobile_number'}
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
        'model': 'stg_hm_gmc_ahc',
        'alias': 't13',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'email_id', 'tgt': 'email_address'},
            {'src': 'contact_no', 'tgt': 'mobile_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_GMC_AHC'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't14',
        'key_column': 'HUB_POLICY_BK__POLICY',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'fax', 'tgt': 'fax_number'},
            {'src': 'phone', 'tgt': 'landline_number'},
            {'src': 'mobile_no', 'tgt': 'mobile_number'},
            {'src': 'std', 'tgt': 'std_code'}
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
            {'src': 'caller_email_id', 'tgt': 'email_address'},
            {'src': 'caller_contact_no', 'tgt': 'mobile_number'}
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
            {'src': 'email_id', 'tgt': 'email_address'},
            {'src': 'phone_no', 'tgt': 'landline_number'}
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
        'alias': 't17',
        'key_column': 'HUB_POLICY_BK__POLICY_NUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'telephone_no', 'tgt': 'landline_number'}
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
        'alias': 't18',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'emailid', 'tgt': 'email_address'},
            {'src': 'mobileno', 'tgt': 'mobile_number'}
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
        'alias': 't19',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'contact_person', 'tgt': 'contact_person_name'},
            {'src': 'mailid', 'tgt': 'email_address'},
            {'src': 'telephone', 'tgt': 'landline_number'},
            {'src': 'mobile_no', 'tgt': 'mobile_number'}
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
        'alias': 't20',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'email_id', 'tgt': 'email_address'}
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
        'alias': 't21',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'email_id_1', 'tgt': 'email_address'},
            {'src': 'mob_no', 'tgt': 'mobile_number'}
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
        'model': 'stg_hcp_transcript_url',
        'alias': 't22',
        'key_column': 'HUB_ASSESSMENT_BK__SCRUTINY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'partner_mail_id', 'tgt': 'email_address'},
            {'src': 'partner_mobile_no', 'tgt': 'mobile_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'imd_code', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCP_TRANSCRIPT_URL'
    },
    {
        'model': 'stg_hm_hospital_master',
        'alias': 't23',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'designation', 'tgt': 'contact_person_designation'},
            {'src': 'contact_person', 'tgt': 'contact_person_name'},
            {'src': 'email', 'tgt': 'email_address'},
            {'src': 'fax_no', 'tgt': 'fax_number'},
            {'src': 'phone_no', 'tgt': 'landline_number'},
            {'src': 'std_code', 'tgt': 'std_code'}
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
        'alias': 't24',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'ins_dept_contact1', 'tgt': 'contact_point'},
            {'src': 'email_fin_dept', 'tgt': 'email_address'},
            {'src': 'fax_no2', 'tgt': 'fax_number'},
            {'src': 'phone_no2', 'tgt': 'landline_number'},
            {'src': 'mobile_no', 'tgt': 'mobile_number'}
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
        'alias': 't25',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'adminemail', 'tgt': 'email_address'},
            {'src': 'adminmobileno', 'tgt': 'mobile_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSP_MASTER_EXTN1'
    },
    {
        'model': 'stg_hm_preauth_request',
        'alias': 't26',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'insured_email', 'tgt': 'email_address'},
            {'src': 'patient_contact_no', 'tgt': 'mobile_number'}
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
        'alias': 't27',
        'key_column': 'HUB_PARTY_BK__INTERMEDIARY_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'username', 'tgt': 'email_address'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(BUSINESS_CHANNEL),'')", 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL'},
            {'src_expr': "nullif(trim(NEW_BC),'')", 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC'},
            {'src_expr': "nullif(trim(INTERMEDIARY_ID),'')", 'tgt': 'HUB_PARTY_BK__INTERMEDIARY_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_INTERMEDIARY'
    },
    {
        'model': 'stg_neft_partner_dtls',
        'alias': 't28',
        'key_column': 'HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'email_id', 'tgt': 'email_address'},
            {'src': 'branch_contact_no_2', 'tgt': 'landline_number'},
            {'src': 'mobile_no', 'tgt': 'mobile_number'}
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
        'alias': 't29',
        'key_column': 'HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'email_id', 'tgt': 'email_address'},
            {'src': 'fax_no', 'tgt': 'fax_number'},
            {'src': 'phone_no', 'tgt': 'landline_number'},
            {'src': 'mobile_no', 'tgt': 'mobile_number'}
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
    'alternate_email_address', 'alternate_mobile_number', 'contact_person_designation', 'contact_person_name', 'contact_point', 'email_address', 'fax_number', 'landline_number', 'mobile_number', 'std_code'
] -%}

{%- set coalesce_rules = {
    'alternate_email_address': ['t6', 't12'],
    'alternate_mobile_number': ['t6', 't7'],
    'contact_person_designation': ['t23'],
    'contact_person_name': ['t8', 't23', 't19'],
    'contact_point': ['t24'],
    'email_address': ['t8', 't26', 't27', 't28', 't18', 't0', 't2', 't3', 't4', 't5', 't6', 't7', 't9', 't10', 't11', 't22', 't12', 't13', 't23', 't24', 't25', 't15', 't16', 't20', 't21', 't19', 't29'],
    'fax_number': ['t2', 't3', 't4', 't5', 't9', 't14', 't23', 't24', 't29'],
    'landline_number': ['t28', 't1', 't2', 't3', 't4', 't5', 't9', 't10', 't11', 't12', 't14', 't23', 't24', 't16', 't17', 't19', 't29'],
    'mobile_number': ['t8', 't26', 't28', 't18', 't2', 't3', 't4', 't5', 't6', 't7', 't9', 't10', 't22', 't12', 't13', 't14', 't24', 't25', 't15', 't21', 't19', 't29'],
    'std_code': ['t14', 't23']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 'coalesce(t23.HUB_AGREEMENT_BK__HOSID, t24.HUB_AGREEMENT_BK__HOSID, t25.HUB_AGREEMENT_BK__HOSID)'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__SCRUTINY_NO, t1.HUB_ASSESSMENT_BK__SCRUTINY_NO, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t3.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t4.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t5.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t6.HUB_ASSESSMENT_BK__SCRUTINY_NO, t7.HUB_ASSESSMENT_BK__SCRUTINY_NO, t22.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t6.HUB_CLAIM_BK__REFERENCE_ID, t14.HUB_CLAIM_BK__CLID, t15.HUB_CLAIM_BK__CLAIM_ID, t17.HUB_CLAIM_BK__CLAIM_ID, t21.HUB_CLAIM_BK__BJAZ_CLAIM_ID, t26.HUB_CLAIM_BK__CLAIM_ID, t29.HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 't12.HUB_COVERAGE_BK__COVER_CODE'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t9.HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID, t12.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t14.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t16.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t18.HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO, t20.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t21.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t22.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t23.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t24.HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t15.HUB_DOCUMENT_BK__INWARD_ID, t20.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t2.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t3.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t4.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t5.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t14.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO, t16.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t14.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t21.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 'coalesce(t6.HUB_LOCATION_BK__LOCATION_CODE, t18.HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE, t23.HUB_LOCATION_BK__PIN_CODE, t28.HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE, t29.HUB_LOCATION_BK__ADDRESS1_ADDRESS2_ADDRESS3_CITY)'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t14.HUB_LOSS_EVENT_BK__CLAIM_NO, t15.HUB_LOSS_EVENT_BK__CLAIM_ID, t21.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t3.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t4.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t5.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t7.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t1.HUB_PARTY_BK__ALLOTED_TO, t6.HUB_PARTY_BK__CUSTOMER_ID, t11.HUB_PARTY_BK__MEMBER_NO, t12.HUB_PARTY_BK__PART_ID, t14.HUB_PARTY_BK__HOSPITAL_ID, t15.HUB_PARTY_BK__COURIER_ID, t16.HUB_PARTY_BK__MEMBER_ID, t20.HUB_PARTY_BK__MEMBER_NO, t23.HUB_PARTY_BK__HOSID, t24.HUB_PARTY_BK__HOSID, t25.HUB_PARTY_BK__HOSID, t27.HUB_PARTY_BK__INTERMEDIARY_ID, t29.HUB_PARTY_BK__MEMBER_MEMBER_NO)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t14.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t21.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__CONTRACT_ID, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__POL_SERIAL_NO, t4.HUB_POLICY_BK__POL_SERIAL_NO, t5.HUB_POLICY_BK__POL_SERIAL_NO, t6.HUB_POLICY_BK__POLICY_REF, t7.HUB_POLICY_BK__POLICY_REF, t8.HUB_POLICY_BK__POLICY_NO, t9.HUB_POLICY_BK__PMASTERPOLICYNUMBER, t10.HUB_POLICY_BK__REG_NO, t11.HUB_POLICY_BK__CONTRACT_ID, t12.HUB_POLICY_BK__CONTRACT_ID, t13.HUB_POLICY_BK__POLICY_NO, t14.HUB_POLICY_BK__POLICY, t15.HUB_POLICY_BK__POLICY_REF, t16.HUB_POLICY_BK__CONTRACT_ID, t17.HUB_POLICY_BK__POLICY_NUMBER, t18.HUB_POLICY_BK__POLICY_REF, t19.HUB_POLICY_BK__CONTRACT_ID, t20.HUB_POLICY_BK__CONTRACT_ID, t21.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t3.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t4.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t5.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t7.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t10.HUB_PRODUCT_BK__PRODUCT, t12.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t16.HUB_PRODUCT_BK__PRODUCT_CODE, t19.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t22.HUB_PRODUCT_BK__PRODUCT_CODE)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t1.HUB_PROPOSAL_BK__HI_CONTROL_NUMBER, t8.HUB_PROPOSAL_BK__SCRUTINY_NO, t12.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t8.HUB_QUOTE_BK__QUOTATION_NO, t10.HUB_QUOTE_BK__QUOTE_SUB_NO, t12.HUB_QUOTE_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t2.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t4.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t18.HUB_RISK_OBJECT_BK__CUSTID_CUST_ID, t29.HUB_RISK_OBJECT_BK__MEMBER_MEMBER_NO)'},
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
    {'name': 'T6__HUB_PRODUCT_BK__PLAN_ID', 'expr': 't6.HUB_PRODUCT_BK__PLAN_ID'},
    {'name': 'T6__HUB_PRODUCT_BK__PRODUCT_CODE', 'expr': 't6.HUB_PRODUCT_BK__PRODUCT_CODE'},
    {'name': 'T7__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't7.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T7__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't7.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T7__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't7.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T7__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't7.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T7__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't7.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T8__HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN', 'expr': 't8.HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN'},
    {'name': 'T8__HUB_LOCATION_BK__PH_ADDRESS', 'expr': 't8.HUB_LOCATION_BK__PH_ADDRESS'},
    {'name': 'T8__HUB_LOCATION_BK__PP_ADDRESS', 'expr': 't8.HUB_LOCATION_BK__PP_ADDRESS'},
    {'name': 'T8__HUB_PARTY_BK__EMP_RM_CODE', 'expr': 't8.HUB_PARTY_BK__EMP_RM_CODE'},
    {'name': 'T8__HUB_PARTY_BK__CORPORATE_ID', 'expr': 't8.HUB_PARTY_BK__CORPORATE_ID'},
    {'name': 'T8__HUB_PARTY_BK__IMD_CODE', 'expr': 't8.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T8__HUB_PARTY_BK__PH_ID', 'expr': 't8.HUB_PARTY_BK__PH_ID'},
    {'name': 'T8__HUB_PARTY_BK__PP_ID', 'expr': 't8.HUB_PARTY_BK__PP_ID'},
    {'name': 'T8__HUB_PARTY_BK__SUBIMD_CODE', 'expr': 't8.HUB_PARTY_BK__SUBIMD_CODE'},
    {'name': 'T9__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't9.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T9__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't9.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T9__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't9.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T9__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't9.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T9__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't9.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T9__HUB_PRODUCT_BK__PLANID', 'expr': 't9.HUB_PRODUCT_BK__PLANID'},
    {'name': 'T9__HUB_PRODUCT_BK__SCHEMECODE', 'expr': 't9.HUB_PRODUCT_BK__SCHEMECODE'},
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
    {'name': 'T17__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't17.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T17__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't17.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T17__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't17.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T17__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't17.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T17__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't17.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T18__HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME', 'expr': 't18.HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME'},
    {'name': 'T18__HUB_PARTY_BK__CUST_ID', 'expr': 't18.HUB_PARTY_BK__CUST_ID'},
    {'name': 'T19__HUB_LOCATION_BK__ADDRESS_CITY_REGION', 'expr': 't19.HUB_LOCATION_BK__ADDRESS_CITY_REGION'},
    {'name': 'T19__HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE', 'expr': 't19.HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE'},
    {'name': 'T19__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't19.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T19__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't19.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T19__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't19.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T19__HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME', 'expr': 't19.HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME'},
    {'name': 'T19__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't19.HUB_PARTY_BK__PARTID_PART_ID'},
    {'name': 'T21__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't21.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T21__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't21.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T21__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't21.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T21__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't21.HUB_PARTY_BK__HOSPITAL_CODE'},
    {'name': 'T26__HUB_DOCUMENT_BK__FIR_FIR_NO', 'expr': 't26.HUB_DOCUMENT_BK__FIR_FIR_NO'},
    {'name': 'T26__HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO', 'expr': 't26.HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO'},
    {'name': 'T26__HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO', 'expr': 't26.HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO'},
    {'name': 'T26__HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD', 'expr': 't26.HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD'},
    {'name': 'T26__HUB_PARTY_BK__HOSPID_HOS_ID', 'expr': 't26.HUB_PARTY_BK__HOSPID_HOS_ID'},
    {'name': 'T27__HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL', 'expr': 't27.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL'},
    {'name': 'T27__HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC', 'expr': 't27.HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC'},
    {'name': 'T28__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't28.HUB_PARTY_BK__PARTID_PART_ID'},
    {'name': 'T28__HUB_PARTY_BK__INTERMEDIARY_ID', 'expr': 't28.HUB_PARTY_BK__INTERMEDIARY_ID'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_common_contact'
) }}
