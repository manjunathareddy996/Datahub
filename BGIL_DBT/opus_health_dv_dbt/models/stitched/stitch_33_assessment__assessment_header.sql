/* RESHAPED (Option C) from central view 33 into the partner thin form.
   Procedure: the pilot's 9-step REUSABLE RESHAPE PROCEDURE
   (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_ASSESSMENT  (unique_key='parent_bk')
   target_sat        : sat_assessment_header
     Central view 33 feeds 5 satellites; this reshape carries ONLY the
     SAT_ASSESSMENT_HEADER payload (stage_33 SAT_ASSESSMENT_HEADER_HASHDIFF, 17 cols).
   key_column per src: each source's HUB_ASSESSMENT_BK__* column (HUB_ASSESSMENT grain).
     DOCUMENTED GRAIN DEVIATIONS (source carries no HUB_ASSESSMENT key; key_column is its
     real central-view join key; kept so family-1/2 hub_keys referencing the alias resolve):
     - t6 (BJAZ_HM_HCM_EXTRACT)      -> key_column=HUB_CLAIM_BK__CLID
     - t7 (BJAZ_HM_HCS_TECH_ASSESS_COV) -> key_column=HUB_CLAIM_BK__CLAIM_ID
     - t8 (BJAZ_HM_HOSP_MASTER_EXTN1) -> key_column=HUB_PARTY_BK__HOSID
     - t9 (BJAZ_TPA_CLAIM_DETAILS_WS) -> key_column=HUB_CLAIM_BK__BJAZ_CLAIM_ID
   same-alias drops  : assessment_status keeps t0.status_code; dropped-secondary
                       t0.status_desc (macro emits one col per alias per tgt).
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_pp_mem_dtls',
        'alias': 't0',
        'key_column': 'HUB_ASSESSMENT_BK__SCRUTINY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'appointment_code', 'tgt': 'assessment_reference_number'},
            {'src': 'priority_flag',    'tgt': 'priority'},
            {'src': 'type_of_checkup',  'tgt': 'assessment_type'},
            {'src': 'checkup_amt',      'tgt': 'cost_of_assessment'},
            {'src': 'status_code',      'tgt': 'assessment_status'},
            {'src': 'sub_status_code',  'tgt': 'assessment_sub_status_code'},
            {'src': 'sub_status_desc',  'tgt': 'assessment_sub_status_description'},
            {'src': 'remarks',          'tgt': 'outcome_summary'},
            {'src': 'app_date',         'tgt': 'scheduled_date'},
            {'src': 'app_time',         'tgt': 'scheduled_time'},
            {'src': 'reschedule_date',  'tgt': 'rescheduled_date'},
            {'src': 'reschedule_time',  'tgt': 'rescheduled_time'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',        'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'alloted_to',         'tgt': 'HUB_PARTY_BK__ALLOTED_TO'},
            {'src_expr': 'contract_id',        'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'hi_control_number',  'tgt': 'HUB_PROPOSAL_BK__HI_CONTROL_NUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PP_MEM_DTLS'
    },
    {
        'model': 'stg_hcp_prod_8439_clh_loader',
        'alias': 't1',
        'key_column': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plc_medical_test_alrdy_con', 'tgt': 'assessment_status'}
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
        'model': 'stg_enroll_scr_dtls',
        'alias': 't2',
        'key_column': 'HUB_ASSESSMENT_BK__SCRUTINY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'inserted_by', 'tgt': 'assessor_reference'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(SCRUTINY_NO),'')",  'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')",  'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif(trim(QUOTATION_NO),'')", 'tgt': 'HUB_QUOTE_BK__QUOTATION_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_ENROLL_SCR_DTLS'
    },
    {
        'model': 'stg_hm_pro_assessment',
        'alias': 't3',
        'key_column': 'HUB_ASSESSMENT_BK__ASSESS_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'assessment_sdate', 'tgt': 'conducted_date'},
            {'src': 'assessment_edate', 'tgt': 'completed_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'assess_id', 'tgt': 'HUB_ASSESSMENT_BK__ASSESS_ID'},
            {'src_expr': 'claim_id',  'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_PRO_ASSESSMENT'
    },
    {
        'model': 'stg_risk_trans_dtls',
        'alias': 't4',
        'key_column': 'HUB_ASSESSMENT_BK__CONTRACT_ID_CLAIM_ID_RISK_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'trigger_type', 'tgt': 'trigger_event'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(CONTRACT_ID),''),'') || '|' || coalesce(nullif(trim(CLAIM_ID),''),'') || '|' || coalesce(nullif(trim(RISK_ID),''),''), '||'))))", 'tgt': 'HUB_ASSESSMENT_BK__CONTRACT_ID_CLAIM_ID_RISK_ID'},
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_RISK_TRANS_DTLS'
    },
    {
        'model': 'stg_scr_hlth_portable_dtls',
        'alias': 't5',
        'key_column': 'HUB_ASSESSMENT_BK__SCRUTINY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'status', 'tgt': 'assessment_status'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',       'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'request_no',        'tgt': 'HUB_CASE_BK__REQUEST_NO'},
            {'src_expr': 'member_identifier', 'tgt': 'HUB_PARTY_BK__MEMBER_IDENTIFIER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_SCR_HLTH_PORTABLE_DTLS'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't6',
        'key_column': 'HUB_CLAIM_BK__CLID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'asssement_date', 'tgt': 'conducted_date'}
        ],
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
        'model': 'stg_hm_hcs_tech_assess_cov',
        'alias': 't7',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': "nullif('HEALTHCARD:' || nullif(trim(ID_CARD_NO),''), 'HEALTHCARD:')", 'tgt': 'HUB_RISK_OBJECT_BK__HEALTHCARD_ID_CARD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_HCS_TECH_ASSESS_COV'
    },
    {
        'model': 'stg_hm_hosp_master_extn1',
        'alias': 't8',
        'key_column': 'HUB_PARTY_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'hospvisitedby',     'tgt': 'assessor_reference'},
            {'src': 'hospvisiteddate',   'tgt': 'conducted_date'},
            {'src': 'hospvisited',       'tgt': 'inspection_conducted_indicator'},
            {'src': 'hospvisitedremark', 'tgt': 'outcome_summary'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSP_MASTER_EXTN1'
    },
    {
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't9',
        'key_column': 'HUB_CLAIM_BK__BJAZ_CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pre_auth_status', 'tgt': 'assessment_status'}
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
    'assessment_reference_number',
    'priority',
    'assessment_type',
    'cost_of_assessment',
    'assessment_status',
    'assessment_sub_status_code',
    'assessment_sub_status_description',
    'outcome_summary',
    'scheduled_date',
    'scheduled_time',
    'rescheduled_date',
    'rescheduled_time',
    'conducted_date',
    'inspection_conducted_indicator',
    'assessor_reference',
    'completed_date',
    'trigger_event'
] -%}

{%- set coalesce_rules = {
    'assessment_reference_number':       ['t0'],
    'priority':                          ['t0'],
    'assessment_type':                   ['t0'],
    'cost_of_assessment':                ['t0'],
    'assessment_status':                 ['t0', 't1', 't5', 't9'],
    'assessment_sub_status_code':        ['t0'],
    'assessment_sub_status_description': ['t0'],
    'outcome_summary':                   ['t0', 't8'],
    'scheduled_date':                    ['t0'],
    'scheduled_time':                    ['t0'],
    'rescheduled_date':                  ['t0'],
    'rescheduled_time':                  ['t0'],
    'conducted_date':                    ['t6', 't8', 't3'],
    'inspection_conducted_indicator':    ['t8'],
    'assessor_reference':                ['t2', 't8'],
    'completed_date':                    ['t3'],
    'trigger_event':                     ['t4']
} %}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't8.HUB_AGREEMENT_BK__HOSID'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__SCRUTINY_NO, t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__SCRUTINY_NO, t3.HUB_ASSESSMENT_BK__ASSESS_ID, t4.HUB_ASSESSMENT_BK__CONTRACT_ID_CLAIM_ID_RISK_ID, t5.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CASE_BK', 'expr': 't5.HUB_CASE_BK__REQUEST_NO'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t3.HUB_CLAIM_BK__CLAIM_ID, t4.HUB_CLAIM_BK__CLAIM_ID, t6.HUB_CLAIM_BK__CLID, t7.HUB_CLAIM_BK__CLAIM_ID, t9.HUB_CLAIM_BK__BJAZ_CLAIM_ID)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t9.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t1.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t6.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t6.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t9.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t6.HUB_LOSS_EVENT_BK__CLAIM_NO, t9.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 't1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__ALLOTED_TO, t5.HUB_PARTY_BK__MEMBER_IDENTIFIER, t6.HUB_PARTY_BK__HOSPITAL_ID, t8.HUB_PARTY_BK__HOSID)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t6.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t9.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__CONTRACT_ID, t4.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__POLICY, t9.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 't1.HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 't0.HUB_PROPOSAL_BK__HI_CONTROL_NUMBER'},
    {'name': 'HUB_QUOTE_BK', 'expr': 't2.HUB_QUOTE_BK__QUOTATION_NO'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 't7.HUB_RISK_OBJECT_BK__HEALTHCARD_ID_CARD_NO'},
    {'name': 'T1__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't1.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T6__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't6.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T6__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't6.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T6__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't6.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T6__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't6.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T6__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't6.HUB_LOCATION_BK__RISK_LOCATION'},
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
    target_sat='sat_assessment_header'
) }}
