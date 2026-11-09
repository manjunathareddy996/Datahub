/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Batch task 5.1. Procedure: the stitch_01 pilot's 9-step REUSABLE PROCEDURE.
   spine hub / grain : HUB_CLAIM  (unique_key='parent_bk')
   target_sat        : sat_claim_header
   GRAIN DEVIATIONS (source has no spine-hub key; keyed on its real join col):
     - t14 (stg_ec_mem_dtls_extn): no HUB_CLAIM key; key_column=HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID (real join key)
     - t15 (stg_hcf_member_dtls): no HUB_CLAIM key; key_column=HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID (real join key)
   SAME-ALIAS PAYLOAD DROPS (macro emits one col per alias per tgt; secondary dropped):
     - closed_date: kept t1.close_date, dropped-secondary t1.updated_on
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hat_ocr_fina_dtls_lst',
        'alias': 't0',
        'key_column': 'HUB_CLAIM_BK__CASE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'inward_no', 'tgt': 'claim_reference_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'case_id', 'tgt': 'HUB_CLAIM_BK__CASE_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HAT_OCR_FINA_DTLS_LST'
    },
    {
        'model': 'stg_hm_claim_close',
        'alias': 't1',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'clid_hpms', 'tgt': 'claim_reference_number'},
            {'src': 'close_status', 'tgt': 'claim_status'},
            {'src': 'updated_by', 'tgt': 'closed_by_user_reference'},
            {'src': 'close_date', 'tgt': 'closed_date'},
            {'src': 'approval_date', 'tgt': 'closure_approval_date'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_CLAIM_CLOSE'
    },
    {
        'model': 'stg_hm_claim_reopen',
        'alias': 't2',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'clid_hpms', 'tgt': 'claim_reference_number'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_CLAIM_REOPEN'
    },
    {
        'model': 'stg_hm_claim_tracker',
        'alias': 't3',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claim_status', 'tgt': 'claim_status'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_CLAIM_TRACKER'
    },
    {
        'model': 'stg_hm_coinsu_clm_dtls',
        'alias': 't4',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claim_ref', 'tgt': 'claim_reference_number'},
            {'src': 'status', 'tgt': 'claim_status'},
            {'src': 'rfa_status', 'tgt': 'claim_sub_status'},
            {'src': 'type_of_claim', 'tgt': 'claim_type'},
            {'src': 'amt_of_claim_lodged', 'tgt': 'gross_incurred_amount'},
            {'src': 'total_amount', 'tgt': 'net_incurred_amount'},
            {'src': 'claim_date', 'tgt': 'notification_date'},
            {'src': 'date_of_cl_lodged', 'tgt': 'registration_date'},
            {'src': 'reeported_amt', 'tgt': 'reported_claim_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'ldr_pid', 'tgt': 'HUB_PARTY_BK__LDR_PID'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'prod_cd', 'tgt': 'HUB_PRODUCT_BK__PROD_CD'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_COINSU_CLM_DTLS'
    },
    {
        'model': 'stg_hm_gpa_bill_dtls',
        'alias': 't5',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'clid_hpms', 'tgt': 'claim_reference_number'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_GPA_BILL_DTLS'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't6',
        'key_column': 'HUB_CLAIM_BK__CLID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'general_remarks', 'tgt': 'claim_remarks'},
            {'src': 'claim_status', 'tgt': 'claim_status'},
            {'src': 'claim_close_status', 'tgt': 'claim_sub_status'},
            {'src': 'claim_type', 'tgt': 'claim_type'},
            {'src': 'close_date', 'tgt': 'closed_date'},
            {'src': 'orphan_claimno', 'tgt': 'orphan_claim_number'},
            {'src': 'orphan_intimation_dt', 'tgt': 'orphan_intimation_date'},
            {'src': 'orphan_remark', 'tgt': 'orphan_remark'},
            {'src': 'registration_date', 'tgt': 'registration_date'}
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
        'model': 'stg_hm_hcs_tech_assess_cov',
        'alias': 't7',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'clid_hpms', 'tgt': 'claim_reference_number'},
            {'src': 'inward_id', 'tgt': 'inward_registration_reference'},
            {'src': 'date_of_loss', 'tgt': 'loss_date'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': "nullif('HEALTHCARD:' || nullif(trim(ID_CARD_NO),''), 'HEALTHCARD:')", 'tgt': 'HUB_RISK_OBJECT_BK__HEALTHCARD_ID_CARD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_HCS_TECH_ASSESS_COV'
    },
    {
        'model': 'stg_hm_orphan_reg',
        'alias': 't8',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'orphan_close_yn', 'tgt': 'claim_closed_indicator'},
            {'src': 'orphan_remark', 'tgt': 'claim_remarks'},
            {'src': 'claim_type', 'tgt': 'claim_type'},
            {'src': 'orphan_inti_date', 'tgt': 'notification_date'},
            {'src': 'orphan_date', 'tgt': 'registration_date'}
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
        'model': 'stg_hm_preauth_request',
        'alias': 't9',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claim_ref', 'tgt': 'claim_reference_number'},
            {'src': 'clid_hpms', 'tgt': 'external_claim_reference'},
            {'src': 'injury_date', 'tgt': 'loss_date'},
            {'src': 'policy_ref', 'tgt': 'policy_reference'}
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
        'model': 'stg_hm_pro_assessment',
        'alias': 't10',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'closer_letdate', 'tgt': 'closed_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'assess_id', 'tgt': 'HUB_ASSESSMENT_BK__ASSESS_ID'},
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_PRO_ASSESSMENT'
    },
    {
        'model': 'stg_remedinet_claim_details',
        'alias': 't11',
        'key_column': 'HUB_CLAIM_BK__CLAIM_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'payer_reference_no', 'tgt': 'claim_reference_number'},
            {'src': 'claim_status', 'tgt': 'claim_status'},
            {'src': 'action_status', 'tgt': 'claim_sub_status'},
            {'src': 'claim_type', 'tgt': 'claim_type'}
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
        'model': 'stg_risk_trans_dtls',
        'alias': 't12',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claim_ref', 'tgt': 'claim_reference_number'},
            {'src': 'clid_hpms', 'tgt': 'external_claim_reference'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(CONTRACT_ID),''),'') || '|' || coalesce(nullif(trim(CLAIM_ID),''),'') || '|' || coalesce(nullif(trim(RISK_ID),''),''), '||'))))", 'tgt': 'HUB_ASSESSMENT_BK__CONTRACT_ID_CLAIM_ID_RISK_ID'},
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_RISK_TRANS_DTLS'
    },
    {
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't13',
        'key_column': 'HUB_CLAIM_BK__BJAZ_CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claim_category', 'tgt': 'claim_category'},
            {'src': 'bjaz_claim_status', 'tgt': 'claim_status'},
            {'src': 'claim_type', 'tgt': 'claim_type'},
            {'src': 'intimation_date', 'tgt': 'notification_date'}
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
        'model': 'stg_ec_mem_dtls_extn',
        'alias': 't14',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claim_received', 'tgt': 'registration_date'}
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
        'model': 'stg_hcf_member_dtls',
        'alias': 't15',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claim_dtls', 'tgt': 'claim_remarks'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCF_MEMBER_DTLS'
    }
] -%}

{%- set output_columns = [
    'claim_category', 'claim_closed_indicator', 'claim_reference_number', 'claim_remarks', 'claim_status', 'claim_sub_status', 'claim_type', 'closed_by_user_reference', 'closed_date', 'closure_approval_date', 'external_claim_reference', 'gross_incurred_amount', 'inward_registration_reference', 'loss_date', 'net_incurred_amount', 'notification_date', 'orphan_claim_number', 'orphan_intimation_date', 'orphan_remark', 'policy_reference', 'registration_date', 'reported_claim_amount'
] -%}

{%- set coalesce_rules = {
    'claim_category': ['t13'],
    'claim_closed_indicator': ['t8'],
    'claim_reference_number': ['t1', 't2', 't5', 't7', 't9', 't0', 't4', 't11', 't12'],
    'claim_remarks': ['t15', 't6', 't8'],
    'claim_status': ['t1', 't3', 't4', 't6', 't11', 't13'],
    'claim_sub_status': ['t4', 't6', 't11'],
    'claim_type': ['t4', 't6', 't8', 't11', 't13'],
    'closed_by_user_reference': ['t1'],
    'closed_date': ['t1', 't6', 't10'],
    'closure_approval_date': ['t1'],
    'external_claim_reference': ['t9', 't12'],
    'gross_incurred_amount': ['t4'],
    'inward_registration_reference': ['t7'],
    'loss_date': ['t7', 't9'],
    'net_incurred_amount': ['t4'],
    'notification_date': ['t4', 't8', 't13'],
    'orphan_claim_number': ['t6'],
    'orphan_intimation_date': ['t6'],
    'orphan_remark': ['t6'],
    'policy_reference': ['t9'],
    'registration_date': ['t14', 't4', 't6', 't8'],
    'reported_claim_amount': ['t4']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't11.HUB_AGREEMENT_BK__REMEDINET_PROVIDER_CODE'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t10.HUB_ASSESSMENT_BK__ASSESS_ID, t12.HUB_ASSESSMENT_BK__CONTRACT_ID_CLAIM_ID_RISK_ID)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t0.HUB_CLAIM_BK__CASE_ID, t1.HUB_CLAIM_BK__CLAIM_ID, t2.HUB_CLAIM_BK__CLAIM_ID, t3.HUB_CLAIM_BK__CLAIM_ID, t4.HUB_CLAIM_BK__CLAIM_ID, t5.HUB_CLAIM_BK__CLAIM_ID, t6.HUB_CLAIM_BK__CLID, t7.HUB_CLAIM_BK__CLAIM_ID, t8.HUB_CLAIM_BK__CLAIM_ID, t9.HUB_CLAIM_BK__CLAIM_ID, t10.HUB_CLAIM_BK__CLAIM_ID, t11.HUB_CLAIM_BK__CLAIM_NO, t12.HUB_CLAIM_BK__CLAIM_ID, t13.HUB_CLAIM_BK__BJAZ_CLAIM_ID)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t6.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t13.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t14.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t15.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t11.HUB_DOCUMENT_BK__OMNI_INWARD_NO, t14.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 't6.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t6.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t13.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t6.HUB_LOSS_EVENT_BK__CLAIM_NO, t13.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t4.HUB_PARTY_BK__LDR_PID, t6.HUB_PARTY_BK__HOSPITAL_ID, t14.HUB_PARTY_BK__MEMBER_NO, t15.HUB_PARTY_BK__MEMBER_NO)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t6.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t13.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t4.HUB_POLICY_BK__POLICY_REF, t6.HUB_POLICY_BK__POLICY, t8.HUB_POLICY_BK__POLICY_NUMBER, t11.HUB_POLICY_BK__POLICY_NO, t12.HUB_POLICY_BK__CONTRACT_ID, t13.HUB_POLICY_BK__POLICY_NO, t14.HUB_POLICY_BK__CONTRACT_ID, t15.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 't4.HUB_PRODUCT_BK__PROD_CD'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t7.HUB_RISK_OBJECT_BK__HEALTHCARD_ID_CARD_NO, t14.HUB_RISK_OBJECT_BK__MEMBER_NO, t15.HUB_RISK_OBJECT_BK__MEMBER_NO)'},
    {'name': 'T6__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't6.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T6__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't6.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T6__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't6.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T6__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't6.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T6__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't6.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T8__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't8.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T8__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't8.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T8__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't8.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T8__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't8.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T8__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't8.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T9__HUB_DOCUMENT_BK__FIR_FIR_NO', 'expr': 't9.HUB_DOCUMENT_BK__FIR_FIR_NO'},
    {'name': 'T9__HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO', 'expr': 't9.HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO'},
    {'name': 'T9__HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO', 'expr': 't9.HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO'},
    {'name': 'T9__HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD', 'expr': 't9.HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD'},
    {'name': 'T9__HUB_PARTY_BK__HOSPID_HOS_ID', 'expr': 't9.HUB_PARTY_BK__HOSPID_HOS_ID'},
    {'name': 'T11__HUB_PARTY_BK__PAYER_CODE', 'expr': 't11.HUB_PARTY_BK__PAYER_CODE'},
    {'name': 'T11__HUB_PARTY_BK__REMEDINET_PROVIDER_CODE', 'expr': 't11.HUB_PARTY_BK__REMEDINET_PROVIDER_CODE'},
    {'name': 'T13__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't13.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T13__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't13.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T13__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't13.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T13__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't13.HUB_PARTY_BK__HOSPITAL_CODE'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_claim_header'
) }}
