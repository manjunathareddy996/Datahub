-- automate_dv.stage() for SAT_AUG_DOCUMENT_CHECKLIST, read off central view stitch_v07_document.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v07_document'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DOCUMENT_BELONGS_TO_PARTY_ROLE'
      - 'REQUIRED_FROM_PARTY_ROLE'
      - 'REQUIREMENT_RAISED_BY_REFERENCE'
      - 'REQUIREMENT_RAISED_DATE'
      - 'REQUIRED_DOCUMENT_TYPE_CK'
derived_columns:
  DOCUMENT_NK: "case when coalesce(AUG_DOCUMENT_CHECKLIST__DOCUMENT_BELONGS_TO_PARTY_ROLE, AUG_DOCUMENT_CHECKLIST__REQUIRED_FROM_PARTY_ROLE, AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RAISED_BY_REFERENCE, AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RAISED_DATE) is not null then 'HUB_DOCUMENT|' || DOCUMENT_BK end"
  REQUIRED_DOCUMENT_TYPE_CK: 'AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK'
  DOCUMENT_BELONGS_TO_PARTY_ROLE: 'AUG_DOCUMENT_CHECKLIST__DOCUMENT_BELONGS_TO_PARTY_ROLE'
  REQUIRED_FROM_PARTY_ROLE: 'AUG_DOCUMENT_CHECKLIST__REQUIRED_FROM_PARTY_ROLE'
  REQUIREMENT_RAISED_BY_REFERENCE: 'AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RAISED_BY_REFERENCE'
  REQUIREMENT_RAISED_DATE: 'AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RAISED_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v07_document'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
