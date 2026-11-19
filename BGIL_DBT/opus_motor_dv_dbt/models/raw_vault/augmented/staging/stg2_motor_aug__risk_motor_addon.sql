-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_MOTOR_ADDON, read off central view stitch_motor__v14_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v14_policy'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADD_ON_DISCOUNT_AMOUNT'
      - 'DEVIATED_ADD_ON_PREMIUM'
      - 'ADD_ON_CODE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_MOTOR_ADDON__ADD_ON_DISCOUNT_AMOUNT, AUG_RISK_MOTOR_ADDON__DEVIATED_ADD_ON_PREMIUM) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  ADD_ON_CODE_CK: 'AUG_RISK_MOTOR_ADDON__ADD_ON_CODE_CK'
  ADD_ON_DISCOUNT_AMOUNT: 'AUG_RISK_MOTOR_ADDON__ADD_ON_DISCOUNT_AMOUNT'
  DEVIATED_ADD_ON_PREMIUM: 'AUG_RISK_MOTOR_ADDON__DEVIATED_ADD_ON_PREMIUM'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_MOTOR_V14_POLICY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
