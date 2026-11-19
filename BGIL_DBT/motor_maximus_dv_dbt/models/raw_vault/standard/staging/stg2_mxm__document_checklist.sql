-- automate_dv.stage() for SAT_DOCUMENT_CHECKLIST, read off central view stitch_mxm__v06_document.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v06_document'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'REQUIRED_DOCUMENT_TYPE'
      - 'REQUIRED_DOCUMENT_TYPE_CK'
derived_columns:
  DOCUMENT_NK: "case when DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE is not null then 'HUB_DOCUMENT|' || DOCUMENT_BK end"
  REQUIRED_DOCUMENT_TYPE_CK: 'DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK'
  REQUIRED_DOCUMENT_TYPE: 'DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE'
  LOAD_DATETIME: 'DOCUMENT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v06_document'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
