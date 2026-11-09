/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Batch task 5.1. Procedure: the stitch_01 pilot's 9-step REUSABLE PROCEDURE.
   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_party_identification
   GRAIN DEVIATIONS (source has no spine-hub key; keyed on its real join col):
     - t19 (stg_hm_hospital_master): no HUB_POLICY key; key_column=HUB_AGREEMENT_BK__HOSID (real join key)
     - t20 (stg_hm_hospital_master_extn): no HUB_POLICY key; key_column=HUB_AGREEMENT_BK__HOSID (real join key)
     - t21 (stg_hm_preauth_request): no HUB_POLICY key; key_column=HUB_CLAIM_BK__CLAIM_ID (real join key)
     - t22 (stg_intermediary): no HUB_POLICY key; key_column=HUB_PARTY_BK__INTERMEDIARY_ID (real join key)
     - t23 (stg_neft_partner_dtls): no HUB_POLICY key; key_column=HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE (real join key)
   SAME-ALIAS PAYLOAD DROPS (macro emits one col per alias per tgt; secondary dropped):
     - identification_number: kept t20.irda_unique_id, dropped-secondary t20.rohini_code
     - identification_number: kept t16.supp_id, dropped-secondary t16.workshop_id
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_prod_8428_gpg_loader',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_adhar_card_no', 'tgt': 'aadhaar_number'},
            {'src': 'gstin_uin', 'tgt': 'gstin'},
            {'src': 'pd_bank_ref_no2_bank_cust_id', 'tgt': 'identification_number'},
            {'src': 'pd_pan_no', 'tgt': 'pan_number'},
            {'src': 'pd_electronic_insur_account_no', 'tgt': 'eia_number'}
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
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_adhar_card_no', 'tgt': 'aadhaar_number'},
            {'src': 'gstin_uin', 'tgt': 'gstin'},
            {'src': 'pd_pan_no', 'tgt': 'pan_number'},
            {'src': 'pd_electronic_insur_account_no', 'tgt': 'eia_number'}
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
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_adhar_card_no', 'tgt': 'aadhaar_number'},
            {'src': 'gstin_uin', 'tgt': 'gstin'},
            {'src': 'pd_pan_no', 'tgt': 'pan_number'},
            {'src': 'pd_electronic_insur_account_no', 'tgt': 'eia_number'}
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
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_a_card_no', 'tgt': 'aadhaar_number'},
            {'src': 'gstin_uin', 'tgt': 'gstin'},
            {'src': 'pd_pan_no', 'tgt': 'pan_number'},
            {'src': 'pd_electronic_insur_account_no', 'tgt': 'eia_number'}
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
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'aadhaar_number', 'tgt': 'aadhaar_number'},
            {'src': 'gst_reg_no', 'tgt': 'gstin'},
            {'src': 'pan_no', 'tgt': 'pan_number'}
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
        'model': 'stg_ec_mem_dtls_extn',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age_proof', 'tgt': 'age_proof_type'}
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
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gstin_no', 'tgt': 'gstin'}
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
        'model': 'stg_generic_loader_log_table',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'aadhar_valid_status', 'tgt': 'aadhaar_verification_status'},
            {'src': 'pan_valid_status', 'tgt': 'pan_verification_status'},
            {'src': 'passportno', 'tgt': 'passport_number'}
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
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'partner_gstn', 'tgt': 'gstin'}
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
        'model': 'stg_grp_hlt_maternity_dtls',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'partner_gstn', 'tgt': 'gstin'}
        ],
        'hub_key_columns': [
            {'src_expr': 'reg_no', 'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product', 'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_MATERNITY_DTLS'
    },
    {
        'model': 'stg_hg_pol_dtls',
        'alias': 't10',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'aadhar_yn', 'tgt': 'aadhaar_available_indicator'},
            {'src': 'aadhaar_no', 'tgt': 'aadhaar_number'},
            {'src': 'partner_gstn', 'tgt': 'gstin'},
            {'src': 'pan_number', 'tgt': 'pan_number'},
            {'src': 'pan_ind_cover_yn', 'tgt': 'pan_provided_indicator'}
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
        'alias': 't11',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age_proof_yn', 'tgt': 'age_proof_type'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HLT_ENSURE_MEM_DTLS'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't12',
        'key_column': 'HUB_POLICY_BK__POLICY',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'id_card', 'tgt': 'identification_number'},
            {'src': 'pan_no', 'tgt': 'pan_number'}
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
        'alias': 't13',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'passport_no', 'tgt': 'passport_number'}
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
        'model': 'stg_ihg_mem_dtls_extn',
        'alias': 't14',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age_proof', 'tgt': 'age_proof_type'}
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
        'model': 'stg_pmsby_data_web_service',
        'alias': 't15',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'aadharno', 'tgt': 'aadhaar_number'},
            {'src': 'pancardno', 'tgt': 'pan_number'}
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
        'alias': 't16',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'supp_id', 'tgt': 'identification_number'}
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
        'alias': 't17',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'irda_id', 'tgt': 'identification_number'}
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
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't18',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pan_no', 'tgt': 'pan_number'}
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
        'model': 'stg_hm_hospital_master',
        'alias': 't19',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'stax_reg_no', 'tgt': 'identification_number'},
            {'src': 'partner_id', 'tgt': 'partner_identifier'},
            {'src': 'hospital_no', 'tgt': 'provider_registration_number'}
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
        'alias': 't20',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'irda_unique_id', 'tgt': 'identification_number'},
            {'src': 'tan_no', 'tgt': 'tan_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'distribution_partner', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSPITAL_MASTER_EXTN'
    },
    {
        'model': 'stg_hm_preauth_request',
        'alias': 't21',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'emp_id', 'tgt': 'identification_number'}
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
        'alias': 't22',
        'key_column': 'HUB_PARTY_BK__INTERMEDIARY_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gst_status', 'tgt': 'gst_registration_status'},
            {'src': 'gst_no', 'tgt': 'gstin'},
            {'src': 'pan_aadhar_linked', 'tgt': 'pan_aadhaar_linked_indicator'},
            {'src': 'pan_number', 'tgt': 'pan_number'}
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
        'alias': 't23',
        'key_column': 'HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'supplier_id', 'tgt': 'identification_number'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(trim(MANDATE_ADDRESS),'') || '|' || coalesce(trim(AREA),'') || '|' || coalesce(trim(CITY),'') || '|' || coalesce(trim(STATE),'') || '|' || coalesce(trim(to_char(PINCODE)),''), '||||'))))", 'tgt': 'HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE'},
            {'src_expr': "nullif('PARTID:' || nullif(trim(PART_ID),''), 'PARTID:')", 'tgt': 'HUB_PARTY_BK__PARTID_PART_ID'},
            {'src_expr': "nullif(trim(INTERMEDIARY_ID),'')", 'tgt': 'HUB_PARTY_BK__INTERMEDIARY_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_NEFT_PARTNER_DTLS'
    }
] -%}

{%- set output_columns = [
    'aadhaar_available_indicator', 'aadhaar_number', 'aadhaar_verification_status', 'age_proof_type', 'gst_registration_status', 'gstin', 'identification_number', 'pan_aadhaar_linked_indicator', 'pan_number', 'pan_provided_indicator', 'pan_verification_status', 'partner_identifier', 'passport_number', 'provider_registration_number', 'tan_number', 'eia_number'
] -%}

{%- set coalesce_rules = {
    'aadhaar_available_indicator': ['t10'],
    'aadhaar_number': ['t15', 't0', 't1', 't2', 't3', 't4', 't10'],
    'aadhaar_verification_status': ['t7'],
    'age_proof_type': ['t5', 't11', 't14'],
    'gst_registration_status': ['t22'],
    'gstin': ['t22', 't0', 't1', 't2', 't3', 't4', 't6', 't8', 't9', 't10'],
    'identification_number': ['t21', 't23', 't0', 't12', 't19', 't20', 't17', 't16'],
    'pan_aadhaar_linked_indicator': ['t22'],
    'pan_number': ['t22', 't15', 't0', 't1', 't2', 't3', 't4', 't10', 't12', 't18'],
    'pan_provided_indicator': ['t10'],
    'pan_verification_status': ['t7'],
    'partner_identifier': ['t19'],
    'passport_number': ['t7', 't13'],
    'provider_registration_number': ['t19'],
    'tan_number': ['t20'],
    'eia_number': ['t0', 't1', 't2', 't3']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 'coalesce(t17.HUB_AGREEMENT_BK__REMEDINET_PROVIDER_CODE, t19.HUB_AGREEMENT_BK__HOSID, t20.HUB_AGREEMENT_BK__HOSID)'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t3.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t4.HUB_ASSESSMENT_BK__SCRUTINY_NO, t6.HUB_ASSESSMENT_BK__SCRUTINY_NO, t8.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t4.HUB_CLAIM_BK__REFERENCE_ID, t12.HUB_CLAIM_BK__CLID, t13.HUB_CLAIM_BK__CLAIM_ID, t17.HUB_CLAIM_BK__CLAIM_NO, t18.HUB_CLAIM_BK__BJAZ_CLAIM_ID, t21.HUB_CLAIM_BK__CLAIM_ID)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 't10.HUB_COVERAGE_BK__COVER_CODE'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID, t8.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t10.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t11.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t12.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t14.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t15.HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO, t18.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t19.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t20.HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t5.HUB_DOCUMENT_BK__MEDICAL_REPORT, t13.HUB_DOCUMENT_BK__INWARD_ID, t14.HUB_DOCUMENT_BK__MEDICAL_REPORT, t17.HUB_DOCUMENT_BK__OMNI_INWARD_NO)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t0.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t1.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t2.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t3.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t8.HUB_FINANCIAL_ACCOUNT_BK__LMS_NO, t12.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t12.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t18.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 'coalesce(t4.HUB_LOCATION_BK__LOCATION_CODE, t15.HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE, t19.HUB_LOCATION_BK__PIN_CODE, t23.HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE)'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t12.HUB_LOSS_EVENT_BK__CLAIM_NO, t13.HUB_LOSS_EVENT_BK__CLAIM_ID, t18.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t0.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t3.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t6.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT, t8.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t4.HUB_PARTY_BK__CUSTOMER_ID, t5.HUB_PARTY_BK__MEMBER_NO, t10.HUB_PARTY_BK__PART_ID, t11.HUB_PARTY_BK__MEMBER_NO, t12.HUB_PARTY_BK__HOSPITAL_ID, t13.HUB_PARTY_BK__COURIER_ID, t14.HUB_PARTY_BK__MEMBER_NO, t19.HUB_PARTY_BK__HOSID, t20.HUB_PARTY_BK__HOSID, t22.HUB_PARTY_BK__INTERMEDIARY_ID)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t12.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t18.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__POL_SERIAL_NO, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__POL_SERIAL_NO, t4.HUB_POLICY_BK__POLICY_REF, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__POLICY_REF, t7.HUB_POLICY_BK__PMASTERPOLICYNUMBER, t8.HUB_POLICY_BK__REFERENCE_ID, t9.HUB_POLICY_BK__REG_NO, t10.HUB_POLICY_BK__CONTRACT_ID, t11.HUB_POLICY_BK__CONTRACT_ID, t12.HUB_POLICY_BK__POLICY, t13.HUB_POLICY_BK__POLICY_REF, t14.HUB_POLICY_BK__CONTRACT_ID, t15.HUB_POLICY_BK__POLICY_REF, t16.HUB_POLICY_BK__CONTRACT_ID, t17.HUB_POLICY_BK__POLICY_NO, t18.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t3.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t6.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t8.HUB_PRODUCT_BK__PRODUCT_CODE, t9.HUB_PRODUCT_BK__PRODUCT, t10.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t16.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 't10.HUB_PROPOSAL_BK__QUOTE_REF_NO'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t9.HUB_QUOTE_BK__QUOTE_SUB_NO, t10.HUB_QUOTE_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_REINSURANCE_TREATY_BK', 'expr': 't8.HUB_REINSURANCE_TREATY_BK__RE_INSU'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t0.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t2.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t5.HUB_RISK_OBJECT_BK__MEMBER_NO, t15.HUB_RISK_OBJECT_BK__CUSTID_CUST_ID)'},
    {'name': 'T0__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't0.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T1__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't1.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T2__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't2.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T3__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't3.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T3__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't3.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T3__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't3.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T4__HUB_PRODUCT_BK__PLAN_ID', 'expr': 't4.HUB_PRODUCT_BK__PLAN_ID'},
    {'name': 'T4__HUB_PRODUCT_BK__PRODUCT_CODE', 'expr': 't4.HUB_PRODUCT_BK__PRODUCT_CODE'},
    {'name': 'T6__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't6.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T6__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't6.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T6__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't6.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T6__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't6.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T6__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't6.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T7__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't7.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T7__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't7.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T7__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't7.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T7__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't7.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T7__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't7.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T7__HUB_PRODUCT_BK__PLANID', 'expr': 't7.HUB_PRODUCT_BK__PLANID'},
    {'name': 'T7__HUB_PRODUCT_BK__SCHEMECODE', 'expr': 't7.HUB_PRODUCT_BK__SCHEMECODE'},
    {'name': 'T8__HUB_PARTY_BK__BAGIC_E_CODE', 'expr': 't8.HUB_PARTY_BK__BAGIC_E_CODE'},
    {'name': 'T8__HUB_PARTY_BK__BAGIC_RM_E_CODE', 'expr': 't8.HUB_PARTY_BK__BAGIC_RM_E_CODE'},
    {'name': 'T8__HUB_PARTY_BK__IMD_CODE', 'expr': 't8.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T8__HUB_PARTY_BK__SUB_IMD_CODE', 'expr': 't8.HUB_PARTY_BK__SUB_IMD_CODE'},
    {'name': 'T10__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't10.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T10__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't10.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T12__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't12.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T12__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't12.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T12__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't12.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T12__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't12.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T12__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't12.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T13__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't13.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T13__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't13.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T13__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't13.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T13__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't13.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T13__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't13.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T15__HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME', 'expr': 't15.HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME'},
    {'name': 'T15__HUB_PARTY_BK__CUST_ID', 'expr': 't15.HUB_PARTY_BK__CUST_ID'},
    {'name': 'T16__HUB_LOCATION_BK__ADDRESS_CITY_REGION', 'expr': 't16.HUB_LOCATION_BK__ADDRESS_CITY_REGION'},
    {'name': 'T16__HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE', 'expr': 't16.HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE'},
    {'name': 'T16__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't16.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T16__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't16.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T16__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't16.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T16__HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME', 'expr': 't16.HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME'},
    {'name': 'T16__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't16.HUB_PARTY_BK__PARTID_PART_ID'},
    {'name': 'T17__HUB_PARTY_BK__PAYER_CODE', 'expr': 't17.HUB_PARTY_BK__PAYER_CODE'},
    {'name': 'T17__HUB_PARTY_BK__REMEDINET_PROVIDER_CODE', 'expr': 't17.HUB_PARTY_BK__REMEDINET_PROVIDER_CODE'},
    {'name': 'T18__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't18.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T18__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't18.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T18__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't18.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T18__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't18.HUB_PARTY_BK__HOSPITAL_CODE'},
    {'name': 'T21__HUB_DOCUMENT_BK__FIR_FIR_NO', 'expr': 't21.HUB_DOCUMENT_BK__FIR_FIR_NO'},
    {'name': 'T21__HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO', 'expr': 't21.HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO'},
    {'name': 'T21__HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO', 'expr': 't21.HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO'},
    {'name': 'T21__HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD', 'expr': 't21.HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD'},
    {'name': 'T21__HUB_PARTY_BK__HOSPID_HOS_ID', 'expr': 't21.HUB_PARTY_BK__HOSPID_HOS_ID'},
    {'name': 'T22__HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL', 'expr': 't22.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL'},
    {'name': 'T22__HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC', 'expr': 't22.HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC'},
    {'name': 'T23__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't23.HUB_PARTY_BK__PARTID_PART_ID'},
    {'name': 'T23__HUB_PARTY_BK__INTERMEDIARY_ID', 'expr': 't23.HUB_PARTY_BK__INTERMEDIARY_ID'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_party_identification'
) }}
