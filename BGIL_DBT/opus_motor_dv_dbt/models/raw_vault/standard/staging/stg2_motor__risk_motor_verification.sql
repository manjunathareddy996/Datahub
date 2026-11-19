-- automate_dv.stage() for SAT_RISK_MOTOR_VERIFICATION, read off central view stitch_motor__v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v15_policy'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'VAHAN_CHECK_STATUS'
      - 'VEHICLE_VERIFICATION_REFERENCE'
      - 'VERIFICATION_REMARKS'
      - 'VERIFICATION_REQUEST_NUMBER'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_MOTOR_VERIFICATION__VAHAN_CHECK_STATUS, RISK_MOTOR_VERIFICATION__VEHICLE_VERIFICATION_REFERENCE, RISK_MOTOR_VERIFICATION__VERIFICATION_REMARKS, RISK_MOTOR_VERIFICATION__VERIFICATION_REQUEST_NUMBER) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  VAHAN_CHECK_STATUS: 'RISK_MOTOR_VERIFICATION__VAHAN_CHECK_STATUS'
  VEHICLE_VERIFICATION_REFERENCE: 'RISK_MOTOR_VERIFICATION__VEHICLE_VERIFICATION_REFERENCE'
  VERIFICATION_REMARKS: 'RISK_MOTOR_VERIFICATION__VERIFICATION_REMARKS'
  VERIFICATION_REQUEST_NUMBER: 'RISK_MOTOR_VERIFICATION__VERIFICATION_REQUEST_NUMBER'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V15_POLICY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
