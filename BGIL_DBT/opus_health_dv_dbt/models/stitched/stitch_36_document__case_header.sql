/* RESHAPED (Option C) from central view 36 into the partner thin form.
   Procedure: the pilot's 9-step REUSABLE RESHAPE PROCEDURE
   (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_DOCUMENT  (unique_key='parent_bk')
   target_sat        : sat_case_header
     Central view 36 feeds 5 satellites; this reshape carries ONLY the
     SAT_CASE_HEADER payload (stage_36 SAT_CASE_HEADER_HASHDIFF: CASE_STATUS,
     ASSIGNED_TO_REFERENCE, ALLOCATION_INDICATOR, ALLOCATION_DATE).
   key_column per src: each source's HUB_DOCUMENT_BK__* column (HUB_DOCUMENT grain).
     DOCUMENTED GRAIN DEVIATIONS (no HUB_DOCUMENT key; key_column is the real join key):
     - t7 (BJAZ_HCP_TRANSCRIPT_URL)   -> key_column=HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE
     - t8 (BJAZ_HM_HCM_EXTRACT)       -> key_column=HUB_CLAIM_BK__CLID
     - t9 (BJAZ_TPA_CLAIM_DETAILS_WS) -> key_column=HUB_CLAIM_BK__BJAZ_CLAIM_ID
   same-alias drops  : none.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_card_dtls',
        'alias': 't0',
        'key_column': 'HUB_DOCUMENT_BK__CARD_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'card_no',    'tgt': 'HUB_DOCUMENT_BK__CARD_NO'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_CARD_DTLS'
    },
    {
        'model': 'stg_hat_ocr_fina_perticulars',
        'alias': 't1',
        'key_column': 'HUB_DOCUMENT_BK__INWARD_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CASE_ID),'')",  'tgt': 'HUB_CLAIM_BK__CASE_ID'},
            {'src_expr': "nullif(trim(INWARD_NO),'')", 'tgt': 'HUB_DOCUMENT_BK__INWARD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HAT_OCR_FINA_PERTICULARS'
    },
    {
        'model': 'stg_hm_inward_autoallocation',
        'alias': 't2',
        'key_column': 'HUB_DOCUMENT_BK__OMNI_INWARD_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'bucket_status', 'tgt': 'case_status'},
            {'src': 'allocate_to',   'tgt': 'assigned_to_reference'},
            {'src': 'allocate_flag', 'tgt': 'allocation_indicator'},
            {'src': 'allocate_on',   'tgt': 'allocation_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'allocate_id',    'tgt': 'HUB_CASE_BK__ALLOCATE_ID'},
            {'src_expr': 'claim_id',       'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'omni_inward_no', 'tgt': 'HUB_DOCUMENT_BK__OMNI_INWARD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_INWARD_AUTOALLOCATION'
    },
    {
        'model': 'stg_hm_inward_dtls',
        'alias': 't3',
        'key_column': 'HUB_DOCUMENT_BK__INWARD_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'model': 'stg_hm_preauth_attach',
        'alias': 't4',
        'key_column': 'HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO_REPORT_ATTACH_PATH',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "coalesce(nullif('OMNI_INWARD:' || nullif(trim(OMNI_INWARD_NO),''), 'OMNI_INWARD:'), md5(normalise(upper(nullif(trim(REPORT_ATTACH_PATH),'')))))", 'tgt': 'HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO_REPORT_ATTACH_PATH'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_PREAUTH_ATTACH'
    },
    {
        'model': 'stg_remedinet_claim_details',
        'alias': 't5',
        'key_column': 'HUB_DOCUMENT_BK__OMNI_INWARD_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'remedinet_provider_code', 'tgt': 'HUB_AGREEMENT_BK__REMEDINET_PROVIDER_CODE'},
            {'src_expr': 'claim_no',                'tgt': 'HUB_CLAIM_BK__CLAIM_NO'},
            {'src_expr': 'omni_inward_no',          'tgt': 'HUB_DOCUMENT_BK__OMNI_INWARD_NO'},
            {'src_expr': 'payer_code',              'tgt': 'HUB_PARTY_BK__PAYER_CODE'},
            {'src_expr': 'remedinet_provider_code', 'tgt': 'HUB_PARTY_BK__REMEDINET_PROVIDER_CODE'},
            {'src_expr': 'policy_no',               'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_REMEDINET_CLAIM_DETAILS'
    },
    {
        'model': 'stg_ng_fax_inward_details',
        'alias': 't6',
        'key_column': 'HUB_DOCUMENT_BK__INWARD_INWARDNO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'allocate_to',   'tgt': 'assigned_to_reference'},
            {'src': 'allocate_flag', 'tgt': 'allocation_indicator'},
            {'src': 'allocate_on',   'tgt': 'allocation_date'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('INWARD:' || nullif(trim(INWARDNO),''), 'INWARD:')", 'tgt': 'HUB_CASE_BK__INWARD_INWARDNO'},
            {'src_expr': "nullif('INWARD:' || nullif(trim(INWARDNO),''), 'INWARD:')", 'tgt': 'HUB_DOCUMENT_BK__INWARD_INWARDNO'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_NG_FAX_INWARD_DETAILS'
    },
    {
        'model': 'stg_hcp_transcript_url',
        'alias': 't7',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',  'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'imd_code',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCP_TRANSCRIPT_URL'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't8',
        'key_column': 'HUB_CLAIM_BK__CLID',
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
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't9',
        'key_column': 'HUB_CLAIM_BK__BJAZ_CLAIM_ID',
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
    }
] -%}

{%- set output_columns = [
    'case_status',
    'assigned_to_reference',
    'allocation_indicator',
    'allocation_date'
] -%}

{%- set coalesce_rules = {
    'case_status':           ['t2'],
    'assigned_to_reference': ['t2', 't6'],
    'allocation_indicator':  ['t2', 't6'],
    'allocation_date':       ['t2', 't6']
} %}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't5.HUB_AGREEMENT_BK__REMEDINET_PROVIDER_CODE'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 't7.HUB_ASSESSMENT_BK__SCRUTINY_NO'},
    {'name': 'HUB_CASE_BK', 'expr': 'coalesce(t2.HUB_CASE_BK__ALLOCATE_ID, t6.HUB_CASE_BK__INWARD_INWARDNO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t1.HUB_CLAIM_BK__CASE_ID, t2.HUB_CLAIM_BK__CLAIM_ID, t3.HUB_CLAIM_BK__CLAIM_ID, t5.HUB_CLAIM_BK__CLAIM_NO, t8.HUB_CLAIM_BK__CLID, t9.HUB_CLAIM_BK__BJAZ_CLAIM_ID)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t8.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t9.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t0.HUB_DOCUMENT_BK__CARD_NO, t1.HUB_DOCUMENT_BK__INWARD_NO, t2.HUB_DOCUMENT_BK__OMNI_INWARD_NO, t3.HUB_DOCUMENT_BK__INWARD_ID, t4.HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO_REPORT_ATTACH_PATH, t5.HUB_DOCUMENT_BK__OMNI_INWARD_NO, t6.HUB_DOCUMENT_BK__INWARD_INWARDNO)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 't8.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t8.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t9.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t3.HUB_LOSS_EVENT_BK__CLAIM_ID, t8.HUB_LOSS_EVENT_BK__CLAIM_NO, t9.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t3.HUB_PARTY_BK__COURIER_ID, t8.HUB_PARTY_BK__HOSPITAL_ID)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t8.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t9.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__POLICY_REF, t3.HUB_POLICY_BK__POLICY_REF, t5.HUB_POLICY_BK__POLICY_NO, t8.HUB_POLICY_BK__POLICY, t9.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 't7.HUB_PRODUCT_BK__PRODUCT_CODE'},
    {'name': 'T3__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't3.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T3__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't3.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T3__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't3.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T3__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't3.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T3__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't3.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T5__HUB_PARTY_BK__PAYER_CODE', 'expr': 't5.HUB_PARTY_BK__PAYER_CODE'},
    {'name': 'T5__HUB_PARTY_BK__REMEDINET_PROVIDER_CODE', 'expr': 't5.HUB_PARTY_BK__REMEDINET_PROVIDER_CODE'},
    {'name': 'T8__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't8.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T8__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't8.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T8__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't8.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T8__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't8.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T8__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't8.HUB_LOCATION_BK__RISK_LOCATION'},
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
    target_sat='sat_case_header'
) }}
