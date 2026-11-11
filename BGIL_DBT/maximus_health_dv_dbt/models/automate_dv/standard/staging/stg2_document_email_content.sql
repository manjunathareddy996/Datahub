-- automate_dv.stage() for SAT_DOCUMENT_EMAIL_CONTENT, read off central view stitch_v07_document.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v07_document'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMAIL_BODY'
      - 'EMAIL_FROM'
      - 'EMAIL_SUBJECT'
derived_columns:
  DOCUMENT_NK: "case when coalesce(DOCUMENT_EMAIL_CONTENT__EMAIL_BODY, DOCUMENT_EMAIL_CONTENT__EMAIL_FROM, DOCUMENT_EMAIL_CONTENT__EMAIL_SUBJECT) is not null then 'HUB_DOCUMENT|' || DOCUMENT_BK end"
  EMAIL_BODY: 'DOCUMENT_EMAIL_CONTENT__EMAIL_BODY'
  EMAIL_FROM: 'DOCUMENT_EMAIL_CONTENT__EMAIL_FROM'
  EMAIL_SUBJECT: 'DOCUMENT_EMAIL_CONTENT__EMAIL_SUBJECT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v07_document'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
