-- automate_dv.stage() for SAT_PRODUCT_RATING_STRUCTURE, read off central view stitch_v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_policy'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RATING_METHODOLOGY'
derived_columns:
  PRODUCT_NK: "case when PRODUCT_RATING_STRUCTURE__RATING_METHODOLOGY is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  RATING_METHODOLOGY: 'PRODUCT_RATING_STRUCTURE__RATING_METHODOLOGY'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
