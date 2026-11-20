-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_MOTOR_DRIVER, read off central view stitch_motor__v05_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v05_coverage'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGE_AT_LICENCE_ISSUE'
      - 'DRIVER_LINE_PARTICULARS'
      - 'DRIVER_LICENCE_NUMBER_CK'
      - 'DRIVER_ROLE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_MOTOR_DRIVER__AGE_AT_LICENCE_ISSUE, AUG_RISK_MOTOR_DRIVER__DRIVER_LINE_PARTICULARS) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  DRIVER_LICENCE_NUMBER_CK: 'AUG_RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK'
  DRIVER_ROLE_CK: 'AUG_RISK_MOTOR_DRIVER__DRIVER_ROLE_CK'
  AGE_AT_LICENCE_ISSUE: 'AUG_RISK_MOTOR_DRIVER__AGE_AT_LICENCE_ISSUE'
  DRIVER_LINE_PARTICULARS: 'AUG_RISK_MOTOR_DRIVER__DRIVER_LINE_PARTICULARS'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v05_coverage'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
