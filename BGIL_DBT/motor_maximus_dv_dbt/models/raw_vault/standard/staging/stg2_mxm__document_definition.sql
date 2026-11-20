-- automate_dv.stage() for SAT_DOCUMENT_DEFINITION, read off central view stitch_mxm__v06_document.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v06_document'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DOCUMENT_NAME'
      - 'DOCUMENT_TYPE'
      - 'ISSUE_DATE'
      - 'RECEIVED_DATE'
derived_columns:
  DOCUMENT_NK: "case when coalesce(DOCUMENT_DEFINITION__DOCUMENT_NAME, DOCUMENT_DEFINITION__DOCUMENT_TYPE, DOCUMENT_DEFINITION__ISSUE_DATE, DOCUMENT_DEFINITION__RECEIVED_DATE) is not null then 'HUB_DOCUMENT|' || DOCUMENT_BK end"
  DOCUMENT_NAME: 'DOCUMENT_DEFINITION__DOCUMENT_NAME'
  DOCUMENT_TYPE: 'DOCUMENT_DEFINITION__DOCUMENT_TYPE'
  ISSUE_DATE: 'DOCUMENT_DEFINITION__ISSUE_DATE'
  RECEIVED_DATE: 'DOCUMENT_DEFINITION__RECEIVED_DATE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v06_document'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
