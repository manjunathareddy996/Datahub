/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Procedure: the 9-step REUSABLE RESHAPE PROCEDURE documented in the pilot
   stitch_01_policy__policy_header.sql (task 4.1). Applied here by task 6.1.

   spine hub / grain : HUB_PRODUCT  (unique_key='parent_bk'); satellite: SAT_CHANNEL_DEFINITION
   target_sat        : sat_channel_definition  (header "SAT_CHANNEL_DEFINITION" ==
                       stage_17 "SAT_CHANNEL_DEFINITION_HASHDIFF" == filename tail).
   key_column per src: each source's HUB_PRODUCT_BK__* column (the HUB_PRODUCT-grain key).
     - 10 of 11 sources carry a HUB_PRODUCT_BK__* spine column -> used directly as key_column.
     - t10 (BJAZ_BANDHAN_MEDI_CLAM): its HUB_PRODUCT_BK columns are auxiliary (T10__), NOT in
       the HUB_PRODUCT_BK spine coalesce; the central view joined it on HUB_ASSESSMENT_BK__SCRUTINY_NO.
       DOCUMENTED GRAIN DEVIATION: key_column=HUB_ASSESSMENT_BK__SCRUTINY_NO (its real join key).
   PAYLOAD same-alias collisions: none.
   merge order       : R8 precedence (v2 > legacy > delta3) preserved as the central
                       view's documented COALESCE order, transcribed verbatim per attr.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_prod_8428_gpg_loader',
        'alias': 't0',
        'key_column': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_partner_type', 'tgt': 'channel_type'},
            {'src': 'pd_sub_imd_code', 'tgt': 'sub_channel_code'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',          'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',               'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'mlac_emi_pc_loan_account_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO'},
            {'src_expr': 'pd_location_code',            'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',          'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',            'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',         'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',               'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',             'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
            {'src_expr': 'md_seq_no',                   'tgt': 'HUB_RISK_OBJECT_BK__MD_SEQ_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8428_GPG_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8432_ecp_loader',
        'alias': 't1',
        'key_column': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_partner_type', 'tgt': 'channel_type'},
            {'src': 'pd_sub_imd_code', 'tgt': 'sub_channel_code'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',      'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',           'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'pd_bank_ref_no1_lac_sac', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC'},
            {'src_expr': 'pd_location_code',        'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',      'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',        'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',     'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',           'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',         'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8432_ECP_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8433_fhc_loader',
        'alias': 't2',
        'key_column': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_partner_type', 'tgt': 'channel_type'},
            {'src': 'pd_sub_imd_code', 'tgt': 'sub_channel_code'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',      'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',           'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'pd_bank_ref_no1_lac_sac', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC'},
            {'src_expr': 'pd_location_code',        'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',      'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',        'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',     'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',           'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',         'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
            {'src_expr': 'md_seq_no',               'tgt': 'HUB_RISK_OBJECT_BK__MD_SEQ_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8433_FHC_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8439_clh_loader',
        'alias': 't3',
        'key_column': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_partner_type', 'tgt': 'channel_type'},
            {'src': 'pd_sub_imd_code', 'tgt': 'sub_channel_code'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number', 'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',      'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'plc_loan_acc_no',    'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO'},
            {'src_expr': 'pd_location_code',   'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',   'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id','tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',      'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',    'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8439_CLH_LOADER'
    },
    {
        'model': 'stg_bot_utilization_dtls',
        'alias': 't4',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'chatbot_name', 'tgt': 'channel_name'}
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
        'model': 'stg_ehh_pol_dtls',
        'alias': 't5',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'partner_type', 'tgt': 'channel_type'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',         'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'partner_id',          'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'location_code',       'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode',        'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc',          'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location',     'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location',       'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'company_org_unit',    'tgt': 'HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
            {'src_expr': 'policy_ref',          'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'product_4digit_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_EHH_POL_DTLS'
    },
    {
        'model': 'stg_gp_hospital_cash',
        'alias': 't6',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'source_name', 'tgt': 'channel_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'imd_code',            'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 's_account_number',    'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER'},
            {'src_expr': 'user_id',             'tgt': 'HUB_PARTY_BK__USER_ID'},
            {'src_expr': 'master_policy_no',    'tgt': 'HUB_POLICY_BK__MASTER_POLICY_NO'},
            {'src_expr': 'product_code',        'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 'kgc_proposal_number', 'tgt': 'HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER'},
            {'src_expr': 'reference_id',        'tgt': 'HUB_PROPOSAL_BK__REFERENCE_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GP_HOSPITAL_CASH'
    },
    {
        'model': 'stg_grp_hlt_cust_dtls',
        'alias': 't7',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'partner_type', 'tgt': 'channel_type'}
        ],
        'hub_key_columns': [
            {'src_expr': 'reg_no',       'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product',      'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_CUST_DTLS'
    },
    {
        'model': 'stg_grp_hlt_dtls',
        'alias': 't8',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'brokerage_rate',     'tgt': 'brokerage_rate'},
            {'src': 'channel',            'tgt': 'channel_type'},
            {'src': 'hpr_brokerage_rate', 'tgt': 'health_prime_rider_brokerage_rate'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',   'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'branch',        'tgt': 'HUB_ORG_UNIT_BK__BRANCH'},
            {'src_expr': 'department',    'tgt': 'HUB_ORG_UNIT_BK__DEPARTMENT'},
            {'src_expr': 'policy_no',     'tgt': 'HUB_POLICY_BK__POLICY_NO'},
            {'src_expr': 'prev_pol_ref',  'tgt': 'HUB_POLICY_BK__PREV_POL_REF'},
            {'src_expr': 'reg_no',        'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product',       'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_ref_no',  'tgt': 'HUB_PROPOSAL_BK__QUOTE_REF_NO'},
            {'src_expr': 'quote_sub_no',  'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_DTLS'
    },
    {
        'model': 'stg_hdfc_sec_fhpp',
        'alias': 't9',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'bdr_code',    'tgt': 'business_development_manager_reference'},
            {'src': 'source_name', 'tgt': 'channel_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'imd_code',         'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 's_account_number', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER'},
            {'src_expr': 'client_id',        'tgt': 'HUB_PARTY_BK__CLIENT_ID'},
            {'src_expr': 'reference_id',     'tgt': 'HUB_POLICY_BK__REFERENCE_ID'},
            {'src_expr': 'product_code',     'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 'ba_lead_no',       'tgt': 'HUB_PROPOSAL_BK__BA_LEAD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HDFC_SEC_FHPP'
    },
    {
        'model': 'stg_bandhan_medi_clam',
        'alias': 't10',
        'key_column': 'HUB_ASSESSMENT_BK__SCRUTINY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'issuance_source', 'tgt': 'channel_category'},
            {'src': 'lg_name',         'tgt': 'channel_name'},
            {'src': 'partner_type',    'tgt': 'channel_type'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',   'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'reference_id',  'tgt': 'HUB_CLAIM_BK__REFERENCE_ID'},
            {'src_expr': 'partner_id',    'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'customer_id',   'tgt': 'HUB_PARTY_BK__CUSTOMER_ID'},
            {'src_expr': 'policy_ref',    'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'plan_id',       'tgt': 'HUB_PRODUCT_BK__PLAN_ID'},
            {'src_expr': 'product_code',  'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_BANDHAN_MEDI_CLAM'
    }
] -%}

{%- set output_columns = [
    'channel_type',
    'sub_channel_code',
    'channel_category',
    'channel_name',
    'brokerage_rate',
    'health_prime_rider_brokerage_rate',
    'business_development_manager_reference'
] -%}

{#-- coalesce_rules: precedence order transcribed from the central view's final-SELECT
     payload COALESCEs. Single-alias rules emit a bare column reference (macro behaviour). --#}
{%- set coalesce_rules = {
    'channel_type':                          ['t0', 't1', 't2', 't3', 't10', 't5', 't7', 't8'],
    'sub_channel_code':                      ['t0', 't1', 't2', 't3'],
    'channel_category':                      ['t10'],
    'channel_name':                          ['t10', 't6', 't9', 't4'],
    'brokerage_rate':                        ['t8'],
    'health_prime_rider_brokerage_rate':     ['t8'],
    'business_development_manager_reference': ['t9']
} %}

{#-- hub_keys: transcribed VERBATIM from the central view's final SELECT.
     Family 1 = merged-spine BKs (coalesce over alias.tgt). Family 2 = auxiliary
     per-source BKs (single alias.tgt, name prefixed TN__). Order preserved. --#}
{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t3.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t5.HUB_ASSESSMENT_BK__SCRUTINY_NO, t8.HUB_ASSESSMENT_BK__SCRUTINY_NO, t10.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 't10.HUB_CLAIM_BK__REFERENCE_ID'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__CHATBOT_CHATBOT_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t9.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t10.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t0.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t1.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t2.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t3.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t6.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER, t9.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 'coalesce(t4.HUB_LOCATION_BK__PINCODE, t10.HUB_LOCATION_BK__LOCATION_CODE)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t0.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t3.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t4.HUB_ORG_UNIT_BK__BRANCH_CODE, t5.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t6.HUB_PARTY_BK__USER_ID, t9.HUB_PARTY_BK__CLIENT_ID, t10.HUB_PARTY_BK__CUSTOMER_ID)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__POL_SERIAL_NO, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__POL_SERIAL_NO, t5.HUB_POLICY_BK__POLICY_REF, t6.HUB_POLICY_BK__MASTER_POLICY_NO, t7.HUB_POLICY_BK__REG_NO, t9.HUB_POLICY_BK__REFERENCE_ID, t10.HUB_POLICY_BK__POLICY_REF)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t3.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t4.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t5.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t6.HUB_PRODUCT_BK__PRODUCT_CODE, t7.HUB_PRODUCT_BK__PRODUCT, t8.HUB_PRODUCT_BK__PRODUCT, t9.HUB_PRODUCT_BK__PRODUCT_CODE)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t8.HUB_PROPOSAL_BK__QUOTE_REF_NO, t9.HUB_PROPOSAL_BK__BA_LEAD_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t7.HUB_QUOTE_BK__QUOTE_SUB_NO, t8.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t0.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t2.HUB_RISK_OBJECT_BK__MD_SEQ_NO)'},
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
    {'name': 'T4__HUB_PARTY_BK__CUST_NAME', 'expr': 't4.HUB_PARTY_BK__CUST_NAME'},
    {'name': 'T4__HUB_PARTY_BK__USER_NAME', 'expr': 't4.HUB_PARTY_BK__USER_NAME'},
    {'name': 'T5__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't5.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T5__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't5.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T5__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't5.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T5__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't5.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T5__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't5.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T6__HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER', 'expr': 't6.HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER'},
    {'name': 'T6__HUB_PROPOSAL_BK__REFERENCE_ID', 'expr': 't6.HUB_PROPOSAL_BK__REFERENCE_ID'},
    {'name': 'T8__HUB_ORG_UNIT_BK__BRANCH', 'expr': 't8.HUB_ORG_UNIT_BK__BRANCH'},
    {'name': 'T8__HUB_ORG_UNIT_BK__DEPARTMENT', 'expr': 't8.HUB_ORG_UNIT_BK__DEPARTMENT'},
    {'name': 'T8__HUB_POLICY_BK__POLICY_NO', 'expr': 't8.HUB_POLICY_BK__POLICY_NO'},
    {'name': 'T8__HUB_POLICY_BK__PREV_POL_REF', 'expr': 't8.HUB_POLICY_BK__PREV_POL_REF'},
    {'name': 'T8__HUB_POLICY_BK__REG_NO', 'expr': 't8.HUB_POLICY_BK__REG_NO'},
    {'name': 'T10__HUB_PRODUCT_BK__PLAN_ID', 'expr': 't10.HUB_PRODUCT_BK__PLAN_ID'},
    {'name': 'T10__HUB_PRODUCT_BK__PRODUCT_CODE', 'expr': 't10.HUB_PRODUCT_BK__PRODUCT_CODE'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_channel_definition'
) }}
