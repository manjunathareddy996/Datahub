{{ config(materialized='view') }}
-- This part feeds SAT_DOCUMENT_DEFINITION only. Original precedence comments are kept below (from stitch_v01_agreement).
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
-- depends_on: {{ ref('stg_health__bjaz_hat_ocr_fina_perticulars') }}
-- depends_on: {{ ref('stg_health__bjaz_card_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_inward_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_claim_details') }}
-- depends_on: {{ ref('stg_health__ng_fax_inward_details') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hat_ocr_fina_perticulars',
      'alias': 't0',
      'key_column': "nullif(trim(inward_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_OCR_FINA_PERTICULARS',
      'columns': [
        {'src': 'inward_no', 'tgt': 'document_definition__document_reference_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_card_dtls',
      'alias': 't1',
      'key_column': 'card_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CARD_DTLS',
      'columns': [
        {'src': 'card_status', 'tgt': 'document_definition__document_status'},
        {'src': 'card_type', 'tgt': 'document_definition__document_type'},
        {'src': 'card_expiry', 'tgt': 'document_definition__expiry_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_inward_dtls',
      'alias': 't2',
      'key_column': 'inward_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_INWARD_DTLS',
      'columns': [
        {'src': 'pertain_to', 'tgt': 'document_definition__document_category'},
        {'src': 'inward_no', 'tgt': 'document_definition__document_reference_number'},
        {'src': 'doc_rec_date', 'tgt': 'document_definition__received_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_claim_details',
      'alias': 't3',
      'key_column': 'omni_inward_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_CLAIM_DETAILS',
      'columns': [
        {'src': 'coalesce(approval_file_name, compressed_file, member_photo_file_name)', 'tgt': 'document_definition__document_name'}
      ]
    },
    {
      'model': 'stg_health__ng_fax_inward_details',
      'alias': 't4',
      'key_column': "nullif('INWARD:' || nullif(trim(inwardno),''), 'INWARD:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_NG_FAX_INWARD_DETAILS',
      'columns': [
        {'src': 'imagename', 'tgt': 'document_definition__document_name'},
        {'src': 'faxcreateddate', 'tgt': 'document_definition__issue_date'},
        {'src': 'createddate', 'tgt': 'document_definition__received_date'},
        {'src': 'docindex', 'tgt': 'document_definition__storage_reference'}
      ]
    }
] -%}
{%- set output_columns = [
    'document_definition__document_reference_number',
    'document_definition__document_status',
    'document_definition__document_type',
    'document_definition__expiry_date',
    'document_definition__document_category',
    'document_definition__received_date',
    'document_definition__document_name',
    'document_definition__issue_date',
    'document_definition__storage_reference'
] -%}
{%- set coalesce_rules = {
    'document_definition__document_reference_number': ['t0', 't2'],
    'document_definition__document_status': ['t1'],
    'document_definition__document_type': ['t1'],
    'document_definition__expiry_date': ['t1'],
    'document_definition__document_category': ['t2'],
    'document_definition__received_date': ['t2', 't4'],
    'document_definition__document_name': ['t3', 't4'],
    'document_definition__issue_date': ['t4'],
    'document_definition__storage_reference': ['t4']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='document_bk',
    target_sat='sat_document_definition'
) }}
