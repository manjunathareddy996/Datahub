-- automate_dv.stage() for SAT_PRODUCT_DEFINITION, read off central view stitch_v32_product.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v32_product'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LINE_OF_BUSINESS'
      - 'PRODUCT_CATEGORY'
      - 'PRODUCT_DESCRIPTION'
      - 'PRODUCT_DISPLAY_NAME'
      - 'PRODUCT_NAME'
      - 'PRODUCT_STATUS'
      - 'UIN'
derived_columns:
  PRODUCT_NK: "case when coalesce(PRODUCT_DEFINITION__LINE_OF_BUSINESS, PRODUCT_DEFINITION__PRODUCT_CATEGORY, PRODUCT_DEFINITION__PRODUCT_DESCRIPTION, PRODUCT_DEFINITION__PRODUCT_DISPLAY_NAME, PRODUCT_DEFINITION__PRODUCT_NAME, PRODUCT_DEFINITION__PRODUCT_STATUS, PRODUCT_DEFINITION__UIN) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  LINE_OF_BUSINESS: 'PRODUCT_DEFINITION__LINE_OF_BUSINESS'
  PRODUCT_CATEGORY: 'PRODUCT_DEFINITION__PRODUCT_CATEGORY'
  PRODUCT_DESCRIPTION: 'PRODUCT_DEFINITION__PRODUCT_DESCRIPTION'
  PRODUCT_DISPLAY_NAME: 'PRODUCT_DEFINITION__PRODUCT_DISPLAY_NAME'
  PRODUCT_NAME: 'PRODUCT_DEFINITION__PRODUCT_NAME'
  PRODUCT_STATUS: 'PRODUCT_DEFINITION__PRODUCT_STATUS'
  UIN: 'PRODUCT_DEFINITION__UIN'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v32_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
