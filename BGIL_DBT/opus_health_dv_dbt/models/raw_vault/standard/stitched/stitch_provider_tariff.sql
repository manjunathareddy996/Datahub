{{ config(materialized='view') }}
-- This part feeds SAT_PROVIDER_TARIFF only. Original precedence comments are kept below (from stitch_v01_agreement).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't0',
      'key_column': "hosid || '|' || coalesce(pp_disc_services1, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'pp_disc_services1', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'pp_discount1', 'tgt': 'provider_tariff__discount_percentage'},
        {'src': 'tariff_from_date', 'tgt': 'provider_tariff__effective_date'},
        {'src': 'tariff_to_date', 'tgt': 'provider_tariff__expiry_date'},
        {'src': 'package_rates', 'tgt': 'provider_tariff__package_rate'},
        {'src': 'pp_disc_services1', 'tgt': 'provider_tariff__service_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't1',
      'key_column': "hosid || '|' || coalesce(pp_disc_services2, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'pp_disc_services2', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'pp_discount2', 'tgt': 'provider_tariff__discount_percentage'},
        {'src': 'pp_disc_services2', 'tgt': 'provider_tariff__service_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't2',
      'key_column': "hosid || '|' || coalesce(pp_disc_services3, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'pp_disc_services3', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'pp_discount3', 'tgt': 'provider_tariff__discount_percentage'},
        {'src': 'pp_disc_services3', 'tgt': 'provider_tariff__service_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't3',
      'key_column': "hosid || '|' || coalesce(pp_disc_services4, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'pp_disc_services4', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'pp_discount4', 'tgt': 'provider_tariff__discount_percentage'},
        {'src': 'pp_disc_services4', 'tgt': 'provider_tariff__service_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't4',
      'key_column': "hosid || '|' || coalesce(pp_disc_services5, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'pp_disc_services5', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'pp_discount5', 'tgt': 'provider_tariff__discount_percentage'},
        {'src': 'pp_disc_services5', 'tgt': 'provider_tariff__service_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't5',
      'key_column': "hosid || '|' || coalesce(pp_disc_services6, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'pp_disc_services6', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'pp_discount6', 'tgt': 'provider_tariff__discount_percentage'},
        {'src': 'pp_disc_services6', 'tgt': 'provider_tariff__service_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't6',
      'key_column': "hosid || '|' || coalesce(pp_disc_services7, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'pp_disc_services7', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'pp_discount7', 'tgt': 'provider_tariff__discount_percentage'},
        {'src': 'pp_disc_services7', 'tgt': 'provider_tariff__service_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't7',
      'key_column': "hosid || '|' || coalesce(pp_disc_services8, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'pp_disc_services8', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'pp_discount8', 'tgt': 'provider_tariff__discount_percentage'},
        {'src': 'pp_disc_services8', 'tgt': 'provider_tariff__service_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't8',
      'key_column': "hosid || '|' || coalesce(pp_disc_services9, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'pp_disc_services9', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'pp_discount9', 'tgt': 'provider_tariff__discount_percentage'},
        {'src': 'pp_disc_services9', 'tgt': 'provider_tariff__service_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't9',
      'key_column': "hosid || '|' || coalesce(pp_disc_services10, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'pp_disc_services10', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'pp_discount10', 'tgt': 'provider_tariff__discount_percentage'},
        {'src': 'pp_disc_services10', 'tgt': 'provider_tariff__service_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't10',
      'key_column': "hosid || '|' || coalesce(pp_disc_services11, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'pp_disc_services11', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'pp_discount11', 'tgt': 'provider_tariff__discount_percentage'},
        {'src': 'pp_disc_services11', 'tgt': 'provider_tariff__service_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't11',
      'key_column': "hosid || '|' || coalesce(pp_disc_services12, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'pp_disc_services12', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'pp_discount12', 'tgt': 'provider_tariff__discount_percentage'},
        {'src': 'pp_disc_services12', 'tgt': 'provider_tariff__service_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hosp_master_extn1',
      'alias': 't12',
      'key_column': "hosid || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSP_MASTER_EXTN1',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'provider_tariff__service_code_ck'},
        {'src': 'stepdwnrmrent', 'tgt': 'provider_tariff__room_rent_cap'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_bk',
    'provider_tariff__service_code_ck',
    'provider_tariff__discount_percentage',
    'provider_tariff__effective_date',
    'provider_tariff__expiry_date',
    'provider_tariff__package_rate',
    'provider_tariff__service_description',
    'provider_tariff__room_rent_cap'
] -%}
{%- set coalesce_rules = {
    'party_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12'],
    'provider_tariff__service_code_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12'],
    'provider_tariff__discount_percentage': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11'],
    'provider_tariff__effective_date': ['t0'],
    'provider_tariff__expiry_date': ['t0'],
    'provider_tariff__package_rate': ['t0'],
    'provider_tariff__service_description': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11'],
    'provider_tariff__room_rent_cap': ['t12']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='provider_tariff_pk',
    target_sat='sat_provider_tariff'
) }}
