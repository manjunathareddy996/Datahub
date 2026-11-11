-- automate_dv.stage() for SAT_DOCUMENT_CHECKLIST, read off central view stitch_v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v03_claim'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MANDATORY_INDICATOR'
      - 'RECEIVED_INDICATOR'
      - 'REQUIRED_DOCUMENT_TYPE'
      - 'VERIFICATION_STATUS'
      - 'REQUIRED_DOCUMENT_TYPE_CK'
derived_columns:
  DOCUMENT_NK: "case when coalesce(DOCUMENT_CHECKLIST__MANDATORY_INDICATOR, DOCUMENT_CHECKLIST__RECEIVED_INDICATOR, DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE, DOCUMENT_CHECKLIST__VERIFICATION_STATUS) is not null then 'HUB_DOCUMENT|' || DOCUMENT_BK end"
  REQUIRED_DOCUMENT_TYPE_CK: 'DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK'
  MANDATORY_INDICATOR: 'DOCUMENT_CHECKLIST__MANDATORY_INDICATOR'
  RECEIVED_INDICATOR: 'DOCUMENT_CHECKLIST__RECEIVED_INDICATOR'
  REQUIRED_DOCUMENT_TYPE: 'DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE'
  VERIFICATION_STATUS: 'DOCUMENT_CHECKLIST__VERIFICATION_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
