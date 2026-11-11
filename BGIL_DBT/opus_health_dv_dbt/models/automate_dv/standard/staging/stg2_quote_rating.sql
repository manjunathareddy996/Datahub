-- automate_dv.stage() for SAT_QUOTE_RATING, read off central view stitch_v31_product.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v31_product'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISCOUNT_AMOUNT'
      - 'GROSS_PREMIUM'
      - 'TOTAL_ANNUAL_PREMIUM'
derived_columns:
  QUOTE_NK: "case when coalesce(QUOTE_RATING__DISCOUNT_AMOUNT, QUOTE_RATING__GROSS_PREMIUM, QUOTE_RATING__TOTAL_ANNUAL_PREMIUM) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  DISCOUNT_AMOUNT: 'QUOTE_RATING__DISCOUNT_AMOUNT'
  GROSS_PREMIUM: 'QUOTE_RATING__GROSS_PREMIUM'
  TOTAL_ANNUAL_PREMIUM: 'QUOTE_RATING__TOTAL_ANNUAL_PREMIUM'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v31_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
