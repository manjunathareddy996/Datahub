{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_PROVIDER_BILLING only. Original precedence comments are kept below (from stitch_v08_claim).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_gpa_bill_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_bill_detail') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_bill_detail_ocr') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': 'updated_by', 'tgt': 'aug_claim_provider_billing__bill_adjudicated_by_user'},
        {'src': 'updated_on', 'tgt': 'aug_claim_provider_billing__bill_adjudication_timestamp'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_bill_detail',
      'alias': 't1',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_BILL_DETAIL',
      'columns': [
        {'src': 'claimed_amt', 'tgt': 'aug_claim_provider_billing__claimed_amount'},
        {'src': 'tot_copay_amt', 'tgt': 'aug_claim_provider_billing__co_pay_amount'},
        {'src': 'discount', 'tgt': 'aug_claim_provider_billing__discount_amount'},
        {'src': 'tot_app_amtmou', 'tgt': 'aug_claim_provider_billing__mou_approved_amount'},
        {'src': 'amt_frm_patient', 'tgt': 'aug_claim_provider_billing__patient_paid_amount'},
        {'src': 'ref_bill_id', 'tgt': 'aug_claim_provider_billing__related_bill_reference'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_bill_detail_ocr',
      'alias': 't2',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_BILL_DETAIL_OCR',
      'columns': [
        {'src': 'claimed_amt', 'tgt': 'aug_claim_provider_billing__claimed_amount'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_claim_provider_billing__bill_adjudicated_by_user',
    'aug_claim_provider_billing__bill_adjudication_timestamp',
    'aug_claim_provider_billing__claimed_amount',
    'aug_claim_provider_billing__co_pay_amount',
    'aug_claim_provider_billing__discount_amount',
    'aug_claim_provider_billing__mou_approved_amount',
    'aug_claim_provider_billing__patient_paid_amount',
    'aug_claim_provider_billing__related_bill_reference'
] -%}
{%- set coalesce_rules = {
    'aug_claim_provider_billing__bill_adjudicated_by_user': ['t0'],
    'aug_claim_provider_billing__bill_adjudication_timestamp': ['t0'],
    'aug_claim_provider_billing__claimed_amount': ['t1', 't2'],
    'aug_claim_provider_billing__co_pay_amount': ['t1'],
    'aug_claim_provider_billing__discount_amount': ['t1'],
    'aug_claim_provider_billing__mou_approved_amount': ['t1'],
    'aug_claim_provider_billing__patient_paid_amount': ['t1'],
    'aug_claim_provider_billing__related_bill_reference': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_aug_claim_provider_billing'
) }}
