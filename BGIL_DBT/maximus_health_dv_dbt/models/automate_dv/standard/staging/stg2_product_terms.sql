-- automate_dv.stage() for SAT_PRODUCT_TERMS, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MAXIMUM_ENTRY_AGE'
      - 'MINIMUM_ENTRY_AGE'
derived_columns:
  PRODUCT_NK: "case when coalesce(PRODUCT_TERMS__MAXIMUM_ENTRY_AGE, PRODUCT_TERMS__MINIMUM_ENTRY_AGE) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  MAXIMUM_ENTRY_AGE: 'PRODUCT_TERMS__MAXIMUM_ENTRY_AGE'
  MINIMUM_ENTRY_AGE: 'PRODUCT_TERMS__MINIMUM_ENTRY_AGE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
