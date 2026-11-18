-- automate_dv.stage() for SAT_PRODUCT_UW_RULE, read off central view stitch_motor__v21_product.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v21_product'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACTION'
      - 'AUTHORITY_LEVEL_REQUIRED'
      - 'EFFECTIVE_DATE'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
derived_columns:
  PRODUCT_NK: "case when coalesce(PRODUCT_UW_RULE__ACTION, PRODUCT_UW_RULE__AUTHORITY_LEVEL_REQUIRED, PRODUCT_UW_RULE__EFFECTIVE_DATE) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK'
  ACTION: 'PRODUCT_UW_RULE__ACTION'
  AUTHORITY_LEVEL_REQUIRED: 'PRODUCT_UW_RULE__AUTHORITY_LEVEL_REQUIRED'
  EFFECTIVE_DATE: 'PRODUCT_UW_RULE__EFFECTIVE_DATE'
  LOAD_DATETIME: 'PRODUCT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v21_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
