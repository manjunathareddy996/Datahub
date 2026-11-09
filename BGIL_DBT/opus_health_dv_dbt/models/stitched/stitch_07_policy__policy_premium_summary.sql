/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Batch task 5.1. Procedure: the stitch_01 pilot's 9-step REUSABLE PROCEDURE.
   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_policy_premium_summary
   (no grain deviations; no same-alias payload drops)
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_ba_ccp_sub_mater_dtls',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'tot_sec_prem', 'tgt': 'base_premium'},
            {'src': 'final_prem', 'tgt': 'gross_premium'},
            {'src': 'long_trm_disc', 'tgt': 'long_term_discount_amount'},
            {'src': 'net_prem', 'tgt': 'net_premium'},
            {'src': 'terr_prem', 'tgt': 'terrorism_premium'},
            {'src': 'amt_collected_cust', 'tgt': 'total_premium_collected'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('LOANACC:' || nullif(trim(LOAN_ACC_NUMBER),''), 'LOANACC:')", 'tgt': 'HUB_RISK_OBJECT_BK__LOANACC_LOAN_ACC_NUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BA_CCP_SUB_MATER_DTLS'
    },
    {
        'model': 'stg_hcp_dt_premium',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'total_prem_on_base_cov_addon', 'tgt': 'add_on_premium'},
            {'src': 'total_prem_on_base_cov', 'tgt': 'base_premium'},
            {'src': 'pol_gross_prem_amt', 'tgt': 'gross_premium'},
            {'src': 'pol_net_prem_amt', 'tgt': 'net_premium'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno', 'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'user_id', 'tgt': 'HUB_PARTY_BK__USER_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_PREMIUM'
    },
    {
        'model': 'stg_hcp_pol_mst',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'group_discount', 'tgt': 'group_discount_amount'}
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
        'model': 'stg_hcp_prime_rider_dtls',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__BASE_POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'total_final_premium', 'tgt': 'gross_premium'},
            {'src': 'total_net_premium', 'tgt': 'net_premium'}
        ],
        'hub_key_columns': [
            {'src_expr': 'base_policy_ref', 'tgt': 'HUB_POLICY_BK__BASE_POLICY_REF'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PRIME_RIDER_DTLS'
    },
    {
        'model': 'stg_hcp_prod_8428_gpg_loader',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_premium_including_st', 'tgt': 'gross_premium'}
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
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_premium_including_st', 'tgt': 'gross_premium'}
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
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_premium_including_st', 'tgt': 'gross_premium'}
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
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_premium_including_st', 'tgt': 'gross_premium'}
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
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'installments', 'tgt': 'instalment_count'}
        ],
        'hub_key_columns': [
            {'src_expr': 'emp_code', 'tgt': 'HUB_PARTY_BK__EMP_CODE'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BGIL_GMC_FINAL_INSTL_DATA'
    },
    {
        'model': 'stg_bandhan_medi_clam',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gross_preminum', 'tgt': 'gross_premium'}
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
        'alias': 't10',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gross_premium', 'tgt': 'gross_premium'}
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
        'model': 'stg_enroll_scr_dtls',
        'alias': 't11',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'total_base_premium', 'tgt': 'base_premium'},
            {'src': 'base_premium', 'tgt': 'base_premium_before_adjustment'},
            {'src': 'environment_fund', 'tgt': 'environment_relief_fund_amount'},
            {'src': 'final_premium', 'tgt': 'gross_premium'},
            {'src': 'group_discount', 'tgt': 'group_discount_amount'},
            {'src': 'installment_no', 'tgt': 'instalment_count'},
            {'src': 'installment_option_yn', 'tgt': 'instalment_indicator'},
            {'src': 'net_premium', 'tgt': 'net_premium'},
            {'src': 'premium_with_commm', 'tgt': 'premium_inclusive_of_commission_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(SCRUTINY_NO),'')", 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif(trim(QUOTATION_NO),'')", 'tgt': 'HUB_QUOTE_BK__QUOTATION_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_ENROLL_SCR_DTLS'
    },
    {
        'model': 'stg_generic_loader_log_table',
        'alias': 't12',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pgrosspremium', 'tgt': 'gross_premium'},
            {'src': 'ptotalpremium', 'tgt': 'total_premium_collected'}
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
        'alias': 't13',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'total_addon_premium', 'tgt': 'add_on_premium'},
            {'src': 'total_base_premium', 'tgt': 'base_premium'},
            {'src': 'full_yr_net_prem', 'tgt': 'full_year_net_premium'},
            {'src': 'final_premium', 'tgt': 'gross_premium'},
            {'src': 'long_term_discount', 'tgt': 'long_term_discount_amount'},
            {'src': 'net_premium', 'tgt': 'net_premium'},
            {'src': 'full_yr_terr_prem', 'tgt': 'terrorism_premium'}
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
        'alias': 't14',
        'key_column': 'HUB_POLICY_BK__MASTER_POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gross_premium', 'tgt': 'gross_premium'}
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
        'model': 'stg_grp_hlt_maternity_dtls',
        'alias': 't15',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'base_premium', 'tgt': 'base_premium'},
            {'src': 'gross_permium', 'tgt': 'gross_premium'},
            {'src': 'total_permium', 'tgt': 'total_premium_collected'}
        ],
        'hub_key_columns': [
            {'src_expr': 'reg_no', 'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product', 'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_MATERNITY_DTLS'
    },
    {
        'model': 'stg_hdfc_sec_fhpp',
        'alias': 't16',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gross_premium', 'tgt': 'gross_premium'}
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
        'model': 'stg_health_webservice_info',
        'alias': 't17',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'add_on_prem', 'tgt': 'add_on_premium'},
            {'src': 'gross_premium', 'tgt': 'gross_premium'},
            {'src': 'net_premium', 'tgt': 'net_premium'}
        ],
        'hub_key_columns': [
            {'src_expr': 'deal_id', 'tgt': 'HUB_AGREEMENT_BK__DEAL_ID'},
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'loan_accno', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__LOAN_ACCNO'},
            {'src_expr': 'ptransaction_id', 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__PTRANSACTION_ID'},
            {'src_expr': 'branch_code', 'tgt': 'HUB_ORG_UNIT_BK__BRANCH_CODE'},
            {'src_expr': 'dept_code', 'tgt': 'HUB_ORG_UNIT_BK__DEPT_CODE'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HEALTH_WEBSERVICE_INFO'
    },
    {
        'model': 'stg_hg_pol_dtls',
        'alias': 't18',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gross_premium', 'tgt': 'gross_premium'}
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
        'model': 'stg_pmsby_data_web_service',
        'alias': 't19',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pay_status', 'tgt': 'premium_payment_status'}
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
            {'src': 'full_yr_net_prem', 'tgt': 'full_year_net_premium'},
            {'src': 'full_yr_terr_prem', 'tgt': 'full_year_terrorism_premium'},
            {'src': 'gross_premium', 'tgt': 'gross_premium'},
            {'src': 'maxexp_netrate', 'tgt': 'maximum_exposure_net_rate'},
            {'src': 'maxexp_stdrate', 'tgt': 'maximum_exposure_standard_rate'},
            {'src': 'ncb_amt', 'tgt': 'no_claim_bonus_amount'},
            {'src': 'cust_amt', 'tgt': 'total_premium_collected'}
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
            {'src': 'envr_fund_amt', 'tgt': 'environment_relief_fund_amount'},
            {'src': 'gross_premium', 'tgt': 'gross_premium'},
            {'src': 'net_premium', 'tgt': 'net_premium'},
            {'src': 'receipt_dtls', 'tgt': 'receipt_details_text'},
            {'src': 'recpt_type', 'tgt': 'receipt_type'}
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
        'model': 'stg_starpkg_pol_dtls',
        'alias': 't22',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'total_prem', 'tgt': 'gross_premium'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('TXN:' || nullif(trim(TRANSACTION_ID),''), 'TXN:')", 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(PROD_CODE),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT_PROD_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_STARPKG_POL_DTLS'
    },
    {
        'model': 'stg_grp_hlt_dtls',
        'alias': 't23',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'final_prm_ex_stax', 'tgt': 'net_premium'}
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
    }
] -%}

{%- set output_columns = [
    'add_on_premium', 'base_premium', 'base_premium_before_adjustment', 'environment_relief_fund_amount', 'full_year_net_premium', 'full_year_terrorism_premium', 'gross_premium', 'group_discount_amount', 'instalment_count', 'instalment_indicator', 'long_term_discount_amount', 'maximum_exposure_net_rate', 'maximum_exposure_standard_rate', 'net_premium', 'no_claim_bonus_amount', 'premium_inclusive_of_commission_amount', 'premium_payment_status', 'receipt_details_text', 'receipt_type', 'terrorism_premium', 'total_premium_collected'
] -%}

{%- set coalesce_rules = {
    'add_on_premium': ['t1', 't13', 't17'],
    'base_premium': ['t11', 't1', 't13', 't15', 't0'],
    'base_premium_before_adjustment': ['t11'],
    'environment_relief_fund_amount': ['t11', 't21'],
    'full_year_net_premium': ['t13', 't20'],
    'full_year_terrorism_premium': ['t20'],
    'gross_premium': ['t11', 't1', 't3', 't4', 't5', 't6', 't7', 't9', 't10', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't0', 't20', 't21', 't22'],
    'group_discount_amount': ['t11', 't2'],
    'instalment_count': ['t11', 't8'],
    'instalment_indicator': ['t11'],
    'long_term_discount_amount': ['t13', 't0'],
    'maximum_exposure_net_rate': ['t20'],
    'maximum_exposure_standard_rate': ['t20'],
    'net_premium': ['t11', 't1', 't3', 't13', 't23', 't17', 't0', 't21'],
    'no_claim_bonus_amount': ['t20'],
    'premium_inclusive_of_commission_amount': ['t11'],
    'premium_payment_status': ['t19'],
    'receipt_details_text': ['t21'],
    'receipt_type': ['t21'],
    'terrorism_premium': ['t13', 't0'],
    'total_premium_collected': ['t12', 't15', 't0', 't20']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't17.HUB_AGREEMENT_BK__DEAL_ID'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t4.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t5.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t6.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t7.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t9.HUB_ASSESSMENT_BK__SCRUTINY_NO, t10.HUB_ASSESSMENT_BK__SCRUTINY_NO, t11.HUB_ASSESSMENT_BK__SCRUTINY_NO, t13.HUB_ASSESSMENT_BK__SCRUTINY_NO, t17.HUB_ASSESSMENT_BK__SCRUTINY_NO, t23.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 't9.HUB_CLAIM_BK__REFERENCE_ID'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 'coalesce(t1.HUB_COVERAGE_BK__HCP_SEQNO, t18.HUB_COVERAGE_BK__COVER_CODE)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t2.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t9.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t10.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t12.HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID, t13.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t14.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t16.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t17.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t18.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t19.HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t4.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t5.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t6.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t7.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t13.HUB_FINANCIAL_ACCOUNT_BK__LMS_NO, t14.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER, t16.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER, t17.HUB_FINANCIAL_ACCOUNT_BK__LOAN_ACCNO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t17.HUB_FINANCIAL_TRANSACTION_BK__PTRANSACTION_ID, t20.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID, t22.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 'coalesce(t2.HUB_LOCATION_BK__CHILD_LOC_CODE, t9.HUB_LOCATION_BK__LOCATION_CODE, t19.HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t4.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t5.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t6.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t7.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t10.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT, t13.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT, t20.HUB_ORG_UNIT_BK__DEPARTMENT_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t1.HUB_PARTY_BK__USER_ID, t2.HUB_PARTY_BK__USER_ID, t8.HUB_PARTY_BK__EMP_CODE, t9.HUB_PARTY_BK__CUSTOMER_ID, t14.HUB_PARTY_BK__USER_ID, t16.HUB_PARTY_BK__CLIENT_ID, t18.HUB_PARTY_BK__PART_ID)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__CONTRACT_ID, t2.HUB_POLICY_BK__CONTRACT_ID, t3.HUB_POLICY_BK__BASE_POLICY_REF, t4.HUB_POLICY_BK__POL_SERIAL_NO, t5.HUB_POLICY_BK__POL_SERIAL_NO, t6.HUB_POLICY_BK__POL_SERIAL_NO, t7.HUB_POLICY_BK__POL_SERIAL_NO, t8.HUB_POLICY_BK__POLICY_NO, t9.HUB_POLICY_BK__POLICY_REF, t10.HUB_POLICY_BK__POLICY_REF, t11.HUB_POLICY_BK__CONTRACT_ID, t12.HUB_POLICY_BK__PMASTERPOLICYNUMBER, t13.HUB_POLICY_BK__REFERENCE_ID, t14.HUB_POLICY_BK__MASTER_POLICY_NO, t15.HUB_POLICY_BK__REG_NO, t16.HUB_POLICY_BK__REFERENCE_ID, t17.HUB_POLICY_BK__POLICY_REF, t18.HUB_POLICY_BK__CONTRACT_ID, t19.HUB_POLICY_BK__POLICY_REF, t20.HUB_POLICY_BK__CONTRACT_ID, t21.HUB_POLICY_BK__CONTRACT_ID, t22.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t1.HUB_PRODUCT_BK__PRODUCT_CODE, t3.HUB_PRODUCT_BK__PRODUCT_CODE, t4.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t5.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t6.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t7.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t10.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t13.HUB_PRODUCT_BK__PRODUCT_CODE, t14.HUB_PRODUCT_BK__PRODUCT_CODE, t15.HUB_PRODUCT_BK__PRODUCT, t16.HUB_PRODUCT_BK__PRODUCT_CODE, t17.HUB_PRODUCT_BK__PRODUCT_CODE, t18.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t20.HUB_PRODUCT_BK__PRODUCT_PRODUCT_4DIGIT_CODE, t21.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t22.HUB_PRODUCT_BK__PRODUCT_PROD_CODE, t23.HUB_PRODUCT_BK__PRODUCT)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t16.HUB_PROPOSAL_BK__BA_LEAD_NO, t18.HUB_PROPOSAL_BK__QUOTE_REF_NO, t23.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t11.HUB_QUOTE_BK__QUOTATION_NO, t15.HUB_QUOTE_BK__QUOTE_SUB_NO, t18.HUB_QUOTE_BK__QUOTE_REF_NO, t23.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_REINSURANCE_TREATY_BK', 'expr': 't13.HUB_REINSURANCE_TREATY_BK__RE_INSU'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t0.HUB_RISK_OBJECT_BK__LOANACC_LOAN_ACC_NUMBER, t4.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t6.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t19.HUB_RISK_OBJECT_BK__CUSTID_CUST_ID)'},
    {'name': 'T4__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't4.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T4__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't4.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T4__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't4.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T5__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't5.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T5__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't5.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T5__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't5.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T6__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't6.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T6__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't6.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T6__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't6.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T7__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't7.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T7__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't7.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T7__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't7.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T9__HUB_PRODUCT_BK__PLAN_ID', 'expr': 't9.HUB_PRODUCT_BK__PLAN_ID'},
    {'name': 'T9__HUB_PRODUCT_BK__PRODUCT_CODE', 'expr': 't9.HUB_PRODUCT_BK__PRODUCT_CODE'},
    {'name': 'T10__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't10.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T10__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't10.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T10__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't10.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T10__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't10.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T10__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't10.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T12__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't12.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T12__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't12.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T12__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't12.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T12__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't12.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T12__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't12.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T12__HUB_PRODUCT_BK__PLANID', 'expr': 't12.HUB_PRODUCT_BK__PLANID'},
    {'name': 'T12__HUB_PRODUCT_BK__SCHEMECODE', 'expr': 't12.HUB_PRODUCT_BK__SCHEMECODE'},
    {'name': 'T13__HUB_PARTY_BK__BAGIC_E_CODE', 'expr': 't13.HUB_PARTY_BK__BAGIC_E_CODE'},
    {'name': 'T13__HUB_PARTY_BK__BAGIC_RM_E_CODE', 'expr': 't13.HUB_PARTY_BK__BAGIC_RM_E_CODE'},
    {'name': 'T13__HUB_PARTY_BK__IMD_CODE', 'expr': 't13.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T13__HUB_PARTY_BK__SUB_IMD_CODE', 'expr': 't13.HUB_PARTY_BK__SUB_IMD_CODE'},
    {'name': 'T14__HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER', 'expr': 't14.HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER'},
    {'name': 'T14__HUB_PROPOSAL_BK__REFERENCE_ID', 'expr': 't14.HUB_PROPOSAL_BK__REFERENCE_ID'},
    {'name': 'T17__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't17.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T17__HUB_ORG_UNIT_BK__DEPT_CODE', 'expr': 't17.HUB_ORG_UNIT_BK__DEPT_CODE'},
    {'name': 'T18__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't18.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T18__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't18.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
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
    {'name': 'T23__HUB_ORG_UNIT_BK__BRANCH', 'expr': 't23.HUB_ORG_UNIT_BK__BRANCH'},
    {'name': 'T23__HUB_ORG_UNIT_BK__DEPARTMENT', 'expr': 't23.HUB_ORG_UNIT_BK__DEPARTMENT'},
    {'name': 'T23__HUB_POLICY_BK__POLICY_NO', 'expr': 't23.HUB_POLICY_BK__POLICY_NO'},
    {'name': 'T23__HUB_POLICY_BK__PREV_POL_REF', 'expr': 't23.HUB_POLICY_BK__PREV_POL_REF'},
    {'name': 'T23__HUB_POLICY_BK__REG_NO', 'expr': 't23.HUB_POLICY_BK__REG_NO'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_policy_premium_summary'
) }}
