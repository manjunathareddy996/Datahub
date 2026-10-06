{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_DOCUMENT_DEFINITION, table 'BJAZ_T_KYC_POI_DOCUMENT'.
-- Anchor HUB_DOCUMENT, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered GLUED because the anchor is a HUB (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- Null-padded TO THE SATELLITE, not to this feeder (BUILD_RULES.md 6): 1 of 9
-- payload column(s) are not carried by BJAZ_T_KYC_POI_DOCUMENT and are emitted as a typed NULL so
-- the HASHDIFF column list is identical across every branch of the union.
-- Padded: DOCUMENTREFERENCENUMBER.
--
-- GRAIN CONFLICT, BUILT AS MAPPED AND RAISED (BUILD_RULES.md 5.7):
-- 8 attribute(s) of this single-active satellite are written by this table AND
-- by BJAZ_T_KYC_POA_DOCUMENT under a BYTE-IDENTICAL HUB_DOCUMENT key, with an EMPTY discriminator.
-- One load silently overwrites the other. The builder does not choose between
-- two writers -- that IS the mapping decision. Attributes: Document Category, Document Format, Document Name, Document Status, Document Type, Expiry Date, Storage Reference, Verification Status.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_kyc_poi_document'
hashed_columns:
  DOCUMENT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DOCUMENTCATEGORY'
      - 'DOCUMENTFORMAT'
      - 'DOCUMENTNAME'
      - 'DOCUMENTREFERENCENUMBER'
      - 'DOCUMENTSTATUS'
      - 'DOCUMENTTYPE'
      - 'EXPIRYDATE'
      - 'STORAGEREFERENCE'
      - 'VERIFICATIONSTATUS'
derived_columns:
  PARENT_BK: "upper(trim(coalesce(docs_type,''))) || ':' || upper(trim(coalesce(docs_number,'')))"
  PARENT_NK: "'HUB_DOCUMENT|' || (upper(trim(coalesce(docs_type,''))) || ':' || upper(trim(coalesce(docs_number,''))))"
  DOCUMENTCATEGORY: 'document_category'
  DOCUMENTFORMAT: 'doc_extension'
  DOCUMENTNAME: 'doc_name'
  DOCUMENTREFERENCENUMBER: "cast(null as varchar)"
  DOCUMENTSTATUS: 'status'
  DOCUMENTTYPE: 'docs_type'
  EXPIRYDATE: 'expiry_date'
  STORAGEREFERENCE: 'omni_doc_index'
  VERIFICATIONSTATUS: 'response_code'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_KYC_POI_DOCUMENT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
