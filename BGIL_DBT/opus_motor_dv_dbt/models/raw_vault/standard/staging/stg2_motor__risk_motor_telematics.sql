-- automate_dv.stage() for SAT_RISK_MOTOR_TELEMATICS, read off central view stitch_motor__v25_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v25_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DRIVING_BEHAVIOUR_SCORE'
      - 'INCLUDED_KILOMETRES'
      - 'ODOMETER_READING'
      - 'PLAN_EFFECTIVE_DATE'
      - 'SCORE_DATE'
      - 'TOP_UP_KILOMETRE_SLAB'
      - 'USAGE_BASED_PLAN_TYPE'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_MOTOR_TELEMATICS__DRIVING_BEHAVIOUR_SCORE, RISK_MOTOR_TELEMATICS__INCLUDED_KILOMETRES, RISK_MOTOR_TELEMATICS__ODOMETER_READING, RISK_MOTOR_TELEMATICS__PLAN_EFFECTIVE_DATE, RISK_MOTOR_TELEMATICS__SCORE_DATE, RISK_MOTOR_TELEMATICS__TOP_UP_KILOMETRE_SLAB, RISK_MOTOR_TELEMATICS__USAGE_BASED_PLAN_TYPE) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  DRIVING_BEHAVIOUR_SCORE: 'RISK_MOTOR_TELEMATICS__DRIVING_BEHAVIOUR_SCORE'
  INCLUDED_KILOMETRES: 'RISK_MOTOR_TELEMATICS__INCLUDED_KILOMETRES'
  ODOMETER_READING: 'RISK_MOTOR_TELEMATICS__ODOMETER_READING'
  PLAN_EFFECTIVE_DATE: 'RISK_MOTOR_TELEMATICS__PLAN_EFFECTIVE_DATE'
  SCORE_DATE: 'RISK_MOTOR_TELEMATICS__SCORE_DATE'
  TOP_UP_KILOMETRE_SLAB: 'RISK_MOTOR_TELEMATICS__TOP_UP_KILOMETRE_SLAB'
  USAGE_BASED_PLAN_TYPE: 'RISK_MOTOR_TELEMATICS__USAGE_BASED_PLAN_TYPE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V25_RISK_OBJECT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
