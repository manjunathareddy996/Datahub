-- automate_dv.stage() for SAT_DOCUMENT_DEFINITION, read off central view stitch_v07_document.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v07_document'
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
      - 'FILE_SIZE'
      - 'PAGE_COUNT'
      - 'RECEIVED_DATE'
      - 'SOURCE_CHANNEL'
derived_columns:
  DOCUMENT_NK: "case when coalesce(DOCUMENT_DEFINITION__DOCUMENT_CATEGORY, DOCUMENT_DEFINITION__DOCUMENT_NAME, DOCUMENT_DEFINITION__DOCUMENT_REFERENCE_NUMBER, DOCUMENT_DEFINITION__DOCUMENT_STATUS, DOCUMENT_DEFINITION__DOCUMENT_TYPE, DOCUMENT_DEFINITION__FILE_SIZE, DOCUMENT_DEFINITION__PAGE_COUNT, DOCUMENT_DEFINITION__RECEIVED_DATE, DOCUMENT_DEFINITION__SOURCE_CHANNEL) is not null then 'HUB_DOCUMENT|' || DOCUMENT_BK end"
  DOCUMENT_CATEGORY: 'DOCUMENT_DEFINITION__DOCUMENT_CATEGORY'
  DOCUMENT_NAME: 'DOCUMENT_DEFINITION__DOCUMENT_NAME'
  DOCUMENT_REFERENCE_NUMBER: 'DOCUMENT_DEFINITION__DOCUMENT_REFERENCE_NUMBER'
  DOCUMENT_STATUS: 'DOCUMENT_DEFINITION__DOCUMENT_STATUS'
  DOCUMENT_TYPE: 'DOCUMENT_DEFINITION__DOCUMENT_TYPE'
  FILE_SIZE: 'DOCUMENT_DEFINITION__FILE_SIZE'
  PAGE_COUNT: 'DOCUMENT_DEFINITION__PAGE_COUNT'
  RECEIVED_DATE: 'DOCUMENT_DEFINITION__RECEIVED_DATE'
  SOURCE_CHANNEL: 'DOCUMENT_DEFINITION__SOURCE_CHANNEL'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v07_document'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
