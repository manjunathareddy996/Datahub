/* RESHAPED (Option C) from central view 31 into the partner thin form.
   Procedure: the pilot's 9-step REUSABLE RESHAPE PROCEDURE
   (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_account_balance
     Central view 31 feeds 9 satellites; this reshape carries ONLY the
     SAT_ACCOUNT_BALANCE payload (stage_31 SAT_ACCOUNT_BALANCE_HASHDIFF:
     SANCTIONED_LOAN_AMOUNT, EMI_INSTALMENT_AMOUNT, OPENING_BALANCE, EMI_AMOUNT,
     ASSIGNMENT_AMOUNT).
   key_column per src: each source's HUB_POLICY_BK__* column (HUB_POLICY grain).
     - t9 (BJAZ_HM_PRO_ASSESSMENT): carries NO HUB_POLICY key. The central view joined
       it on HUB_ASSESSMENT_BK__ASSESS_ID. DOCUMENTED GRAIN DEVIATION: key_column=
       HUB_ASSESSMENT_BK__ASSESS_ID (its real join key). Kept only so family-1 hub_keys
       referencing t9.* resolve.
   same-alias drops  : none.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_dt_premium',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno',    'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'user_id',      'tgt': 'HUB_PARTY_BK__USER_ID'},
            {'src_expr': 'contract_id',  'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_PREMIUM'
    },
    {
        'model': 'stg_hcp_prod_8428_gpg_loader',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'mlac_emi_pc_sanctioned_loan', 'tgt': 'sanctioned_loan_amount'},
            {'src': 'mlac_emi_pc_emi_rs',          'tgt': 'emi_instalment_amount'}
        ],
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
        'model': 'stg_hcp_prod_8432_ecp_loader',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plc_sactioned_loan_amt', 'tgt': 'opening_balance'},
            {'src': 'plc_emi_inr',            'tgt': 'emi_amount'},
            {'src': 'plc_assignment_amount',  'tgt': 'assignment_amount'}
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
        'model': 'stg_bandhan_medi_clam',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
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
        'model': 'stg_ehh_pol_dtls',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'model': 'stg_health_webservice_info',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
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
        'model': 'stg_hg_pol_dtls',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'cover_code',          'tgt': 'HUB_COVERAGE_BK__COVER_CODE'},
            {'src_expr': 'business_source',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE'},
            {'src_expr': 'company_org_unit',    'tgt': 'HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
            {'src_expr': 'department_code',     'tgt': 'HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
            {'src_expr': 'part_id',             'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id',         'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'product_4digit_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE'},
            {'src_expr': 'quote_ref_no',        'tgt': 'HUB_PROPOSAL_BK__QUOTE_REF_NO'},
            {'src_expr': 'quote_ref_no',        'tgt': 'HUB_QUOTE_BK__QUOTE_REF_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HG_POL_DTLS'
    },
    {
        'model': 'stg_hm_pro_assessment',
        'alias': 't9',
        'key_column': 'HUB_ASSESSMENT_BK__ASSESS_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'assess_id', 'tgt': 'HUB_ASSESSMENT_BK__ASSESS_ID'},
            {'src_expr': 'claim_id',  'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_PRO_ASSESSMENT'
    }
] -%}

{%- set output_columns = [
    'sanctioned_loan_amount',
    'emi_instalment_amount',
    'opening_balance',
    'emi_amount',
    'assignment_amount'
] -%}

{%- set coalesce_rules = {
    'sanctioned_loan_amount': ['t1'],
    'emi_instalment_amount':  ['t1'],
    'opening_balance':        ['t4'],
    'emi_amount':             ['t4'],
    'assignment_amount':      ['t4']
} %}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't7.HUB_AGREEMENT_BK__DEAL_ID'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t3.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t4.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t5.HUB_ASSESSMENT_BK__SCRUTINY_NO, t6.HUB_ASSESSMENT_BK__SCRUTINY_NO, t7.HUB_ASSESSMENT_BK__SCRUTINY_NO, t9.HUB_ASSESSMENT_BK__ASSESS_ID)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t5.HUB_CLAIM_BK__REFERENCE_ID, t9.HUB_CLAIM_BK__CLAIM_ID)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 'coalesce(t0.HUB_COVERAGE_BK__HCP_SEQNO, t8.HUB_COVERAGE_BK__COVER_CODE)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t8.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t1.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t2.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t3.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t4.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t7.HUB_FINANCIAL_ACCOUNT_BK__LOAN_ACCNO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 't7.HUB_FINANCIAL_TRANSACTION_BK__PTRANSACTION_ID'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't5.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t3.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t4.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t6.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__USER_ID, t5.HUB_PARTY_BK__CUSTOMER_ID, t8.HUB_PARTY_BK__PART_ID)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__POL_SERIAL_NO, t4.HUB_POLICY_BK__POL_SERIAL_NO, t5.HUB_POLICY_BK__POLICY_REF, t6.HUB_POLICY_BK__POLICY_REF, t7.HUB_POLICY_BK__POLICY_REF, t8.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PRODUCT_CODE, t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t3.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t4.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t6.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t7.HUB_PRODUCT_BK__PRODUCT_CODE, t8.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 't8.HUB_PROPOSAL_BK__QUOTE_REF_NO'},
    {'name': 'HUB_QUOTE_BK', 'expr': 't8.HUB_QUOTE_BK__QUOTE_REF_NO'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t1.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t3.HUB_RISK_OBJECT_BK__MD_SEQ_NO)'},
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
    {'name': 'T7__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't7.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T7__HUB_ORG_UNIT_BK__DEPT_CODE', 'expr': 't7.HUB_ORG_UNIT_BK__DEPT_CODE'},
    {'name': 'T8__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't8.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T8__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't8.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_account_balance'
) }}
