-- automate_dv.stage() for SAT_PRODUCT_DEFINITION, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRODUCT_CATEGORY'
      - 'PRODUCT_DESCRIPTION'
      - 'PRODUCT_DISPLAY_NAME'
      - 'PRODUCT_NAME'
      - 'PRODUCT_TYPE'
derived_columns:
  PRODUCT_NK: "case when coalesce(PRODUCT_DEFINITION__PRODUCT_CATEGORY, PRODUCT_DEFINITION__PRODUCT_DESCRIPTION, PRODUCT_DEFINITION__PRODUCT_DISPLAY_NAME, PRODUCT_DEFINITION__PRODUCT_NAME, PRODUCT_DEFINITION__PRODUCT_TYPE) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  PRODUCT_CATEGORY: 'PRODUCT_DEFINITION__PRODUCT_CATEGORY'
  PRODUCT_DESCRIPTION: 'PRODUCT_DEFINITION__PRODUCT_DESCRIPTION'
  PRODUCT_DISPLAY_NAME: 'PRODUCT_DEFINITION__PRODUCT_DISPLAY_NAME'
  PRODUCT_NAME: 'PRODUCT_DEFINITION__PRODUCT_NAME'
  PRODUCT_TYPE: 'PRODUCT_DEFINITION__PRODUCT_TYPE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
