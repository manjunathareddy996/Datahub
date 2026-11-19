-- automate_dv.stage() for SAT_POLICY_TAX_HEAD, read off central view stitch_motor__v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v16_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TAX_AMOUNT'
      - 'TAX_COMPONENT'
      - 'TAX_HEAD_CODE'
      - 'TAX_HEAD_NAME'
      - 'TAX_HEAD_CODE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_TAX_HEAD__TAX_AMOUNT, POLICY_TAX_HEAD__TAX_COMPONENT, POLICY_TAX_HEAD__TAX_HEAD_CODE, POLICY_TAX_HEAD__TAX_HEAD_NAME) is not null then 'HUB_POLICY|' || POLICY_BK end"
  TAX_HEAD_CODE_CK: 'POLICY_TAX_HEAD__TAX_HEAD_CODE_CK'
  TAX_AMOUNT: 'POLICY_TAX_HEAD__TAX_AMOUNT'
  TAX_COMPONENT: 'POLICY_TAX_HEAD__TAX_COMPONENT'
  TAX_HEAD_CODE: 'POLICY_TAX_HEAD__TAX_HEAD_CODE'
  TAX_HEAD_NAME: 'POLICY_TAX_HEAD__TAX_HEAD_NAME'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_MOTOR_V16_POLICY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
