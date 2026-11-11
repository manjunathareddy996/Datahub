{{ config(materialized='view') }}
-- This part feeds SAT_AUG_AGREEMENT_COMMERCIAL_TERMS only. Original precedence comments are kept below (from stitch_v01_agreement).
-- CENTRAL VIEW v01_agreement -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HAT_OCR_FINA_PERTICULARS (opus_health_v2)
--   BJAZ_CARD_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER_EXTN (opus_health_legacy_v4)
--   BJAZ_HM_HOSP_MASTER_EXTN1 (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_DTLS (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   NG_FAX_INWARD_DETAILS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AGREEMENT_COMMERCIAL_TERMS
--   SAT_AGREEMENT_DEFINITION
--   SAT_AGREEMENT_SLA
--   SAT_AUG_AGREEMENT_COMMERCIAL_TERMS
--   SAT_AUG_AGREEMENT_DEFINITION
--   SAT_AUG_DOCUMENT_DEFINITION
--   SAT_AUG_PARTY_FRAUD_PROFILE
--   SAT_CLAIM_ASSESSMENT_SUMMARY
--   SAT_DOCUMENT_DEFINITION
--   SAT_LNK_ROLE_PROVIDER
--   SAT_PARTY_FRAUD_PROFILE
--   SAT_PROVIDER_QUALITY
--   SAT_PROVIDER_TARIFF
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_AGREEMENT_CHANNEL
--   LNK_AGREEMENT_PARTY
--   LNK_PARTY_CHANNEL
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_DOCUMENT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_hospital_master',
      'alias': 't0',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER',
      'columns': [
        {'src': 'discount_on', 'tgt': 'aug_agreement_commercial_terms__discount_basis'},
        {'src': 'early_discount', 'tgt': 'aug_agreement_commercial_terms__early_payment_discount_percentage'},
        {'src': 'discount', 'tgt': 'aug_agreement_commercial_terms__empanelment_discount_percentage'},
        {'src': 'payment_mode', 'tgt': 'aug_agreement_commercial_terms__provider_payment_mode'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't1',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'pack_accept_date', 'tgt': 'aug_agreement_commercial_terms__package_acceptance_date'},
        {'src': 'package_class', 'tgt': 'aug_agreement_commercial_terms__package_class'},
        {'src': 'pack_expiry_date', 'tgt': 'aug_agreement_commercial_terms__package_expiry_date'},
        {'src': 'package_type', 'tgt': 'aug_agreement_commercial_terms__package_type'},
        {'src': 'pp_remarks', 'tgt': 'aug_agreement_commercial_terms__preferred_provider_remarks'},
        {'src': 'pp_effective_date', 'tgt': 'aug_agreement_commercial_terms__preferred_provider_terms_effective_date'},
        {'src': 'pp_expiray_date', 'tgt': 'aug_agreement_commercial_terms__preferred_provider_terms_expiry_date'},
        {'src': 'serv_charge_perc', 'tgt': 'aug_agreement_commercial_terms__service_charge_percentage'},
        {'src': 'surcharge_perc', 'tgt': 'aug_agreement_commercial_terms__surcharge_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hosp_master_extn1',
      'alias': 't2',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSP_MASTER_EXTN1',
      'columns': [
        {'src': 'tatrange', 'tgt': 'aug_agreement_commercial_terms__bill_settlement_tat_range'},
        {'src': 'cbdiscbusfig', 'tgt': 'aug_agreement_commercial_terms__cashless_bill_discount_business_volume'},
        {'src': 'cbdiscon', 'tgt': 'aug_agreement_commercial_terms__cashless_bill_discount_effective_date'},
        {'src': 'cbdisc', 'tgt': 'aug_agreement_commercial_terms__cashless_bill_discount_percentage'},
        {'src': 'cbdiscremark', 'tgt': 'aug_agreement_commercial_terms__cashless_bill_discount_remark'},
        {'src': 'cbbillrectime', 'tgt': 'aug_agreement_commercial_terms__cashless_bill_receipt_time'},
        {'src': 'earlypaydiscon', 'tgt': 'aug_agreement_commercial_terms__early_payment_discount_effective_date'},
        {'src': 'earlypaydisc', 'tgt': 'aug_agreement_commercial_terms__early_payment_discount_percentage'},
        {'src': 'earlypayremark', 'tgt': 'aug_agreement_commercial_terms__early_payment_discount_remark'},
        {'src': 'nonchmsurg', 'tgt': 'aug_agreement_commercial_terms__non_chm_surgery_indicator'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_agreement_commercial_terms__discount_basis',
    'aug_agreement_commercial_terms__early_payment_discount_percentage',
    'aug_agreement_commercial_terms__empanelment_discount_percentage',
    'aug_agreement_commercial_terms__provider_payment_mode',
    'aug_agreement_commercial_terms__package_acceptance_date',
    'aug_agreement_commercial_terms__package_class',
    'aug_agreement_commercial_terms__package_expiry_date',
    'aug_agreement_commercial_terms__package_type',
    'aug_agreement_commercial_terms__preferred_provider_remarks',
    'aug_agreement_commercial_terms__preferred_provider_terms_effective_date',
    'aug_agreement_commercial_terms__preferred_provider_terms_expiry_date',
    'aug_agreement_commercial_terms__service_charge_percentage',
    'aug_agreement_commercial_terms__surcharge_percentage',
    'aug_agreement_commercial_terms__bill_settlement_tat_range',
    'aug_agreement_commercial_terms__cashless_bill_discount_business_volume',
    'aug_agreement_commercial_terms__cashless_bill_discount_effective_date',
    'aug_agreement_commercial_terms__cashless_bill_discount_percentage',
    'aug_agreement_commercial_terms__cashless_bill_discount_remark',
    'aug_agreement_commercial_terms__cashless_bill_receipt_time',
    'aug_agreement_commercial_terms__early_payment_discount_effective_date',
    'aug_agreement_commercial_terms__early_payment_discount_remark',
    'aug_agreement_commercial_terms__non_chm_surgery_indicator'
] -%}
{%- set coalesce_rules = {
    'aug_agreement_commercial_terms__discount_basis': ['t0'],
    'aug_agreement_commercial_terms__early_payment_discount_percentage': ['t0', 't2'],
    'aug_agreement_commercial_terms__empanelment_discount_percentage': ['t0'],
    'aug_agreement_commercial_terms__provider_payment_mode': ['t0'],
    'aug_agreement_commercial_terms__package_acceptance_date': ['t1'],
    'aug_agreement_commercial_terms__package_class': ['t1'],
    'aug_agreement_commercial_terms__package_expiry_date': ['t1'],
    'aug_agreement_commercial_terms__package_type': ['t1'],
    'aug_agreement_commercial_terms__preferred_provider_remarks': ['t1'],
    'aug_agreement_commercial_terms__preferred_provider_terms_effective_date': ['t1'],
    'aug_agreement_commercial_terms__preferred_provider_terms_expiry_date': ['t1'],
    'aug_agreement_commercial_terms__service_charge_percentage': ['t1'],
    'aug_agreement_commercial_terms__surcharge_percentage': ['t1'],
    'aug_agreement_commercial_terms__bill_settlement_tat_range': ['t2'],
    'aug_agreement_commercial_terms__cashless_bill_discount_business_volume': ['t2'],
    'aug_agreement_commercial_terms__cashless_bill_discount_effective_date': ['t2'],
    'aug_agreement_commercial_terms__cashless_bill_discount_percentage': ['t2'],
    'aug_agreement_commercial_terms__cashless_bill_discount_remark': ['t2'],
    'aug_agreement_commercial_terms__cashless_bill_receipt_time': ['t2'],
    'aug_agreement_commercial_terms__early_payment_discount_effective_date': ['t2'],
    'aug_agreement_commercial_terms__early_payment_discount_remark': ['t2'],
    'aug_agreement_commercial_terms__non_chm_surgery_indicator': ['t2']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='agreement_bk',
    target_sat='sat_aug_agreement_commercial_terms'
) }}
