-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION, read off central view stitch_mxm__v15_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v15_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERED_INDICATOR'
      - 'COUNTRY_CODE_CK'
      - 'GEOGRAPHICAL_EXTENSION_CODE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COVERED_INDICATOR is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  COUNTRY_CODE_CK: 'AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COUNTRY_CODE_CK'
  GEOGRAPHICAL_EXTENSION_CODE_CK: 'AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__GEOGRAPHICAL_EXTENSION_CODE_CK'
  COVERED_INDICATOR: 'AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COVERED_INDICATOR'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v15_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
