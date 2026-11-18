-- automate_dv.stage() for SAT_AUG_RISK_MOTOR_FITMENTS, read off central view stitch_motor__v14_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v14_policy'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SYSTEM_CALCULATED_FITMENT_VALUE'
      - 'FITMENT_TYPE_CK'
      - 'SEQUENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when AUG_RISK_MOTOR_FITMENTS__SYSTEM_CALCULATED_FITMENT_VALUE is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  FITMENT_TYPE_CK: 'AUG_RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK'
  SEQUENCE_CK: 'AUG_RISK_MOTOR_FITMENTS__SEQUENCE_CK'
  SYSTEM_CALCULATED_FITMENT_VALUE: 'AUG_RISK_MOTOR_FITMENTS__SYSTEM_CALCULATED_FITMENT_VALUE'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v14_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
