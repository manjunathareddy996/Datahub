-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_SUM_INSURED_BREAKUP, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SUM_INSURED_CURRENCY_CODE'
      - 'SUM_INSURED_CURRENCY_EXCHANGE_RATE'
      - 'SUM_INSURED_HEAD_CK'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_CODE, AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_EXCHANGE_RATE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  SUM_INSURED_HEAD_CK: 'AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK'
  SUM_INSURED_CURRENCY_CODE: 'AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_CODE'
  SUM_INSURED_CURRENCY_EXCHANGE_RATE: 'AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_EXCHANGE_RATE'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v12_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
