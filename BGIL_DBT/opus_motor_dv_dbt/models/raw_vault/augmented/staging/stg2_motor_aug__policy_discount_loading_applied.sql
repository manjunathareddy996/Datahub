-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_DISCOUNT_LOADING_APPLIED, read off central view stitch_motor__v13_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v13_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BASIS_AMOUNT'
      - 'ITEM_APPLIED_INDICATOR'
      - 'RATING_FACTOR_VALUE'
      - 'ITEM_CODE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_DISCOUNT_LOADING_APPLIED__BASIS_AMOUNT, AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR, AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  ITEM_CODE_CK: 'AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK'
  BASIS_AMOUNT: 'AUG_POLICY_DISCOUNT_LOADING_APPLIED__BASIS_AMOUNT'
  ITEM_APPLIED_INDICATOR: 'AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR'
  RATING_FACTOR_VALUE: 'AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v13_policy'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
