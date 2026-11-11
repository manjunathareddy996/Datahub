-- automate_dv.stage() for SAT_DOCUMENT_DEFINITION, read off central view stitch_v01_agreement.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v01_agreement'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DOCUMENT_CATEGORY'
      - 'DOCUMENT_NAME'
      - 'DOCUMENT_REFERENCE_NUMBER'
      - 'DOCUMENT_STATUS'
      - 'DOCUMENT_TYPE'
      - 'EXPIRY_DATE'
      - 'ISSUE_DATE'
      - 'RECEIVED_DATE'
      - 'STORAGE_REFERENCE'
derived_columns:
  DOCUMENT_NK: "case when coalesce(DOCUMENT_DEFINITION__DOCUMENT_CATEGORY, DOCUMENT_DEFINITION__DOCUMENT_NAME, DOCUMENT_DEFINITION__DOCUMENT_REFERENCE_NUMBER, DOCUMENT_DEFINITION__DOCUMENT_STATUS, DOCUMENT_DEFINITION__DOCUMENT_TYPE, DOCUMENT_DEFINITION__EXPIRY_DATE, DOCUMENT_DEFINITION__ISSUE_DATE, DOCUMENT_DEFINITION__RECEIVED_DATE, DOCUMENT_DEFINITION__STORAGE_REFERENCE) is not null then 'HUB_DOCUMENT|' || DOCUMENT_BK end"
  DOCUMENT_CATEGORY: 'DOCUMENT_DEFINITION__DOCUMENT_CATEGORY'
  DOCUMENT_NAME: 'DOCUMENT_DEFINITION__DOCUMENT_NAME'
  DOCUMENT_REFERENCE_NUMBER: 'DOCUMENT_DEFINITION__DOCUMENT_REFERENCE_NUMBER'
  DOCUMENT_STATUS: 'DOCUMENT_DEFINITION__DOCUMENT_STATUS'
  DOCUMENT_TYPE: 'DOCUMENT_DEFINITION__DOCUMENT_TYPE'
  EXPIRY_DATE: 'DOCUMENT_DEFINITION__EXPIRY_DATE'
  ISSUE_DATE: 'DOCUMENT_DEFINITION__ISSUE_DATE'
  RECEIVED_DATE: 'DOCUMENT_DEFINITION__RECEIVED_DATE'
  STORAGE_REFERENCE: 'DOCUMENT_DEFINITION__STORAGE_REFERENCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v01_agreement'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
