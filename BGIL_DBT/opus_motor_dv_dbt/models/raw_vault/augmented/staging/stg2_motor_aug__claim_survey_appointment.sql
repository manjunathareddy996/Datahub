-- automate_dv.stage() for SAT_AUG_CLAIM_SURVEY_APPOINTMENT, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SURVEYOR_STAGE'
      - 'APPOINTMENT_TYPE_CK'
      - 'SURVEYOR_REFERENCE_CK'
derived_columns:
  CLAIM_NK: "case when AUG_CLAIM_SURVEY_APPOINTMENT__SURVEYOR_STAGE is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  APPOINTMENT_TYPE_CK: 'AUG_CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_TYPE_CK'
  SURVEYOR_REFERENCE_CK: 'AUG_CLAIM_SURVEY_APPOINTMENT__SURVEYOR_REFERENCE_CK'
  SURVEYOR_STAGE: 'AUG_CLAIM_SURVEY_APPOINTMENT__SURVEYOR_STAGE'
  LOAD_DATETIME: 'AUG_CLAIM_SURVEY_APPOINTMENT__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
