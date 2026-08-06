{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_DOCUMENT_DEFINITION (HUB_DOCUMENT grain) -- stitch-backed, 3 table(s) joined.
-- Source: stg2_document_definition.

{%- set yaml_metadata -%}
source_model: 'stg2_document_definition'
src_pk: 'DOCUMENT_HKEY'
src_payload:
  - 'DOCUMENT_CATEGORY'
  - 'DOCUMENT_NAME'
  - 'DOCUMENT_REFERENCE_NUMBER'
  - 'DOCUMENT_STATUS'
  - 'DOCUMENT_TYPE'
  - 'EXPIRY_DATE'
  - 'RECEIVED_DATE'
  - 'STORAGE_REFERENCE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
