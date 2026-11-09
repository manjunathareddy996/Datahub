/* RESHAPED (Option C), ONE STITCH PER SATELLITE, from hcon4 central view 26.
   Batch task 7.1 -- applies the pilot procedure (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_CLAIM  (unique_key='parent_bk')
   target_sat        : sat_claim_benefit_head
   payload           : 19 output column(s), this satellite's stage hashdiff payload only.
   hub_keys          : the FULL final-SELECT hub-key set of the central view (16), verbatim,
                       so downstream hub/stage layers keep resolving every HUB_*_BK column.
   key_column rule   : each source's HUB_CLAIM_BK__* column (spine-hub grain key).
   GRAIN DEVIATIONS  : none.
   SAME-ALIAS DROPS (macro emits one column per alias per attr; secondary raw col dropped):
       claimed_amount: kept t6.child_bill_amt; dropped critic_bill_amt, death_bill_amt, edu_bill_amt, emi_bill_amt, family_bill_amt, funeral_bill_amt, hosp_bill_amt, med_bill_amt, ptd_bill_amt, trans_bill_amt, ttd_bill_amt
       head_basis_description: kept t6.cause_death; dropped critical_illness, ptd_disability, ttd_disability
       approved_amount: kept t6.child_approved_amt; dropped critic_approved_amt, death_approved_amt, edu_approved_amt, emi_approved_amt, family_approved_amt, funeral_approved_amt, hosp_approved_amt, med_approved_amt, ptd_approved_amt, total_approved_amt, trans_approved_amt, ttd_approved_amt
       deduction_amount: kept t6.child_disallow_amt; dropped critic_disallow_amt, death_disallow_amt, edu_disallow_amt, emi_disallow_amt, family_disallow_amt, funeral_disallow_amt, hosp_disallow_amt, med_disallow_amt, ptd_disallow_amt, trans_disallow_amt, ttd_disallow_amt
       deduction_reason: kept t6.child_disallow_reason; dropped critic_disallow_reason, death_disallow_reason, edu_disallow_reason, emi_disallow_reason, family_disallow_reason, funeral_disallow_reason, hosp_disallow_reason, med_disallow_reason, ptd_disallow_reason, trans_disallow_reason, ttd_disallow_reason
       head_onset_date: kept t6.emi_jobloss_date; dropped med_disable_date, ttd_inj_date
       head_resolution_date: kept t6.emi_otherorg_date; dropped med_recover_date, ttd_fit_date
       head_assessed_duration_days: kept t6.emi_no_days; dropped ttd_dur_disablement
       head_basis_count: kept t6.edu_no_children; dropped no_emi_paid, no_of_child
       head_event_date: kept t6.family_travel_date; dropped funeral_date, transport_date
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
        'columns': [
            {'src': 'total', 'tgt': 'claimed_amount'}
        ],
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
        'columns': [
            {'src': 'claimed_amt', 'tgt': 'claimed_amount'},
            {'src': 'tot_approved_amt', 'tgt': 'approved_amount'}
        ],
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
        'columns': [
            {'src': 'claimed_amt', 'tgt': 'claimed_amount'},
            {'src': 'tot_approved_amt', 'tgt': 'approved_amount'}
        ],
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
            {'src': 'child_bill_amt', 'tgt': 'claimed_amount'},
            {'src': 'cause_death', 'tgt': 'head_basis_description'},
            {'src': 'child_approved_amt', 'tgt': 'approved_amount'},
            {'src': 'child_disallow_amt', 'tgt': 'deduction_amount'},
            {'src': 'child_disallow_reason', 'tgt': 'deduction_reason'},
            {'src': 'emi_jobloss_date', 'tgt': 'head_onset_date'},
            {'src': 'emi_otherorg_date', 'tgt': 'head_resolution_date'},
            {'src': 'ttd_leave_from', 'tgt': 'head_claimed_period_from_date'},
            {'src': 'ttd_leave_to', 'tgt': 'head_claimed_period_to_date'},
            {'src': 'emi_no_days', 'tgt': 'head_assessed_duration_days'},
            {'src': 'ttd_dur_leaves', 'tgt': 'head_claimed_duration_days'},
            {'src': 'edu_no_children', 'tgt': 'head_basis_count'},
            {'src': 'family_travel_date', 'tgt': 'head_event_date'},
            {'src': 'family_from_city', 'tgt': 'travel_from_city'},
            {'src': 'family_to_city', 'tgt': 'travel_to_city'}
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
        'columns': [
            {'src': 'claimed_amt', 'tgt': 'claimed_amount'}
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
        'alias': 't8',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'tot_claimed_amt', 'tgt': 'claimed_amount'},
            {'src': 'tot_approved_amt', 'tgt': 'approved_amount'},
            {'src': 'cover_section', 'tgt': 'benefit_head_code'},
            {'src': 'bsi', 'tgt': 'head_base_sum_insured'},
            {'src': 'cum_bonus', 'tgt': 'cumulative_bonus_amount_on_head'},
            {'src': 'sum_insured', 'tgt': 'sum_insured_for_head'}
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
        'columns': [
            {'src': 'tot_approved_amt', 'tgt': 'approved_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': 'assess_id', 'tgt': 'HUB_ASSESSMENT_BK__ASSESS_ID'},
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_PRO_ASSESSMENT'
    }
] -%}

{%- set output_columns = [
    'claimed_amount',
    'head_basis_description',
    'approved_amount',
    'deduction_amount',
    'deduction_reason',
    'head_onset_date',
    'head_resolution_date',
    'head_claimed_period_from_date',
    'head_claimed_period_to_date',
    'head_assessed_duration_days',
    'head_claimed_duration_days',
    'head_basis_count',
    'head_event_date',
    'travel_from_city',
    'travel_to_city',
    'benefit_head_code',
    'head_base_sum_insured',
    'cumulative_bonus_amount_on_head',
    'sum_insured_for_head'
] -%}

{%- set coalesce_rules = {
    'claimed_amount': ['t6', 't8', 't1', 't4', 't5', 't7'],
    'head_basis_description': ['t6'],
    'approved_amount': ['t6', 't8', 't4', 't5', 't9'],
    'deduction_amount': ['t6'],
    'deduction_reason': ['t6'],
    'head_onset_date': ['t6'],
    'head_resolution_date': ['t6'],
    'head_claimed_period_from_date': ['t6'],
    'head_claimed_period_to_date': ['t6'],
    'head_assessed_duration_days': ['t6'],
    'head_claimed_duration_days': ['t6'],
    'head_basis_count': ['t6'],
    'head_event_date': ['t6'],
    'travel_from_city': ['t6'],
    'travel_to_city': ['t6'],
    'benefit_head_code': ['t8'],
    'head_base_sum_insured': ['t8'],
    'cumulative_bonus_amount_on_head': ['t8'],
    'sum_insured_for_head': ['t8']
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
    target_sat='sat_claim_benefit_head'
) }}
