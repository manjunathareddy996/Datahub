{{ config(materialized='view') }}
-- This part feeds SAT_AGREEMENT_DEFINITION only. Original precedence comments are kept below (from stitch_v01_agreement).
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
-- depends_on: {{ ref('stg_health__bjaz_remedinet_claim_details') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_hospital_master',
      'alias': 't0',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER',
      'columns': [
        {'src': 'effective_date', 'tgt': 'agreement_definition__effective_date'},
        {'src': 'empanel_date', 'tgt': 'agreement_definition__execution_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't1',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'ppn_type', 'tgt': 'agreement_definition__agreement_category'},
        {'src': 'type_of_mou', 'tgt': 'agreement_definition__agreement_type'},
        {'src': 'mou_from_date', 'tgt': 'agreement_definition__effective_date'},
        {'src': 'mou_revision_date', 'tgt': 'agreement_definition__execution_date'},
        {'src': 'mou_to_date', 'tgt': 'agreement_definition__expiry_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hosp_master_extn1',
      'alias': 't2',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSP_MASTER_EXTN1',
      'columns': [
        {'src': 'hosnundernego', 'tgt': 'agreement_definition__agreement_status'},
        {'src': 'trfvalfrom', 'tgt': 'agreement_definition__effective_date'},
        {'src': 'trfvalto', 'tgt': 'agreement_definition__expiry_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_claim_details',
      'alias': 't3',
      'key_column': 'remedinet_provider_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_CLAIM_DETAILS',
      'columns': [
        {'src': 'tariff_name', 'tgt': 'agreement_definition__agreement_name'}
      ]
    }
] -%}
{%- set output_columns = [
    'agreement_definition__effective_date',
    'agreement_definition__execution_date',
    'agreement_definition__agreement_category',
    'agreement_definition__agreement_type',
    'agreement_definition__expiry_date',
    'agreement_definition__agreement_status',
    'agreement_definition__agreement_name'
] -%}
{%- set coalesce_rules = {
    'agreement_definition__effective_date': ['t0', 't1', 't2'],
    'agreement_definition__execution_date': ['t0', 't1'],
    'agreement_definition__agreement_category': ['t1'],
    'agreement_definition__agreement_type': ['t1'],
    'agreement_definition__expiry_date': ['t1', 't2'],
    'agreement_definition__agreement_status': ['t2'],
    'agreement_definition__agreement_name': ['t3']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='agreement_bk',
    target_sat='sat_agreement_definition'
) }}
