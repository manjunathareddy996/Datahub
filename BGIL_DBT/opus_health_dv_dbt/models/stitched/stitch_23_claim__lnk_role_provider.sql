/* RESHAPED (Option C), ONE STITCH PER SATELLITE, from hcon4 central view 23.
   Batch task 7.1 -- applies the pilot procedure (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_CLAIM  (unique_key='parent_bk')
   target_sat        : sat_lnk_role_provider
   payload           : 8 output column(s), this satellite's stage hashdiff payload only.
   hub_keys          : the FULL final-SELECT hub-key set of the central view (29), verbatim,
                       so downstream hub/stage layers keep resolving every HUB_*_BK column.
   key_column rule   : each source's HUB_CLAIM_BK__* column (spine-hub grain key).
   GRAIN DEVIATIONS (source has no HUB_CLAIM key; real join key used, kept so hub_keys exprs resolve):
       t7 (stg_hm_hospital_master) key_column=HUB_AGREEMENT_BK__HOSID
       t8 (stg_hm_hospital_master_extn) key_column=HUB_AGREEMENT_BK__HOSID
       t9 (stg_hm_hosp_master_extn1) key_column=HUB_AGREEMENT_BK__HOSID
   SAME-ALIAS DROPS  : none.
   SOURCES OMITTED   : none.
   merge order       : R8 precedence (v2 > legacy > delta3) preserved from the central view COALESCE order.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hm_cashless_inward',
        'alias': 't0',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'hospital_id', 'tgt': 'HUB_PARTY_BK__HOSPITAL_ID'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_CASHLESS_INWARD'
    },
    {
        'model': 'stg_hm_coinsu_clm_dtls',
        'alias': 't1',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'ldr_pid', 'tgt': 'HUB_PARTY_BK__LDR_PID'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'prod_cd', 'tgt': 'HUB_PRODUCT_BK__PROD_CD'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_COINSU_CLM_DTLS'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't2',
        'key_column': 'HUB_CLAIM_BK__CLID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'hospital_type', 'tgt': 'provider_type'}
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
        'model': 'stg_hm_preauth_enhance',
        'alias': 't3',
        'key_column': 'HUB_CLAIM_BK__CLID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'enhance_ref_id', 'tgt': 'HUB_CASE_BK__ENHANCE_REF_ID'},
            {'src_expr': 'clid', 'tgt': 'HUB_CLAIM_BK__CLID'},
            {'src_expr': 'omni_inward_no', 'tgt': 'HUB_DOCUMENT_BK__OMNI_INWARD_NO'},
            {'src_expr': 'hosp_id', 'tgt': 'HUB_PARTY_BK__HOSP_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_PREAUTH_ENHANCE'
    },
    {
        'model': 'stg_hm_preauth_request',
        'alias': 't4',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'model': 'stg_remedinet_claim_details',
        'alias': 't5',
        'key_column': 'HUB_CLAIM_BK__CLAIM_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'remedinet_provider_code', 'tgt': 'provider_code'},
            {'src': 'payer_provider_code', 'tgt': 'payer_provider_code'}
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
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't6',
        'key_column': 'HUB_CLAIM_BK__BJAZ_CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'hospital_code', 'tgt': 'provider_code'}
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
        'model': 'stg_hm_hospital_master',
        'alias': 't7',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'hos_status', 'tgt': 'empanelment_status'},
            {'src': 'preferred_flag', 'tgt': 'preferred_provider_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'pin_code', 'tgt': 'HUB_LOCATION_BK__PIN_CODE'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSPITAL_MASTER'
    },
    {
        'model': 'stg_hm_hospital_master_extn',
        'alias': 't8',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'year_empanelment', 'tgt': 'empanelment_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'distribution_partner', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSPITAL_MASTER_EXTN'
    },
    {
        'model': 'stg_hm_hosp_master_extn1',
        'alias': 't9',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'suspendforext', 'tgt': 'suspension_indicator'},
            {'src': 'ntopratio', 'tgt': 'nurse_to_patient_ratio'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSP_MASTER_EXTN1'
    }
] -%}

{%- set output_columns = [
    'provider_type',
    'empanelment_status',
    'preferred_provider_indicator',
    'empanelment_date',
    'suspension_indicator',
    'nurse_to_patient_ratio',
    'provider_code',
    'payer_provider_code'
] -%}

{%- set coalesce_rules = {
    'provider_type': ['t2'],
    'empanelment_status': ['t7'],
    'preferred_provider_indicator': ['t7'],
    'empanelment_date': ['t8'],
    'suspension_indicator': ['t9'],
    'nurse_to_patient_ratio': ['t9'],
    'provider_code': ['t5', 't6'],
    'payer_provider_code': ['t5']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 'coalesce(t5.HUB_AGREEMENT_BK__REMEDINET_PROVIDER_CODE, t7.HUB_AGREEMENT_BK__HOSID, t8.HUB_AGREEMENT_BK__HOSID, t9.HUB_AGREEMENT_BK__HOSID)'},
    {'name': 'HUB_CASE_BK', 'expr': 't3.HUB_CASE_BK__ENHANCE_REF_ID'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t0.HUB_CLAIM_BK__CLAIM_ID, t1.HUB_CLAIM_BK__CLAIM_ID, t2.HUB_CLAIM_BK__CLID, t3.HUB_CLAIM_BK__CLID, t4.HUB_CLAIM_BK__CLAIM_ID, t5.HUB_CLAIM_BK__CLAIM_NO, t6.HUB_CLAIM_BK__BJAZ_CLAIM_ID)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t2.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t6.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t8.HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t3.HUB_DOCUMENT_BK__OMNI_INWARD_NO, t5.HUB_DOCUMENT_BK__OMNI_INWARD_NO)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 't2.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t2.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t6.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't7.HUB_LOCATION_BK__PIN_CODE'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t2.HUB_LOSS_EVENT_BK__CLAIM_NO, t6.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__HOSPITAL_ID, t1.HUB_PARTY_BK__LDR_PID, t2.HUB_PARTY_BK__HOSPITAL_ID, t3.HUB_PARTY_BK__HOSP_ID, t7.HUB_PARTY_BK__HOSID, t8.HUB_PARTY_BK__HOSID, t9.HUB_PARTY_BK__HOSID)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t2.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t6.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__POLICY_REF, t1.HUB_POLICY_BK__POLICY_REF, t2.HUB_POLICY_BK__POLICY, t5.HUB_POLICY_BK__POLICY_NO, t6.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 't1.HUB_PRODUCT_BK__PROD_CD'},
    {'name': 'T2__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't2.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T2__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't2.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T2__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't2.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T2__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't2.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T2__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't2.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T4__HUB_DOCUMENT_BK__FIR_FIR_NO', 'expr': 't4.HUB_DOCUMENT_BK__FIR_FIR_NO'},
    {'name': 'T4__HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO', 'expr': 't4.HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO'},
    {'name': 'T4__HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO', 'expr': 't4.HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO'},
    {'name': 'T4__HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD', 'expr': 't4.HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD'},
    {'name': 'T4__HUB_PARTY_BK__HOSPID_HOS_ID', 'expr': 't4.HUB_PARTY_BK__HOSPID_HOS_ID'},
    {'name': 'T5__HUB_PARTY_BK__PAYER_CODE', 'expr': 't5.HUB_PARTY_BK__PAYER_CODE'},
    {'name': 'T5__HUB_PARTY_BK__REMEDINET_PROVIDER_CODE', 'expr': 't5.HUB_PARTY_BK__REMEDINET_PROVIDER_CODE'},
    {'name': 'T6__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't6.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T6__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't6.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T6__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't6.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T6__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't6.HUB_PARTY_BK__HOSPITAL_CODE'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_lnk_role_provider'
) }}
