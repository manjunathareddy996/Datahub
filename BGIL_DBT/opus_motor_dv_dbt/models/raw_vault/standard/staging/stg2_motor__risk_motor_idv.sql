-- automate_dv.stage() for SAT_RISK_MOTOR_IDV, read off central view stitch_motor__v24_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v24_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGREED_IDV'
      - 'CNG_KIT_IDV'
      - 'COMPUTED_IDV'
      - 'DEPRECIATION_PERCENTAGE'
      - 'EX_SHOWROOM_PRICE'
      - 'IDV_BASIS'
      - 'IDV_BASIS_INDICATOR'
      - 'TOTAL_IDV'
      - 'VEHICLE_AGE'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_MOTOR_IDV__AGREED_IDV, RISK_MOTOR_IDV__CNG_KIT_IDV, RISK_MOTOR_IDV__COMPUTED_IDV, RISK_MOTOR_IDV__DEPRECIATION_PERCENTAGE, RISK_MOTOR_IDV__EX_SHOWROOM_PRICE, RISK_MOTOR_IDV__IDV_BASIS, RISK_MOTOR_IDV__IDV_BASIS_INDICATOR, RISK_MOTOR_IDV__TOTAL_IDV, RISK_MOTOR_IDV__VEHICLE_AGE) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  AGREED_IDV: 'RISK_MOTOR_IDV__AGREED_IDV'
  CNG_KIT_IDV: 'RISK_MOTOR_IDV__CNG_KIT_IDV'
  COMPUTED_IDV: 'RISK_MOTOR_IDV__COMPUTED_IDV'
  DEPRECIATION_PERCENTAGE: 'RISK_MOTOR_IDV__DEPRECIATION_PERCENTAGE'
  EX_SHOWROOM_PRICE: 'RISK_MOTOR_IDV__EX_SHOWROOM_PRICE'
  IDV_BASIS: 'RISK_MOTOR_IDV__IDV_BASIS'
  IDV_BASIS_INDICATOR: 'RISK_MOTOR_IDV__IDV_BASIS_INDICATOR'
  TOTAL_IDV: 'RISK_MOTOR_IDV__TOTAL_IDV'
  VEHICLE_AGE: 'RISK_MOTOR_IDV__VEHICLE_AGE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v24_risk_object'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
