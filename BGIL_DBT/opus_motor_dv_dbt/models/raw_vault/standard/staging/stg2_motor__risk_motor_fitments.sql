-- automate_dv.stage() for SAT_RISK_MOTOR_FITMENTS, read off central view stitch_motor__v25_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v25_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FITMENT_VALUE'
      - 'SUM_INSURED'
      - 'FITMENT_TYPE_CK'
      - 'SEQUENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_MOTOR_FITMENTS__FITMENT_VALUE, RISK_MOTOR_FITMENTS__SUM_INSURED) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  FITMENT_TYPE_CK: 'RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK'
  SEQUENCE_CK: 'RISK_MOTOR_FITMENTS__SEQUENCE_CK'
  FITMENT_VALUE: 'RISK_MOTOR_FITMENTS__FITMENT_VALUE'
  SUM_INSURED: 'RISK_MOTOR_FITMENTS__SUM_INSURED'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v25_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
