-- automate_dv.stage() for SAT_PRODUCT_VERSION, read off central view stitch_v31_product.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v31_product'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'VERSION_EFFECTIVE_DATE'
      - 'VERSION_NUMBER'
derived_columns:
  PRODUCT_NK: "case when coalesce(PRODUCT_VERSION__VERSION_EFFECTIVE_DATE, PRODUCT_VERSION__VERSION_NUMBER) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  VERSION_EFFECTIVE_DATE: 'PRODUCT_VERSION__VERSION_EFFECTIVE_DATE'
  VERSION_NUMBER: 'PRODUCT_VERSION__VERSION_NUMBER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v31_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
