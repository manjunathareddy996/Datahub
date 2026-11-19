-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_MOTOR_BUREAU_ENQUIRY, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BUREAU_ENQUIRY_REFERENCE'
      - 'BUREAU_ENQUIRY_REFERENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when AUG_RISK_MOTOR_BUREAU_ENQUIRY__BUREAU_ENQUIRY_REFERENCE is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  BUREAU_ENQUIRY_REFERENCE_CK: 'AUG_RISK_MOTOR_BUREAU_ENQUIRY__BUREAU_ENQUIRY_REFERENCE_CK'
  BUREAU_ENQUIRY_REFERENCE: 'AUG_RISK_MOTOR_BUREAU_ENQUIRY__BUREAU_ENQUIRY_REFERENCE'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v12_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
