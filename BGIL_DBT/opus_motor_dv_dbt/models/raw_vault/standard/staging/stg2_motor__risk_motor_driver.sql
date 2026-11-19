-- automate_dv.stage() for SAT_RISK_MOTOR_DRIVER, read off central view stitch_motor__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v09_party'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DRIVER_NAME'
      - 'DRIVER_RELATIONSHIP'
      - 'DRIVING_LICENCE_NUMBER'
      - 'LICENCE_TYPE'
      - 'OWNER_DRIVER_INDICATOR'
      - 'DRIVER_LICENCE_NUMBER_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_MOTOR_DRIVER__DRIVER_NAME, RISK_MOTOR_DRIVER__DRIVER_RELATIONSHIP, RISK_MOTOR_DRIVER__DRIVING_LICENCE_NUMBER, RISK_MOTOR_DRIVER__LICENCE_TYPE, RISK_MOTOR_DRIVER__OWNER_DRIVER_INDICATOR) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  DRIVER_LICENCE_NUMBER_CK: 'RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK'
  DRIVER_NAME: 'RISK_MOTOR_DRIVER__DRIVER_NAME'
  DRIVER_RELATIONSHIP: 'RISK_MOTOR_DRIVER__DRIVER_RELATIONSHIP'
  DRIVING_LICENCE_NUMBER: 'RISK_MOTOR_DRIVER__DRIVING_LICENCE_NUMBER'
  LICENCE_TYPE: 'RISK_MOTOR_DRIVER__LICENCE_TYPE'
  OWNER_DRIVER_INDICATOR: 'RISK_MOTOR_DRIVER__OWNER_DRIVER_INDICATOR'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
