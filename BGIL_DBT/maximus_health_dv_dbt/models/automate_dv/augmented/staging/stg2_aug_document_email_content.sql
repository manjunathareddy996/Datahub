-- automate_dv.stage() for SAT_AUG_DOCUMENT_EMAIL_CONTENT, read off central view stitch_v07_document.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v07_document'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DELIVERY_STATUS'
derived_columns:
  DOCUMENT_NK: "case when AUG_DOCUMENT_EMAIL_CONTENT__DELIVERY_STATUS is not null then 'HUB_DOCUMENT|' || DOCUMENT_BK end"
  DELIVERY_STATUS: 'AUG_DOCUMENT_EMAIL_CONTENT__DELIVERY_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v07_document'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
