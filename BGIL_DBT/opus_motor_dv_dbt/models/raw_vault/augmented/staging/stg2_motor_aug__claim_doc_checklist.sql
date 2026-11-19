-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_DOC_CHECKLIST, read off central view stitch_motor__v01_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v01_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DOCUMENT_NUMBER'
      - 'DOCUMENT_SUBMITTED_INDICATOR'
      - 'DOCUMENT_TYPE'
      - 'REQUIRED_DOCUMENT_TYPE_CK'
      - 'DOCUMENT_TYPE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_NUMBER, AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_SUBMITTED_INDICATOR, AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  REQUIRED_DOCUMENT_TYPE_CK: 'AUG_CLAIM_DOC_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK'
  DOCUMENT_TYPE_CK: 'AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK'
  DOCUMENT_NUMBER: 'AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_NUMBER'
  DOCUMENT_SUBMITTED_INDICATOR: 'AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_SUBMITTED_INDICATOR'
  DOCUMENT_TYPE: 'AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_MOTOR_V01_CLAIM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
