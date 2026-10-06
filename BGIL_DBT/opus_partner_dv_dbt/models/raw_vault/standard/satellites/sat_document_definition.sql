{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER+KYC STANDARD-MODEL sat() for SAT_DOCUMENT_DEFINITION (HUB_DOCUMENT grain) -- union of 3 branch(es).
-- data_7: hist 'SCD2', childkey '', anchor parent 'HUB_DOCUMENT'.
-- Payload rendered GLUED (DEC-01, anchor kind HUB read from data_7's parent field).
--
-- KNOWN DESTRUCTIVE OVERWRITE, BUILT AS MAPPED AND RAISED (5.7). 8 attribute(s)
-- of this SINGLE-ACTIVE satellite are written by more than one source table
-- under a byte-identical HUB_DOCUMENT key with an EMPTY discriminator, so whichever
-- branch loads last wins: Document Category, Document Format, Document Name, Document Status, Document Type, Expiry Date, Storage Reference, Verification Status.
-- The builder refuses to invent a discriminator. One modeller answer unblocks it.
--
-- opus_partner_dv_dbt: written in this project's pattern -- incremental append, sat_multi_source, src_record_source_map OPUS, src_column_map per source; source_model listed once each.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_t_kyc_ocr__document_definition'
  - 'stg2_sat_bjaz_t_kyc_poa_document__document_definition'
  - 'stg2_sat_bjaz_t_kyc_poi_document__document_definition'
src_pk: 'DOCUMENT_HKEY'
src_payload:
  - 'DOCUMENTCATEGORY'
  - 'DOCUMENTFORMAT'
  - 'DOCUMENTNAME'
  - 'DOCUMENTREFERENCENUMBER'
  - 'DOCUMENTSTATUS'
  - 'DOCUMENTTYPE'
  - 'EXPIRYDATE'
  - 'STORAGEREFERENCE'
  - 'VERIFICATIONSTATUS'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_sat_bjaz_t_kyc_ocr__document_definition: 'OPUS'
  stg2_sat_bjaz_t_kyc_poa_document__document_definition: 'OPUS'
  stg2_sat_bjaz_t_kyc_poi_document__document_definition: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_sat_bjaz_t_kyc_ocr__document_definition': ['DOCUMENTCATEGORY', 'DOCUMENTREFERENCENUMBER', 'DOCUMENTTYPE', 'VERIFICATIONSTATUS'],
                        'stg2_sat_bjaz_t_kyc_poa_document__document_definition': ['DOCUMENTCATEGORY', 'DOCUMENTFORMAT', 'DOCUMENTNAME', 'DOCUMENTSTATUS', 'DOCUMENTTYPE', 'EXPIRYDATE', 'STORAGEREFERENCE', 'VERIFICATIONSTATUS'],
                        'stg2_sat_bjaz_t_kyc_poi_document__document_definition': ['DOCUMENTCATEGORY', 'DOCUMENTFORMAT', 'DOCUMENTNAME', 'DOCUMENTSTATUS', 'DOCUMENTTYPE', 'EXPIRYDATE', 'STORAGEREFERENCE', 'VERIFICATIONSTATUS']
                    }) }}
