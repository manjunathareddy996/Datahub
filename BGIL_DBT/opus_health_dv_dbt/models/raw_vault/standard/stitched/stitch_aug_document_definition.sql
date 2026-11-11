{{ config(materialized='view') }}
-- This part feeds SAT_AUG_DOCUMENT_DEFINITION only. Original precedence comments are kept below (from stitch_v01_agreement).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_inward_dtls') }}
-- depends_on: {{ ref('stg_health__ng_fax_inward_details') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_inward_dtls',
      'alias': 't0',
      'key_column': 'inward_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_INWARD_DTLS',
      'columns': [
        {'src': 'doc_remark', 'tgt': 'aug_document_definition__document_remarks'},
        {'src': 'pod_no', 'tgt': 'aug_document_definition__proof_of_delivery_number'},
        {'src': 'doc_rec_time', 'tgt': 'aug_document_definition__received_time'}
      ]
    },
    {
      'model': 'stg_health__ng_fax_inward_details',
      'alias': 't1',
      'key_column': "nullif('INWARD:' || nullif(trim(inwardno),''), 'INWARD:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_NG_FAX_INWARD_DETAILS',
      'columns': [
        {'src': 'fax_no', 'tgt': 'aug_document_definition__originating_fax_number'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_document_definition__document_remarks',
    'aug_document_definition__proof_of_delivery_number',
    'aug_document_definition__received_time',
    'aug_document_definition__originating_fax_number'
] -%}
{%- set coalesce_rules = {
    'aug_document_definition__document_remarks': ['t0'],
    'aug_document_definition__proof_of_delivery_number': ['t0'],
    'aug_document_definition__received_time': ['t0'],
    'aug_document_definition__originating_fax_number': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='document_bk',
    target_sat='sat_aug_document_definition'
) }}
