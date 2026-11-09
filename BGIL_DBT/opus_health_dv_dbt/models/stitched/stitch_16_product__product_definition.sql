/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Procedure: the 9-step REUSABLE RESHAPE PROCEDURE documented in the pilot
   stitch_01_policy__policy_header.sql (task 4.1). Applied here by task 6.1.

   spine hub / grain : HUB_PRODUCT  (unique_key='parent_bk'); satellite: SAT_PRODUCT_DEFINITION
   target_sat        : sat_product_definition  (header "SAT_PRODUCT_DEFINITION" ==
                       stage_16 "SAT_PRODUCT_DEFINITION_HASHDIFF" == filename tail).
   key_column per src: each source's HUB_PRODUCT_BK__* column (the HUB_PRODUCT-grain key).
     - 9 of 12 sources carry a HUB_PRODUCT_BK__* column -> used directly as key_column.
     - t9 (BJAZ_HM_GMC_AHC): carries NO HUB_PRODUCT key; the central view joined it on
       HUB_POLICY_BK__POLICY_NO. DOCUMENTED GRAIN DEVIATION: key_column=HUB_POLICY_BK__POLICY_NO.
     - t10 (BJAZ_HM_INWARD_DTLS): carries NO HUB_PRODUCT key; the central view joined it on
       HUB_PARTY_BK__COURIER_ID. DOCUMENTED GRAIN DEVIATION: key_column=HUB_PARTY_BK__COURIER_ID.
     - t11 (BJAZ_TPA_CLAIM_DETAILS_WS): carries NO HUB_PRODUCT key; the central view joined it
       on HUB_CLAIM_BK__BJAZ_CLAIM_ID. DOCUMENTED GRAIN DEVIATION: key_column=HUB_CLAIM_BK__BJAZ_CLAIM_ID.
     These three are kept as sources so the family-1 hub_keys exprs referencing their aliases resolve.
   PAYLOAD same-alias collisions: none.
   merge order       : R8 precedence (v2 > legacy > delta3) preserved as the central
                       view's documented COALESCE order, transcribed verbatim per attr.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_prod_8433_fhc_loader',
        'alias': 't0',
        'key_column': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plan_name',   'tgt': 'product_name'},
            {'src': 'plan_option', 'tgt': 'product_display_name'}
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
        'alias': 't1',
        'key_column': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plan_name',   'tgt': 'product_name'},
            {'src': 'plan_option', 'tgt': 'product_display_name'}
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
        'model': 'stg_ctngy_gc_control',
        'alias': 't2',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'uin_no', 'tgt': 'uin'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(POLICY_REF),'')", 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(PRODUCT_CODE),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_CTNGY_GC_CONTROL'
    },
    {
        'model': 'stg_ctngy_scheme_mst',
        'alias': 't3',
        'key_column': 'HUB_PRODUCT_BK__SCHEME_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'health_product', 'tgt': 'line_of_business'},
            {'src': 'parent_flag',    'tgt': 'parent_product_indicator'},
            {'src': 'scheme_desc',    'tgt': 'product_name'},
            {'src': 'sertax_flag',    'tgt': 'service_tax_applicable_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',  'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'scheme_code', 'tgt': 'HUB_PRODUCT_BK__SCHEME_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_CTNGY_SCHEME_MST'
    },
    {
        'model': 'stg_ctngy_scheme_plans',
        'alias': 't4',
        'key_column': 'HUB_PRODUCT_BK__SCHEMEPLAN_SCHEME_CODE_PLAN_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'isactive',       'tgt': 'product_status'},
            {'src': 'new_planname_yn','tgt': 'new_plan_name_indicator'},
            {'src': 'pdf_plan_desc',  'tgt': 'product_display_name'},
            {'src': 'plan_desc',      'tgt': 'product_name'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('PARTNER:' || nullif(trim(PARTNER_ID),''), 'PARTNER:')", 'tgt': 'HUB_PARTY_BK__PARTNER_PARTNER_ID'},
            {'src_expr': "nullif('SCHEMEPLAN:' || nullif(trim(SCHEME_CODE),'') || '|' || nullif(trim(PLAN_ID),''), 'SCHEMEPLAN:|')", 'tgt': 'HUB_PRODUCT_BK__SCHEMEPLAN_SCHEME_CODE_PLAN_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_CTNGY_SCHEME_PLANS'
    },
    {
        'model': 'stg_grp_hlt_dtls',
        'alias': 't5',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'category',     'tgt': 'product_category'},
            {'src': 'product_name', 'tgt': 'product_name'}
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
        'model': 'stg_hcs_plansi_mapp',
        'alias': 't6',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plan_name', 'tgt': 'product_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCS_PLANSI_MAPP'
    },
    {
        'model': 'stg_hg_pol_dtls',
        'alias': 't7',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plan_desc', 'tgt': 'product_description'}
        ],
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
        'model': 'stg_hm_member_dtls',
        'alias': 't8',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plan_name', 'tgt': 'product_name'}
        ],
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
        'model': 'stg_hm_gmc_ahc',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'package_name', 'tgt': 'product_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_GMC_AHC'
    },
    {
        'model': 'stg_hm_inward_dtls',
        'alias': 't10',
        'key_column': 'HUB_PARTY_BK__COURIER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plan_name', 'tgt': 'product_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id',       'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'inward_id',      'tgt': 'HUB_DOCUMENT_BK__INWARD_ID'},
            {'src_expr': 'location_code',  'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode',   'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc',     'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location','tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location',  'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'claim_id',       'tgt': 'HUB_LOSS_EVENT_BK__CLAIM_ID'},
            {'src_expr': 'courier_id',     'tgt': 'HUB_PARTY_BK__COURIER_ID'},
            {'src_expr': 'policy_ref',     'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_INWARD_DTLS'
    },
    {
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't11',
        'key_column': 'HUB_CLAIM_BK__BJAZ_CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'product_name', 'tgt': 'product_name'}
        ],
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
    }
] -%}

{%- set output_columns = [
    'product_display_name',
    'product_name',
    'line_of_business',
    'service_tax_applicable_indicator',
    'parent_product_indicator',
    'product_category',
    'product_description',
    'product_status',
    'new_plan_name_indicator',
    'uin'
] -%}

{#-- coalesce_rules: precedence order transcribed from the central view's final-SELECT
     payload COALESCEs. Single-alias rules emit a bare column reference (macro behaviour). --#}
{%- set coalesce_rules = {
    'product_display_name':             ['t4', 't0', 't1'],
    'product_name':                     ['t4', 't0', 't1', 't3', 't5', 't6', 't9', 't10', 't8', 't11'],
    'line_of_business':                 ['t3'],
    'service_tax_applicable_indicator': ['t3'],
    'parent_product_indicator':         ['t3'],
    'product_category':                 ['t5'],
    'product_description':              ['t7'],
    'product_status':                   ['t4'],
    'new_plan_name_indicator':          ['t4'],
    'uin':                              ['t2']
} %}

{#-- hub_keys: transcribed VERBATIM from the central view's final SELECT.
     Family 1 = merged-spine BKs (coalesce over alias.tgt). Family 2 = auxiliary
     per-source BKs (single alias.tgt, name prefixed TN__). Order preserved. --#}
{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t5.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t10.HUB_CLAIM_BK__CLAIM_ID, t11.HUB_CLAIM_BK__BJAZ_CLAIM_ID)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 't7.HUB_COVERAGE_BK__COVER_CODE'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t8.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t11.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 't10.HUB_DOCUMENT_BK__INWARD_ID'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t0.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t1.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t8.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 't11.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t10.HUB_LOSS_EVENT_BK__CLAIM_ID, t11.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t0.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t4.HUB_PARTY_BK__PARTNER_PARTNER_ID, t7.HUB_PARTY_BK__PART_ID, t8.HUB_PARTY_BK__MEMBER_ID, t10.HUB_PARTY_BK__COURIER_ID)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 't11.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__POL_SERIAL_NO, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POLICY_REF, t7.HUB_POLICY_BK__CONTRACT_ID, t8.HUB_POLICY_BK__CONTRACT_ID, t9.HUB_POLICY_BK__POLICY_NO, t10.HUB_POLICY_BK__POLICY_REF, t11.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t3.HUB_PRODUCT_BK__SCHEME_CODE, t4.HUB_PRODUCT_BK__SCHEMEPLAN_SCHEME_CODE_PLAN_ID, t5.HUB_PRODUCT_BK__PRODUCT, t6.HUB_PRODUCT_BK__PRODUCT_CODE, t7.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t8.HUB_PRODUCT_BK__PRODUCT_CODE)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t5.HUB_PROPOSAL_BK__QUOTE_REF_NO, t7.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t5.HUB_QUOTE_BK__QUOTE_SUB_NO, t7.HUB_QUOTE_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 't0.HUB_RISK_OBJECT_BK__MD_SEQ_NO'},
    {'name': 'T0__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't0.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T1__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't1.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T5__HUB_ORG_UNIT_BK__BRANCH', 'expr': 't5.HUB_ORG_UNIT_BK__BRANCH'},
    {'name': 'T5__HUB_ORG_UNIT_BK__DEPARTMENT', 'expr': 't5.HUB_ORG_UNIT_BK__DEPARTMENT'},
    {'name': 'T5__HUB_POLICY_BK__POLICY_NO', 'expr': 't5.HUB_POLICY_BK__POLICY_NO'},
    {'name': 'T5__HUB_POLICY_BK__PREV_POL_REF', 'expr': 't5.HUB_POLICY_BK__PREV_POL_REF'},
    {'name': 'T5__HUB_POLICY_BK__REG_NO', 'expr': 't5.HUB_POLICY_BK__REG_NO'},
    {'name': 'T7__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't7.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T7__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't7.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T10__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't10.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T10__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't10.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T10__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't10.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T10__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't10.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T10__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't10.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T11__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't11.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T11__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't11.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T11__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't11.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T11__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't11.HUB_PARTY_BK__HOSPITAL_CODE'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_product_definition'
) }}
