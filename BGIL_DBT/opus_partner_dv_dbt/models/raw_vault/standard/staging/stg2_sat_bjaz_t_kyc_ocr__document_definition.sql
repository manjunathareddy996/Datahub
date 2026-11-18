{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_DOCUMENT_DEFINITION, table 'BJAZ_T_KYC_OCR'.
-- Anchor HUB_DOCUMENT, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered GLUED because the anchor is a HUB (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- Null-padded TO THE SATELLITE, not to this feeder (BUILD_RULES.md 6): 5 of 9
-- payload column(s) are not carried by BJAZ_T_KYC_OCR and are emitted as a typed NULL so
-- the HASHDIFF column list is identical across every branch of the union.
-- Padded: DOCUMENTFORMAT, DOCUMENTNAME, DOCUMENTSTATUS, EXPIRYDATE, STORAGEREFERENCE.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_kyc_ocr'
hashed_columns:
  DOCUMENT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DOCUMENT_CATEGORY'
      - 'DOCUMENTFORMAT'
      - 'DOCUMENT_NAME'
      - 'DOCUMENT_REFERENCE_NUMBER'
      - 'DOCUMENT_STATUS'
      - 'DOCUMENT_TYPE'
      - 'EXPIRY_DATE'
      - 'STORAGE_REFERENCE'
      - 'VERIFICATIONSTATUS'
derived_columns:
  PARENT_BK: "upper(trim(field_type)) || ':' || trim(field_value) || '#' || upper(trim(image_type))"
  PARENT_NK: "'HUB_DOCUMENT|' || (upper(trim(field_type)) || ':' || trim(field_value) || '#' || upper(trim(image_type)))"
  DOCUMENT_CATEGORY: 'category'
  DOCUMENTFORMAT: "cast(null as varchar)"
  DOCUMENT_NAME: "cast(null as varchar)"
  DOCUMENT_REFERENCE_NUMBER: 'file_number'
  DOCUMENT_STATUS: "cast(null as varchar)"
  DOCUMENT_TYPE: 'image_type'
  EXPIRY_DATE: "cast(null as varchar)"
  STORAGE_REFERENCE: "cast(null as varchar)"
  VERIFICATIONSTATUS: 'ocr_status'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_PARTNER_BJAZ_T_KYC_OCR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
