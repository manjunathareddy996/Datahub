-- automate_dv.stage() for SAT_RISK_MOTOR_ADDON, read off central view stitch_mxm__v15_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v15_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADD_ON_OPTED_INDICATOR'
      - 'ADD_ON_PACKAGE_CODE'
      - 'ADD_ON_CODE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR, RISK_MOTOR_ADDON__ADD_ON_PACKAGE_CODE) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  ADD_ON_CODE_CK: 'RISK_MOTOR_ADDON__ADD_ON_CODE_CK'
  ADD_ON_OPTED_INDICATOR: 'RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR'
  ADD_ON_PACKAGE_CODE: 'RISK_MOTOR_ADDON__ADD_ON_PACKAGE_CODE'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v15_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
