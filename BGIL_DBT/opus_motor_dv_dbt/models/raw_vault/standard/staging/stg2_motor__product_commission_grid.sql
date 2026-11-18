-- automate_dv.stage() for SAT_PRODUCT_COMMISSION_GRID, read off central view stitch_motor__v20_product.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v20_product'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EFFECTIVE_DATE'
      - 'MAXIMUM_PAYABLE_PERCENTAGE'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
derived_columns:
  PRODUCT_NK: "case when coalesce(PRODUCT_COMMISSION_GRID__EFFECTIVE_DATE, PRODUCT_COMMISSION_GRID__MAXIMUM_PAYABLE_PERCENTAGE) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK'
  EFFECTIVE_DATE: 'PRODUCT_COMMISSION_GRID__EFFECTIVE_DATE'
  MAXIMUM_PAYABLE_PERCENTAGE: 'PRODUCT_COMMISSION_GRID__MAXIMUM_PAYABLE_PERCENTAGE'
  LOAD_DATETIME: 'PRODUCT_COMMISSION_GRID__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v20_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
