-- automate_dv.stage() for SAT_MOTOR_AUG_QUOTE_DISCOUNT_LOADING_APPLIED, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AMOUNT_APPLIED'
      - 'COMMISSION_DISCOUNT_AMOUNT'
      - 'EXTRA_DISCOUNT_OPTED_INDICATOR'
      - 'PERCENTAGE_APPLIED'
      - 'RATING_FACTOR_VALUE'
      - 'ITEM_CODE_CK'
derived_columns:
  QUOTE_NK: "case when coalesce(AUG_QUOTE_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED, AUG_QUOTE_DISCOUNT_LOADING_APPLIED__COMMISSION_DISCOUNT_AMOUNT, AUG_QUOTE_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR, AUG_QUOTE_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED, AUG_QUOTE_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  ITEM_CODE_CK: 'AUG_QUOTE_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK'
  AMOUNT_APPLIED: 'AUG_QUOTE_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED'
  COMMISSION_DISCOUNT_AMOUNT: 'AUG_QUOTE_DISCOUNT_LOADING_APPLIED__COMMISSION_DISCOUNT_AMOUNT'
  EXTRA_DISCOUNT_OPTED_INDICATOR: 'AUG_QUOTE_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR'
  PERCENTAGE_APPLIED: 'AUG_QUOTE_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED'
  RATING_FACTOR_VALUE: 'AUG_QUOTE_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE'
  LOAD_DATETIME: 'QUOTE_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v01_assessment'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
