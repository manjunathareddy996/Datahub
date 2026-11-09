/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Procedure: the 9-step REUSABLE RESHAPE PROCEDURE documented in the pilot
   stitch_01_policy__policy_header.sql (task 4.1). Applied here by task 6.1.

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk'); satellite: SAT_POLICY_CLASSIFICATION
   target_sat        : sat_policy_classification  (header "SAT_POLICY_CLASSIFICATION" ==
                       stage_11 "SAT_POLICY_CLASSIFICATION_HASHDIFF" == filename tail).
   key_column per src: each source's HUB_POLICY_BK__* column (the HUB_POLICY-grain key).
     - 14 of 15 sources carry a HUB_POLICY_BK__* column -> used directly as key_column.
     - t14 (BJAZ_HCP_TRANSCRIPT_URL): carries NO HUB_POLICY key; the central view joined
       it on HUB_ASSESSMENT_BK__SCRUTINY_NO. DOCUMENTED GRAIN DEVIATION: it cannot key at
       HUB_POLICY grain, so key_column=HUB_ASSESSMENT_BK__SCRUTINY_NO (its real join key).
       It is kept as a source so the family-1 hub_keys exprs that reference t14.* resolve;
       its one payload contribution (business_type -> classification_value) and its hub
       keys are only populated when t14 survives the parent_bk row-pick.
   PAYLOAD same-alias collisions (macro emits ONE col per alias per tgt; the central view
   coalesced several raw cols from the SAME alias into classification_value -- the
   secondary raw cols are a recorded payload-precedence limitation of the macro form):
     - classification_value: kept t8.buiseness_type; dropped-secondary t8.crcapplicable_yn,
       t8.enrollment_type, t8.transaction_type
     - classification_value: kept t13.business_type; dropped-secondary t13.industry_type
   merge order       : R8 precedence (v2 > legacy > delta3) preserved as the central
                       view's documented COALESCE order, transcribed verbatim per attr.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_dt_premium',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'buss_type', 'tgt': 'classification_value'}
        ],
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
            {'src': 'pd_business_type', 'tgt': 'classification_value'}
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
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_business_type', 'tgt': 'classification_value'}
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
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_business_type', 'tgt': 'classification_value'}
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
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_business_type', 'tgt': 'classification_value'}
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
        'model': 'stg_bgil_gmc_final_instl_data',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'grade_bucket', 'tgt': 'classification_value'}
        ],
        'hub_key_columns': [
            {'src_expr': 'emp_code',  'tgt': 'HUB_PARTY_BK__EMP_CODE'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BGIL_GMC_FINAL_INSTL_DATA'
    },
    {
        'model': 'stg_bandhan_medi_clam',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'business_type', 'tgt': 'classification_value'}
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
    },
    {
        'model': 'stg_ctngy_nr_bases_extn',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'param_ref',   'tgt': 'classification_type'},
            {'src': 'param_id',    'tgt': 'classification_type_code'},
            {'src': 'param_value', 'tgt': 'classification_value'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_CTNGY_NR_BASES_EXTN'
    },
    {
        'model': 'stg_enroll_scr_dtls',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'buiseness_type', 'tgt': 'classification_value'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(SCRUTINY_NO),'')", 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif(trim(QUOTATION_NO),'')", 'tgt': 'HUB_QUOTE_BK__QUOTATION_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_ENROLL_SCR_DTLS'
    },
    {
        'model': 'stg_gpg_pol_dtls',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'business_type', 'tgt': 'classification_value'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',      'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'imd_code',         'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'lms_no',           'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__LMS_NO'},
            {'src_expr': 'company_org_unit', 'tgt': 'HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
            {'src_expr': 'bagic_e_code',     'tgt': 'HUB_PARTY_BK__BAGIC_E_CODE'},
            {'src_expr': 'bagic_rm_e_code',  'tgt': 'HUB_PARTY_BK__BAGIC_RM_E_CODE'},
            {'src_expr': 'imd_code',         'tgt': 'HUB_PARTY_BK__IMD_CODE'},
            {'src_expr': 'sub_imd_code',     'tgt': 'HUB_PARTY_BK__SUB_IMD_CODE'},
            {'src_expr': 'reference_id',     'tgt': 'HUB_POLICY_BK__REFERENCE_ID'},
            {'src_expr': 'product_code',     'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 're_insu',          'tgt': 'HUB_REINSURANCE_TREATY_BK__RE_INSU'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GPG_POL_DTLS'
    },
    {
        'model': 'stg_health_webservice_info',
        'alias': 't10',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'business_type', 'tgt': 'classification_value'}
        ],
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
        'model': 'stg_policy_bases_extn',
        'alias': 't11',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'business_source', 'tgt': 'classification_value'}
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
        'model': 'stg_starpkg_pol_dtls',
        'alias': 't12',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'buss_type', 'tgt': 'classification_value'}
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
        'alias': 't13',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'business_type', 'tgt': 'classification_value'}
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
        'model': 'stg_hcp_transcript_url',
        'alias': 't14',
        'key_column': 'HUB_ASSESSMENT_BK__SCRUTINY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'business_type', 'tgt': 'classification_value'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',  'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'imd_code',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCP_TRANSCRIPT_URL'
    }
] -%}

{%- set output_columns = [
    'classification_value',
    'classification_type',
    'classification_type_code'
] -%}

{#-- coalesce_rules: precedence order transcribed from the central view's final-SELECT
     payload COALESCEs. Single-alias rules emit a bare column reference (macro behaviour).
     Same-alias collisions on classification_value (t8 four raw cols, t13 two raw cols)
     are represented once -- see header dropped-secondary note (macro limitation). --#}
{%- set coalesce_rules = {
    'classification_type':      ['t7'],
    'classification_type_code': ['t7'],
    'classification_value':     ['t7', 't8', 't0', 't1', 't2', 't3', 't4', 't5', 't6', 't9', 't13', 't14', 't10', 't11', 't12']
} %}

{#-- hub_keys: transcribed VERBATIM from the central view's final SELECT.
     Family 1 = merged-spine BKs (coalesce over alias.tgt). Family 2 = auxiliary
     per-source BKs (single alias.tgt, name prefixed TN__). Order preserved. --#}
{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't10.HUB_AGREEMENT_BK__DEAL_ID'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t3.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t4.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t6.HUB_ASSESSMENT_BK__SCRUTINY_NO, t8.HUB_ASSESSMENT_BK__SCRUTINY_NO, t9.HUB_ASSESSMENT_BK__SCRUTINY_NO, t10.HUB_ASSESSMENT_BK__SCRUTINY_NO, t13.HUB_ASSESSMENT_BK__SCRUTINY_NO, t14.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 't6.HUB_CLAIM_BK__REFERENCE_ID'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 't0.HUB_COVERAGE_BK__HCP_SEQNO'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t9.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t10.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t14.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t1.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t2.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t3.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t4.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t9.HUB_FINANCIAL_ACCOUNT_BK__LMS_NO, t10.HUB_FINANCIAL_ACCOUNT_BK__LOAN_ACCNO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t10.HUB_FINANCIAL_TRANSACTION_BK__PTRANSACTION_ID, t11.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID, t12.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't6.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t3.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t4.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t9.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT, t11.HUB_ORG_UNIT_BK__DEPARTMENT_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__USER_ID, t5.HUB_PARTY_BK__EMP_CODE, t6.HUB_PARTY_BK__CUSTOMER_ID)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__POL_SERIAL_NO, t4.HUB_POLICY_BK__POL_SERIAL_NO, t5.HUB_POLICY_BK__POLICY_NO, t6.HUB_POLICY_BK__POLICY_REF, t7.HUB_POLICY_BK__CONTRACT_ID, t8.HUB_POLICY_BK__CONTRACT_ID, t9.HUB_POLICY_BK__REFERENCE_ID, t10.HUB_POLICY_BK__POLICY_REF, t11.HUB_POLICY_BK__CONTRACT_ID, t12.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PRODUCT_CODE, t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t3.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t4.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t9.HUB_PRODUCT_BK__PRODUCT_CODE, t10.HUB_PRODUCT_BK__PRODUCT_CODE, t11.HUB_PRODUCT_BK__PRODUCT_PRODUCT_4DIGIT_CODE, t12.HUB_PRODUCT_BK__PRODUCT_PROD_CODE, t13.HUB_PRODUCT_BK__PRODUCT, t14.HUB_PRODUCT_BK__PRODUCT_CODE)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 't13.HUB_PROPOSAL_BK__QUOTE_REF_NO'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t8.HUB_QUOTE_BK__QUOTATION_NO, t13.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_REINSURANCE_TREATY_BK', 'expr': 't9.HUB_REINSURANCE_TREATY_BK__RE_INSU'},
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
    {'name': 'T6__HUB_PRODUCT_BK__PLAN_ID', 'expr': 't6.HUB_PRODUCT_BK__PLAN_ID'},
    {'name': 'T6__HUB_PRODUCT_BK__PRODUCT_CODE', 'expr': 't6.HUB_PRODUCT_BK__PRODUCT_CODE'},
    {'name': 'T9__HUB_PARTY_BK__BAGIC_E_CODE', 'expr': 't9.HUB_PARTY_BK__BAGIC_E_CODE'},
    {'name': 'T9__HUB_PARTY_BK__BAGIC_RM_E_CODE', 'expr': 't9.HUB_PARTY_BK__BAGIC_RM_E_CODE'},
    {'name': 'T9__HUB_PARTY_BK__IMD_CODE', 'expr': 't9.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T9__HUB_PARTY_BK__SUB_IMD_CODE', 'expr': 't9.HUB_PARTY_BK__SUB_IMD_CODE'},
    {'name': 'T10__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't10.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T10__HUB_ORG_UNIT_BK__DEPT_CODE', 'expr': 't10.HUB_ORG_UNIT_BK__DEPT_CODE'},
    {'name': 'T11__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't11.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T11__HUB_LOCATION_BK__PREV_INSURER_ADD', 'expr': 't11.HUB_LOCATION_BK__PREV_INSURER_ADD'},
    {'name': 'T13__HUB_ORG_UNIT_BK__BRANCH', 'expr': 't13.HUB_ORG_UNIT_BK__BRANCH'},
    {'name': 'T13__HUB_ORG_UNIT_BK__DEPARTMENT', 'expr': 't13.HUB_ORG_UNIT_BK__DEPARTMENT'},
    {'name': 'T13__HUB_POLICY_BK__POLICY_NO', 'expr': 't13.HUB_POLICY_BK__POLICY_NO'},
    {'name': 'T13__HUB_POLICY_BK__PREV_POL_REF', 'expr': 't13.HUB_POLICY_BK__PREV_POL_REF'},
    {'name': 'T13__HUB_POLICY_BK__REG_NO', 'expr': 't13.HUB_POLICY_BK__REG_NO'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_policy_classification'
) }}
