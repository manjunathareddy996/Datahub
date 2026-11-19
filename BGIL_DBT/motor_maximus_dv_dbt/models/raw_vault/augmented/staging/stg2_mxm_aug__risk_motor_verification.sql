-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_MOTOR_VERIFICATION, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'REGISTRATION_NUMBER_AS_VERIFIED'
      - 'VERIFICATION_DATA_SOURCE'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_MOTOR_VERIFICATION__REGISTRATION_NUMBER_AS_VERIFIED, AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_DATA_SOURCE) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  REGISTRATION_NUMBER_AS_VERIFIED: 'AUG_RISK_MOTOR_VERIFICATION__REGISTRATION_NUMBER_AS_VERIFIED'
  VERIFICATION_DATA_SOURCE: 'AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_DATA_SOURCE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
