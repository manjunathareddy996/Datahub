/* RESHAPED (Option C) from central view 32 into the partner thin form.
   Procedure: the pilot's 9-step REUSABLE RESHAPE PROCEDURE
   (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_DISTRIBUTION_CHANNEL  (unique_key='parent_bk')
   target_sat        : sat_agreement_commercial_terms
     Central view 32 feeds 13 satellites; this reshape carries ONLY the
     SAT_AGREEMENT_COMMERCIAL_TERMS payload (stage_32 hashdiff: CREDIT_PERIOD,
     PAYMENT_TERMS, SURCHARGE_PERCENTAGE, SERVICE_CHARGE_PERCENTAGE, PACKAGE_CLASS,
     PACKAGE_TYPE, PACKAGE_ACCEPTANCE_DATE, PACKAGE_EXPIRY_DATE,
     PREFERRED_PROVIDER_TERMS_EFFECTIVE_DATE, PREFERRED_PROVIDER_TERMS_EXPIRY_DATE,
     PREFERRED_PROVIDER_REMARKS -- all carried by t5).
   key_column per src: each source's HUB_DISTRIBUTION_CHANNEL_BK__* column (spine grain).
     - t9 (BJAZ_NEFT_PARTNER_DTLS): carries NO HUB_DISTRIBUTION_CHANNEL key. The central
       view joined it on HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE. DOCUMENTED
       GRAIN DEVIATION: key_column=HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE (its
       real join key). Kept only so family-1/2 hub_keys referencing t9.* resolve.
   same-alias drops  : none.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_prod_8428_gpg_loader',
        'alias': 't0',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',           'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',                'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'mlac_emi_pc_loan_account_no',  'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO'},
            {'src_expr': 'pd_location_code',             'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',           'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',             'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',          'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',                'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',              'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
            {'src_expr': 'md_seq_no',                    'tgt': 'HUB_RISK_OBJECT_BK__MD_SEQ_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8428_GPG_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8439_clh_loader',
        'alias': 't1',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'model': 'stg_bandhan_medi_clam',
        'alias': 't2',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
    },
    {
        'model': 'stg_health_webservice_info',
        'alias': 't3',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'deal_id',         'tgt': 'HUB_AGREEMENT_BK__DEAL_ID'},
            {'src_expr': 'scrutiny_no',     'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'partner_id',      'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'loan_accno',      'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__LOAN_ACCNO'},
            {'src_expr': 'ptransaction_id', 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__PTRANSACTION_ID'},
            {'src_expr': 'branch_code',     'tgt': 'HUB_ORG_UNIT_BK__BRANCH_CODE'},
            {'src_expr': 'dept_code',       'tgt': 'HUB_ORG_UNIT_BK__DEPT_CODE'},
            {'src_expr': 'policy_ref',      'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'product_code',    'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HEALTH_WEBSERVICE_INFO'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't4',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'clid',          'tgt': 'HUB_CLAIM_BK__CLID'},
            {'src_expr': 'imd_code',      'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'bank_ac_no',    'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
            {'src_expr': 'utr_no',        'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__UTR_NO'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode',  'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc',    'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location','tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'claim_no',      'tgt': 'HUB_LOSS_EVENT_BK__CLAIM_NO'},
            {'src_expr': 'hospital_id',   'tgt': 'HUB_PARTY_BK__HOSPITAL_ID'},
            {'src_expr': 'cheque_no',     'tgt': 'HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
            {'src_expr': 'policy',        'tgt': 'HUB_POLICY_BK__POLICY'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HCM_EXTRACT'
    },
    {
        'model': 'stg_hm_hospital_master_extn',
        'alias': 't5',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'credit_period',    'tgt': 'credit_period'},
            {'src': 'interest_clause',  'tgt': 'payment_terms'},
            {'src': 'surcharge_perc',   'tgt': 'surcharge_percentage'},
            {'src': 'serv_charge_perc', 'tgt': 'service_charge_percentage'},
            {'src': 'package_class',    'tgt': 'package_class'},
            {'src': 'package_type',     'tgt': 'package_type'},
            {'src': 'pack_accept_date', 'tgt': 'package_acceptance_date'},
            {'src': 'pack_expiry_date', 'tgt': 'package_expiry_date'},
            {'src': 'pp_effective_date','tgt': 'preferred_provider_terms_effective_date'},
            {'src': 'pp_expiray_date',  'tgt': 'preferred_provider_terms_expiry_date'},
            {'src': 'pp_remarks',       'tgt': 'preferred_provider_remarks'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid',                'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'distribution_partner', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER'},
            {'src_expr': 'hosid',                'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSPITAL_MASTER_EXTN'
    },
    {
        'model': 'stg_hm_member_dtls',
        'alias': 't6',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'partner_id',   'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'bank_ac_no',   'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
            {'src_expr': 'member_id',    'tgt': 'HUB_PARTY_BK__MEMBER_ID'},
            {'src_expr': 'contract_id',  'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_pmsby_data_web_service',
        'alias': 't7',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't8',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'bjaz_claim_id',      'tgt': 'HUB_CLAIM_BK__BJAZ_CLAIM_ID'},
            {'src_expr': 'partner_id',         'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'tpa_trans_key',      'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY'},
            {'src_expr': 'tpa_claim_no',       'tgt': 'HUB_LOSS_EVENT_BK__TPA_CLAIM_NO'},
            {'src_expr': 'controlling_office', 'tgt': 'HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
            {'src_expr': 'operating_office',   'tgt': 'HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
            {'src_expr': 'customer_id',        'tgt': 'HUB_PARTY_BK__CUSTOMER_ID'},
            {'src_expr': 'hospital_code',      'tgt': 'HUB_PARTY_BK__HOSPITAL_CODE'},
            {'src_expr': 'cheque_no',          'tgt': 'HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
            {'src_expr': 'policy_no',          'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_TPA_CLAIM_DETAILS_WS'
    },
    {
        'model': 'stg_neft_partner_dtls',
        'alias': 't9',
        'key_column': 'HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(trim(MANDATE_ADDRESS),'') || '|' || coalesce(trim(AREA),'') || '|' || coalesce(trim(CITY),'') || '|' || coalesce(trim(STATE),'') || '|' || coalesce(trim(to_char(PINCODE)),''), '||||'))))", 'tgt': 'HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE'},
            {'src_expr': "nullif('PARTID:' || nullif(trim(PART_ID),''), 'PARTID:')", 'tgt': 'HUB_PARTY_BK__PARTID_PART_ID'},
            {'src_expr': "nullif(trim(INTERMEDIARY_ID),'')", 'tgt': 'HUB_PARTY_BK__INTERMEDIARY_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_NEFT_PARTNER_DTLS'
    }
] -%}

{%- set output_columns = [
    'credit_period',
    'payment_terms',
    'surcharge_percentage',
    'service_charge_percentage',
    'package_class',
    'package_type',
    'package_acceptance_date',
    'package_expiry_date',
    'preferred_provider_terms_effective_date',
    'preferred_provider_terms_expiry_date',
    'preferred_provider_remarks'
] -%}

{%- set coalesce_rules = {
    'credit_period':                            ['t5'],
    'payment_terms':                            ['t5'],
    'surcharge_percentage':                     ['t5'],
    'service_charge_percentage':                ['t5'],
    'package_class':                            ['t5'],
    'package_type':                             ['t5'],
    'package_acceptance_date':                  ['t5'],
    'package_expiry_date':                      ['t5'],
    'preferred_provider_terms_effective_date':  ['t5'],
    'preferred_provider_terms_expiry_date':     ['t5'],
    'preferred_provider_remarks':               ['t5']
} %}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 'coalesce(t3.HUB_AGREEMENT_BK__DEAL_ID, t5.HUB_AGREEMENT_BK__HOSID)'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__SCRUTINY_NO, t3.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t2.HUB_CLAIM_BK__REFERENCE_ID, t4.HUB_CLAIM_BK__CLID, t8.HUB_CLAIM_BK__BJAZ_CLAIM_ID)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t5.HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER, t6.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO, t8.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t0.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t1.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t3.HUB_FINANCIAL_ACCOUNT_BK__LOAN_ACCNO, t4.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO, t6.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t3.HUB_FINANCIAL_TRANSACTION_BK__PTRANSACTION_ID, t4.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t8.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 'coalesce(t2.HUB_LOCATION_BK__LOCATION_CODE, t7.HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE, t9.HUB_LOCATION_BK__MANDATE_ADDRESS_AREA_CITY_STATE)'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t4.HUB_LOSS_EVENT_BK__CLAIM_NO, t8.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t0.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t2.HUB_PARTY_BK__CUSTOMER_ID, t4.HUB_PARTY_BK__HOSPITAL_ID, t5.HUB_PARTY_BK__HOSID, t6.HUB_PARTY_BK__MEMBER_ID)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t4.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t8.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__POL_SERIAL_NO, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POLICY_REF, t3.HUB_POLICY_BK__POLICY_REF, t4.HUB_POLICY_BK__POLICY, t6.HUB_POLICY_BK__CONTRACT_ID, t7.HUB_POLICY_BK__POLICY_REF, t8.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t3.HUB_PRODUCT_BK__PRODUCT_CODE, t6.HUB_PRODUCT_BK__PRODUCT_CODE)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t0.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t7.HUB_RISK_OBJECT_BK__CUSTID_CUST_ID)'},
    {'name': 'T0__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't0.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T1__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't1.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T2__HUB_PRODUCT_BK__PLAN_ID', 'expr': 't2.HUB_PRODUCT_BK__PLAN_ID'},
    {'name': 'T2__HUB_PRODUCT_BK__PRODUCT_CODE', 'expr': 't2.HUB_PRODUCT_BK__PRODUCT_CODE'},
    {'name': 'T3__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't3.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T3__HUB_ORG_UNIT_BK__DEPT_CODE', 'expr': 't3.HUB_ORG_UNIT_BK__DEPT_CODE'},
    {'name': 'T4__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't4.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T4__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't4.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T4__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't4.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T4__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't4.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T4__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't4.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T7__HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME', 'expr': 't7.HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME'},
    {'name': 'T7__HUB_PARTY_BK__CUST_ID', 'expr': 't7.HUB_PARTY_BK__CUST_ID'},
    {'name': 'T8__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't8.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T8__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't8.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T8__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't8.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T8__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't8.HUB_PARTY_BK__HOSPITAL_CODE'},
    {'name': 'T9__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't9.HUB_PARTY_BK__PARTID_PART_ID'},
    {'name': 'T9__HUB_PARTY_BK__INTERMEDIARY_ID', 'expr': 't9.HUB_PARTY_BK__INTERMEDIARY_ID'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_agreement_commercial_terms'
) }}
