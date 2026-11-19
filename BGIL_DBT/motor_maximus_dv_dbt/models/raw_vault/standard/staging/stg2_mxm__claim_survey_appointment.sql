-- automate_dv.stage() for SAT_CLAIM_SURVEY_APPOINTMENT, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPOINTMENT_STATUS'
      - 'APPOINTMENT_TYPE_CK'
      - 'SURVEYOR_REFERENCE_CK'
derived_columns:
  CLAIM_NK: "case when CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_STATUS is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  APPOINTMENT_TYPE_CK: 'CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_TYPE_CK'
  SURVEYOR_REFERENCE_CK: 'CLAIM_SURVEY_APPOINTMENT__SURVEYOR_REFERENCE_CK'
  APPOINTMENT_STATUS: 'CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_STATUS'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
