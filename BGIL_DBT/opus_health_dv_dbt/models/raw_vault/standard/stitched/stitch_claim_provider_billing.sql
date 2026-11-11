{{ config(materialized='view') }}
-- This part feeds SAT_CLAIM_PROVIDER_BILLING only. Original precedence comments are kept below (from stitch_v08_claim).
-- CENTRAL VIEW v08_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HAT_DISC_SUMMARY_LST (opus_health_v2)
--   BJAZ_HAT_NON_PAYABLE_LST (opus_health_v2)
--   BJAZ_HAT_OCR_FINA_PERTICULARS (opus_health_v2)
--   BJAZ_HAT_RETURN_SUMMARY_LST (opus_health_v2)
--   BJAZ_HM_GPA_BILL_DTLS (opus_health_v2)
--   BJAZ_HM_BILL_CHARGE (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL_OCR (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_BILL_LINE
--   SAT_AUG_CLAIM_PROVIDER_BILLING
--   SAT_CLAIM_PA_DETAIL
--   SAT_CLAIM_PROVIDER_BILLING
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hat_disc_summary_lst') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_ocr_fina_perticulars') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_gpa_bill_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_bill_charge') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_bill_detail') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_bill_detail_ocr') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_pro_assessment') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hat_disc_summary_lst',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(disc_case_id),''))) || '|' || coalesce(disc_bill_number, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_DISC_SUMMARY_LST',
      'columns': [
        {'src': "nullif(trim(disc_case_id),'')", 'tgt': 'claim_bk'},
        {'src': 'disc_bill_number', 'tgt': 'claim_provider_billing__bill_number_ck'},
        {'src': 'disc_bill_date', 'tgt': 'claim_provider_billing__bill_date'},
        {'src': 'disc_bill_number', 'tgt': 'claim_provider_billing__bill_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_ocr_fina_perticulars',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(case_id),''))) || '|' || coalesce(bill_number, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_OCR_FINA_PERTICULARS',
      'columns': [
        {'src': "nullif(trim(case_id),'')", 'tgt': 'claim_bk'},
        {'src': 'bill_number', 'tgt': 'claim_provider_billing__bill_number_ck'},
        {'src': 'bill_date', 'tgt': 'claim_provider_billing__bill_date'},
        {'src': 'bill_number', 'tgt': 'claim_provider_billing__bill_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(bill_id, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'bill_id', 'tgt': 'claim_provider_billing__bill_number_ck'},
        {'src': 'total_approved_amt', 'tgt': 'claim_provider_billing__approved_amount'},
        {'src': 'total_bill_amt', 'tgt': 'claim_provider_billing__billed_amount'},
        {'src': 'bill_id', 'tgt': 'claim_provider_billing__bill_number'},
        {'src': 'total_disallow_amt', 'tgt': 'claim_provider_billing__disallowed_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_bill_charge',
      'alias': 't3',
      'key_column': "claim_id || '|' || coalesce(bill_id, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_BILL_CHARGE',
      'columns': [
        {'src': 'claim_id', 'tgt': 'claim_bk'},
        {'src': 'bill_id', 'tgt': 'claim_provider_billing__bill_number_ck'},
        {'src': 'bill_id', 'tgt': 'claim_provider_billing__bill_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_bill_detail',
      'alias': 't4',
      'key_column': "claim_id || '|' || coalesce(bill_id, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_BILL_DETAIL',
      'columns': [
        {'src': 'claim_id', 'tgt': 'claim_bk'},
        {'src': 'bill_id', 'tgt': 'claim_provider_billing__bill_number_ck'},
        {'src': 'tot_approved_amt', 'tgt': 'claim_provider_billing__approved_amount'},
        {'src': 'tot_bill_amt', 'tgt': 'claim_provider_billing__billed_amount'},
        {'src': 'bill_date', 'tgt': 'claim_provider_billing__bill_date'},
        {'src': 'coalesce(bill_id, hos_bill_no)', 'tgt': 'claim_provider_billing__bill_number'},
        {'src': 'bill_status_type', 'tgt': 'claim_provider_billing__bill_status_type'},
        {'src': 'bill_type', 'tgt': 'claim_provider_billing__bill_type'},
        {'src': 'dis_app_reason', 'tgt': 'claim_provider_billing__disallowance_reason'},
        {'src': 'tot_disallow_amt', 'tgt': 'claim_provider_billing__disallowed_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_bill_detail_ocr',
      'alias': 't5',
      'key_column': "claim_id || '|' || coalesce(bill_id, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_BILL_DETAIL_OCR',
      'columns': [
        {'src': 'claim_id', 'tgt': 'claim_bk'},
        {'src': 'bill_id', 'tgt': 'claim_provider_billing__bill_number_ck'},
        {'src': 'tot_approved_amt', 'tgt': 'claim_provider_billing__approved_amount'},
        {'src': 'tot_app_amtmou', 'tgt': 'claim_provider_billing__authorised_amount'},
        {'src': 'tot_bill_amt', 'tgt': 'claim_provider_billing__billed_amount'},
        {'src': 'bill_date', 'tgt': 'claim_provider_billing__bill_date'},
        {'src': 'coalesce(bill_id, hos_bill_no)', 'tgt': 'claim_provider_billing__bill_number'},
        {'src': 'bill_status_type', 'tgt': 'claim_provider_billing__bill_status_type'},
        {'src': 'bill_type', 'tgt': 'claim_provider_billing__bill_type'},
        {'src': 'dis_app_reason', 'tgt': 'claim_provider_billing__disallowance_reason'},
        {'src': 'tot_disallow_amt', 'tgt': 'claim_provider_billing__disallowed_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't6',
      'key_column': "clid || '|' || coalesce(hospital_bill_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'clid', 'tgt': 'claim_bk'},
        {'src': 'hospital_bill_no', 'tgt': 'claim_provider_billing__bill_number_ck'},
        {'src': 'hospital_bill_no', 'tgt': 'claim_provider_billing__bill_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_pro_assessment',
      'alias': 't7',
      'key_column': "claim_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PRO_ASSESSMENT',
      'columns': [
        {'src': 'claim_id', 'tgt': 'claim_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'claim_provider_billing__bill_number_ck'},
        {'src': 'tot_approved_amt', 'tgt': 'claim_provider_billing__approved_amount'},
        {'src': 'tot_disallow_amt', 'tgt': 'claim_provider_billing__disallowed_amount'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_bk',
    'claim_provider_billing__bill_number_ck',
    'claim_provider_billing__bill_date',
    'claim_provider_billing__bill_number',
    'claim_provider_billing__approved_amount',
    'claim_provider_billing__billed_amount',
    'claim_provider_billing__disallowed_amount',
    'claim_provider_billing__bill_status_type',
    'claim_provider_billing__bill_type',
    'claim_provider_billing__disallowance_reason',
    'claim_provider_billing__authorised_amount'
] -%}
{%- set coalesce_rules = {
    'claim_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7'],
    'claim_provider_billing__bill_number_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7'],
    'claim_provider_billing__bill_date': ['t0', 't1', 't4', 't5'],
    'claim_provider_billing__bill_number': ['t0', 't1', 't2', 't3', 't4', 't5', 't6'],
    'claim_provider_billing__approved_amount': ['t2', 't4', 't5', 't7'],
    'claim_provider_billing__billed_amount': ['t2', 't4', 't5'],
    'claim_provider_billing__disallowed_amount': ['t2', 't4', 't5', 't7'],
    'claim_provider_billing__bill_status_type': ['t4', 't5'],
    'claim_provider_billing__bill_type': ['t4', 't5'],
    'claim_provider_billing__disallowance_reason': ['t4', 't5'],
    'claim_provider_billing__authorised_amount': ['t5']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_provider_billing_pk',
    target_sat='sat_claim_provider_billing'
) }}
