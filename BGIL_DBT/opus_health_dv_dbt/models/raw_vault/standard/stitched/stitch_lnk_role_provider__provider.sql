{{ config(materialized='view') }}
-- This part feeds SAT_LNK_ROLE_PROVIDER only. Original precedence comments are kept below (from stitch_v01_agreement).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_claim_details') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't0',
      'key_column': 'hospital_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'hospital_type', 'tgt': 'lnk_role_provider__provider_type'},
        {'src': "'PROVIDER'", 'tgt': 'lnk_role_provider__role_type_ck'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master',
      'alias': 't1',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER',
      'columns': [
        {'src': 'hos_status', 'tgt': 'lnk_role_provider__empanelment_status'},
        {'src': 'preferred_flag', 'tgt': 'lnk_role_provider__preferred_provider_indicator'},
        {'src': "'PROVIDER'", 'tgt': 'lnk_role_provider__role_type_ck'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't2',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'year_empanelment', 'tgt': 'lnk_role_provider__empanelment_date'},
        {'src': "'PROVIDER'", 'tgt': 'lnk_role_provider__role_type_ck'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hosp_master_extn1',
      'alias': 't3',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSP_MASTER_EXTN1',
      'columns': [
        {'src': 'ntopratio', 'tgt': 'lnk_role_provider__nurse_to_patient_ratio'},
        {'src': 'suspendforext', 'tgt': 'lnk_role_provider__suspension_indicator'},
        {'src': "'PROVIDER'", 'tgt': 'lnk_role_provider__role_type_ck'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_claim_details',
      'alias': 't4',
      'key_column': 'payer_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_CLAIM_DETAILS',
      'columns': [
        {'src': 'remedinet_provider_code', 'tgt': 'lnk_role_provider__provider_code'},
        {'src': "'PROVIDER'", 'tgt': 'lnk_role_provider__role_type_ck'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't5',
      'key_column': 'customer_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'hospital_code', 'tgt': 'lnk_role_provider__provider_code'},
        {'src': "'PROVIDER'", 'tgt': 'lnk_role_provider__role_type_ck'}
      ]
    }
] -%}
{%- set output_columns = [
    'lnk_role_provider__provider_type',
    'lnk_role_provider__role_type_ck',
    'lnk_role_provider__empanelment_status',
    'lnk_role_provider__preferred_provider_indicator',
    'lnk_role_provider__empanelment_date',
    'lnk_role_provider__nurse_to_patient_ratio',
    'lnk_role_provider__suspension_indicator',
    'lnk_role_provider__provider_code'
] -%}
{%- set coalesce_rules = {
    'lnk_role_provider__provider_type': ['t0'],
    'lnk_role_provider__role_type_ck': ['t0', 't1', 't2', 't3', 't4', 't5'],
    'lnk_role_provider__empanelment_status': ['t1'],
    'lnk_role_provider__preferred_provider_indicator': ['t1'],
    'lnk_role_provider__empanelment_date': ['t2'],
    'lnk_role_provider__nurse_to_patient_ratio': ['t3'],
    'lnk_role_provider__suspension_indicator': ['t3'],
    'lnk_role_provider__provider_code': ['t4', 't5']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_bk',
    target_sat='sat_lnk_role_provider'
) }}
