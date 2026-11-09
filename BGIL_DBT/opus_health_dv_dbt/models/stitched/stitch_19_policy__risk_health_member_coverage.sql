/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Procedure: the 9-step REUSABLE RESHAPE PROCEDURE documented in the pilot
   stitch_01_policy__policy_header.sql (task 4.1). Applied here by task 6.1.

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk'); satellite: SAT_RISK_HEALTH_MEMBER_COVERAGE
   target_sat        : sat_risk_health_member_coverage  (header "SAT_RISK_HEALTH_MEMBER_COVERAGE" ==
                       stage_19 "SAT_RISK_HEALTH_MEMBER_COVERAGE_HASHDIFF" == filename tail).
   key_column per src: each source's HUB_POLICY_BK__* column (the HUB_POLICY-grain key).
     - 10 of 11 sources carry a HUB_POLICY_BK__* column -> used directly as key_column.
     - t10 (BJAZ_SCR_HLTH_PORTABLE_DTLS): carries NO HUB_POLICY key; the central view joined it
       on HUB_ASSESSMENT_BK__SCRUTINY_NO (= t0.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER).
       DOCUMENTED GRAIN DEVIATION: key_column=HUB_ASSESSMENT_BK__SCRUTINY_NO (its real join key).
       Kept as a source so the family-1 hub_keys exprs referencing t10.* resolve.
   PAYLOAD same-alias collisions (macro emits ONE col per alias per tgt):
     - member_sum_insured: kept t4.bsi_amt; dropped-secondary t4.sum_insured
   merge order       : R8 precedence (v2 > legacy > delta3) preserved as the central
                       view's documented COALESCE order, transcribed verbatim per attr.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_prod_8439_clh_loader',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_spcl_condtn_member_level', 'tgt': 'loading_reason'}
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
        'model': 'stg_ec_mem_dtls_extn',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'medical_checkup', 'tgt': 'pre_policy_checkup_indicator'},
            {'src': 'sum_insured',     'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no',      'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id',    'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no',      'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_grp_hlt_maternity_dtls',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'corporate_buffer', 'tgt': 'corporate_buffer_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': 'reg_no',       'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product',      'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_MATERNITY_DTLS'
    },
    {
        'model': 'stg_hcf_member_dtls',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'loading_reason', 'tgt': 'loading_reason'},
            {'src': 'sum_insured',    'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',  'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no',   'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no',   'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__POLICY',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'bsi_amt', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'clid',            'tgt': 'HUB_CLAIM_BK__CLID'},
            {'src_expr': 'imd_code',        'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'bank_ac_no',      'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
            {'src_expr': 'utr_no',          'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__UTR_NO'},
            {'src_expr': 'location_code',   'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode',    'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc',      'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location',   'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'claim_no',        'tgt': 'HUB_LOSS_EVENT_BK__CLAIM_NO'},
            {'src_expr': 'hospital_id',     'tgt': 'HUB_PARTY_BK__HOSPITAL_ID'},
            {'src_expr': 'cheque_no',       'tgt': 'HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
            {'src_expr': 'policy',          'tgt': 'HUB_POLICY_BK__POLICY'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HCM_EXTRACT'
    },
    {
        'model': 'stg_hm_member_dtls',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'bonus_si', 'tgt': 'cumulative_bonus_amount'}
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
        'model': 'stg_hm_member_hlth_dtls',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gmc_metro',         'tgt': 'metro_classification'},
            {'src': 'hc_benefit_opted',  'tgt': 'benefit_option_code'},
            {'src': 'hc_hospital',       'tgt': 'network_hospital_reference'},
            {'src': 'hc_rate_status',    'tgt': 'member_rating_status'},
            {'src': 'hc_waiting_period', 'tgt': 'health_cover_benefit_waiting_period'},
            {'src': 'ihg_waiting_period','tgt': 'individual_health_product_waiting_period'},
            {'src': 'inception_date',    'tgt': 'member_cover_inception_date'},
            {'src': 'medical_checkup',   'tgt': 'pre_policy_checkup_indicator'},
            {'src': 'medical_report',    'tgt': 'medical_report_received_indicator'},
            {'src': 'remark_enrollment', 'tgt': 'enrolment_remarks'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(HAT_ID_CITY),''),'') || '|' || coalesce(nullif(trim(HAT_ID_STATE),''),''), '|'))))", 'tgt': 'HUB_LOCATION_BK__HAT_ID_CITY_HAT_ID_STATE'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('MEMBER:' || coalesce(nullif(trim(CONTRACT_ID),''),'') || '#' || coalesce(nullif(trim(MEMBER_ID),''),''), 'MEMBER:#')", 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_CONTRACT_ID_MEMBER_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_MEMBER_HLTH_DTLS'
    },
    {
        'model': 'stg_ihg_mem_dtls_extn',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'medical_checkup', 'tgt': 'pre_policy_checkup_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no',      'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id',    'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_IHG_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_sh_mem_dtls_extn',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'medical_checkup', 'tgt': 'pre_policy_checkup_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no',      'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id',    'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'balance_sum_insured', 'tgt': 'balance_sum_insured_amount'},
            {'src': 'corporate_buffer',    'tgt': 'corporate_buffer_amount'}
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
    },
    {
        'model': 'stg_scr_hlth_portable_dtls',
        'alias': 't10',
        'key_column': 'HUB_ASSESSMENT_BK__SCRUTINY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',       'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'request_no',        'tgt': 'HUB_CASE_BK__REQUEST_NO'},
            {'src_expr': 'member_identifier', 'tgt': 'HUB_PARTY_BK__MEMBER_IDENTIFIER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_SCR_HLTH_PORTABLE_DTLS'
    }
] -%}

{%- set output_columns = [
    'loading_reason',
    'member_sum_insured',
    'pre_policy_checkup_indicator',
    'corporate_buffer_amount',
    'cumulative_bonus_amount',
    'balance_sum_insured_amount',
    'medical_report_received_indicator',
    'member_cover_inception_date',
    'member_rating_status',
    'health_cover_benefit_waiting_period',
    'enrolment_remarks',
    'metro_classification',
    'benefit_option_code',
    'network_hospital_reference',
    'individual_health_product_waiting_period'
] -%}

{#-- coalesce_rules: precedence order transcribed from the central view's final-SELECT
     payload COALESCEs. Single-alias rules emit a bare column reference (macro behaviour).
     Same-alias collision on member_sum_insured (t4) represented once -- see header. --#}
{%- set coalesce_rules = {
    'loading_reason':                           ['t0', 't3'],
    'member_sum_insured':                       ['t1', 't3', 't4', 't10'],
    'pre_policy_checkup_indicator':             ['t6', 't1', 't7', 't8'],
    'corporate_buffer_amount':                  ['t2', 't9'],
    'cumulative_bonus_amount':                  ['t5'],
    'balance_sum_insured_amount':               ['t9'],
    'medical_report_received_indicator':        ['t6'],
    'member_cover_inception_date':              ['t6'],
    'member_rating_status':                     ['t6'],
    'health_cover_benefit_waiting_period':      ['t6'],
    'enrolment_remarks':                        ['t6'],
    'metro_classification':                     ['t6'],
    'benefit_option_code':                      ['t6'],
    'network_hospital_reference':               ['t6'],
    'individual_health_product_waiting_period': ['t6']
} %}

{#-- hub_keys: transcribed VERBATIM from the central view's final SELECT.
     Family 1 = merged-spine BKs (coalesce over alias.tgt). Family 2 = auxiliary
     per-source BKs (single alias.tgt, name prefixed TN__). Order preserved. --#}
{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t10.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CASE_BK', 'expr': 't10.HUB_CASE_BK__REQUEST_NO'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t4.HUB_CLAIM_BK__CLID, t9.HUB_CLAIM_BK__BJAZ_CLAIM_ID)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t1.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t5.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t8.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t9.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t1.HUB_DOCUMENT_BK__MEDICAL_REPORT, t7.HUB_DOCUMENT_BK__MEDICAL_REPORT, t8.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t0.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t4.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO, t5.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t4.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t9.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't6.HUB_LOCATION_BK__HAT_ID_CITY_HAT_ID_STATE'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t4.HUB_LOSS_EVENT_BK__CLAIM_NO, t9.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 't0.HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t1.HUB_PARTY_BK__MEMBER_NO, t3.HUB_PARTY_BK__MEMBER_NO, t4.HUB_PARTY_BK__HOSPITAL_ID, t5.HUB_PARTY_BK__MEMBER_ID, t7.HUB_PARTY_BK__MEMBER_NO, t8.HUB_PARTY_BK__MEMBER_NO, t10.HUB_PARTY_BK__MEMBER_IDENTIFIER)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t4.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t9.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__POL_SERIAL_NO, t1.HUB_POLICY_BK__CONTRACT_ID, t2.HUB_POLICY_BK__REG_NO, t3.HUB_POLICY_BK__CONTRACT_ID, t4.HUB_POLICY_BK__POLICY, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__CONTRACT_ID, t7.HUB_POLICY_BK__CONTRACT_ID, t8.HUB_POLICY_BK__CONTRACT_ID, t9.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PRODUCT, t5.HUB_PRODUCT_BK__PRODUCT_CODE)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 't2.HUB_QUOTE_BK__QUOTE_SUB_NO'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t1.HUB_RISK_OBJECT_BK__MEMBER_NO, t3.HUB_RISK_OBJECT_BK__MEMBER_NO, t6.HUB_RISK_OBJECT_BK__MEMBER_CONTRACT_ID_MEMBER_ID)'},
    {'name': 'T0__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't0.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T4__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't4.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T4__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't4.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T4__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't4.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T4__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't4.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T4__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't4.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T9__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't9.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T9__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't9.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T9__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't9.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T9__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't9.HUB_PARTY_BK__HOSPITAL_CODE'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_risk_health_member_coverage'
) }}
