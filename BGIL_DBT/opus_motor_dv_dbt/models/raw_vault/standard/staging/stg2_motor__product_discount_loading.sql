-- automate_dv.stage() for SAT_PRODUCT_DISCOUNT_LOADING, read off central view stitch_motor__v20_product.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v20_product'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISCOUNT_PERCENTAGE'
      - 'RULE_CODE'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
derived_columns:
  PRODUCT_NK: "case when coalesce(PRODUCT_DISCOUNT_LOADING__DISCOUNT_PERCENTAGE, PRODUCT_DISCOUNT_LOADING__RULE_CODE) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'PRODUCT_DISCOUNT_LOADING__ACTIVE_SEQUENCE_NUMBER_CK'
  DISCOUNT_PERCENTAGE: 'PRODUCT_DISCOUNT_LOADING__DISCOUNT_PERCENTAGE'
  RULE_CODE: 'PRODUCT_DISCOUNT_LOADING__RULE_CODE'
  LOAD_DATETIME: 'PRODUCT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v20_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
