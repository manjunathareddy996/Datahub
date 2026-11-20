-- automate_dv.stage() for SAT_RISK_MOTOR_IDV, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGREED_IDV'
      - 'CNG_KIT_IDV'
      - 'COMPUTED_IDV'
      - 'SIDE_CAR_IDV'
      - 'TOTAL_IDV'
      - 'VEHICLE_AGE'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_MOTOR_IDV__AGREED_IDV, RISK_MOTOR_IDV__CNG_KIT_IDV, RISK_MOTOR_IDV__COMPUTED_IDV, RISK_MOTOR_IDV__SIDE_CAR_IDV, RISK_MOTOR_IDV__TOTAL_IDV, RISK_MOTOR_IDV__VEHICLE_AGE) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  AGREED_IDV: 'RISK_MOTOR_IDV__AGREED_IDV'
  CNG_KIT_IDV: 'RISK_MOTOR_IDV__CNG_KIT_IDV'
  COMPUTED_IDV: 'RISK_MOTOR_IDV__COMPUTED_IDV'
  SIDE_CAR_IDV: 'RISK_MOTOR_IDV__SIDE_CAR_IDV'
  TOTAL_IDV: 'RISK_MOTOR_IDV__TOTAL_IDV'
  VEHICLE_AGE: 'RISK_MOTOR_IDV__VEHICLE_AGE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v14_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
