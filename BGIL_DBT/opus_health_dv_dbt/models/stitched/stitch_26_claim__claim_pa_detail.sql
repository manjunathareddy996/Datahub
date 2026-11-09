/* RESHAPED (Option C), ONE STITCH PER SATELLITE, from hcon4 central view 26.
   Batch task 7.1 -- applies the pilot procedure (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_CLAIM  (unique_key='parent_bk')
   target_sat        : sat_claim_pa_detail
   payload           : 3 output column(s), this satellite's stage hashdiff payload only.
   hub_keys          : the FULL final-SELECT hub-key set of the central view (16), verbatim,
                       so downstream hub/stage layers keep resolving every HUB_*_BK column.
   key_column rule   : each source's HUB_CLAIM_BK__* column (spine-hub grain key).
   GRAIN DEVIATIONS  : none.
   SAME-ALIAS DROPS  : none.
   SOURCES OMITTED   : none.
   merge order       : R8 precedence (v2 > legacy > delta3) preserved from the central view COALESCE order.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hat_disc_summary_lst',
        'alias': 't0',
        'key_column': 'HUB_CLAIM_BK__DISC_CASE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(DISC_CASE_ID),'')", 'tgt': 'HUB_CLAIM_BK__DISC_CASE_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HAT_DISC_SUMMARY_LST'
    },
    {
        'model': 'stg_hat_ocr_fina_dtls_lst',
        'alias': 't1',
        'key_column': 'HUB_CLAIM_BK__CASE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'case_id', 'tgt': 'HUB_CLAIM_BK__CASE_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HAT_OCR_FINA_DTLS_LST'
    },
    {
        'model': 'stg_hat_ocr_fina_perticulars',
        'alias': 't2',
        'key_column': 'HUB_CLAIM_BK__CASE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CASE_ID),'')", 'tgt': 'HUB_CLAIM_BK__CASE_ID'},
            {'src_expr': "nullif(trim(INWARD_NO),'')", 'tgt': 'HUB_DOCUMENT_BK__INWARD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HAT_OCR_FINA_PERTICULARS'
    },
    {
        'model': 'stg_hm_bill_charge',
        'alias': 't3',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_BILL_CHARGE'
    },
    {
        'model': 'stg_hm_bill_detail',
        'alias': 't4',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_BILL_DETAIL'
    },
    {
        'model': 'stg_hm_bill_detail_ocr',
        'alias': 't5',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_BILL_DETAIL_OCR'
    },
    {
        'model': 'stg_hm_gpa_bill_dtls',
        'alias': 't6',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'ptd_percentage', 'tgt': 'disability_percentage'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_GPA_BILL_DTLS'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't7',
        'key_column': 'HUB_CLAIM_BK__CLID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'alias': 't8',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'cause_of_death', 'tgt': 'cause_of_death_description'},
            {'src': 'transmort_date', 'tgt': 'transportation_of_mortal_remains_date'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': "nullif('HEALTHCARD:' || nullif(trim(ID_CARD_NO),''), 'HEALTHCARD:')", 'tgt': 'HUB_RISK_OBJECT_BK__HEALTHCARD_ID_CARD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_HCS_TECH_ASSESS_COV'
    },
    {
        'model': 'stg_hm_pro_assessment',
        'alias': 't9',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'assess_id', 'tgt': 'HUB_ASSESSMENT_BK__ASSESS_ID'},
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_PRO_ASSESSMENT'
    }
] -%}

{%- set output_columns = [
    'disability_percentage',
    'cause_of_death_description',
    'transportation_of_mortal_remains_date'
] -%}

{%- set coalesce_rules = {
    'disability_percentage': ['t6'],
    'cause_of_death_description': ['t8'],
    'transportation_of_mortal_remains_date': ['t8']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 't9.HUB_ASSESSMENT_BK__ASSESS_ID'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t0.HUB_CLAIM_BK__DISC_CASE_ID, t1.HUB_CLAIM_BK__CASE_ID, t2.HUB_CLAIM_BK__CASE_ID, t3.HUB_CLAIM_BK__CLAIM_ID, t4.HUB_CLAIM_BK__CLAIM_ID, t5.HUB_CLAIM_BK__CLAIM_ID, t6.HUB_CLAIM_BK__CLAIM_ID, t7.HUB_CLAIM_BK__CLID, t8.HUB_CLAIM_BK__CLAIM_ID, t9.HUB_CLAIM_BK__CLAIM_ID)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 't7.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 't2.HUB_DOCUMENT_BK__INWARD_NO'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 't7.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 't7.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 't7.HUB_LOSS_EVENT_BK__CLAIM_NO'},
    {'name': 'HUB_PARTY_BK', 'expr': 't7.HUB_PARTY_BK__HOSPITAL_ID'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 't7.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
    {'name': 'HUB_POLICY_BK', 'expr': 't7.HUB_POLICY_BK__POLICY'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 't8.HUB_RISK_OBJECT_BK__HEALTHCARD_ID_CARD_NO'},
    {'name': 'T7__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't7.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T7__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't7.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T7__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't7.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T7__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't7.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T7__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't7.HUB_LOCATION_BK__RISK_LOCATION'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_claim_pa_detail'
) }}
