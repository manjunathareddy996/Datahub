-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_MOTOR_DRIVER, read off central view stitch_mxm__v15_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v15_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DRIVER_DETAILS_TEXT'
      - 'DRIVER_TYPE'
      - 'LICENCE_ISSUING_AUTHORITY'
      - 'LICENCE_VALID_INDICATOR'
      - 'DRIVER_LICENCE_NUMBER_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_MOTOR_DRIVER__DRIVER_DETAILS_TEXT, AUG_RISK_MOTOR_DRIVER__DRIVER_TYPE, AUG_RISK_MOTOR_DRIVER__LICENCE_ISSUING_AUTHORITY, AUG_RISK_MOTOR_DRIVER__LICENCE_VALID_INDICATOR) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  DRIVER_LICENCE_NUMBER_CK: 'AUG_RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK'
  DRIVER_DETAILS_TEXT: 'AUG_RISK_MOTOR_DRIVER__DRIVER_DETAILS_TEXT'
  DRIVER_TYPE: 'AUG_RISK_MOTOR_DRIVER__DRIVER_TYPE'
  LICENCE_ISSUING_AUTHORITY: 'AUG_RISK_MOTOR_DRIVER__LICENCE_ISSUING_AUTHORITY'
  LICENCE_VALID_INDICATOR: 'AUG_RISK_MOTOR_DRIVER__LICENCE_VALID_INDICATOR'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v15_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
