-- automate_dv.stage() for SAT_AUG_PRODUCT_TERMS, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MANDATORY_COVER_LIST'
      - 'MAXIMUM_ENTRY_AGE_UNIT'
      - 'MINIMUM_ENTRY_AGE_UNIT'
derived_columns:
  PRODUCT_NK: "case when coalesce(AUG_PRODUCT_TERMS__MANDATORY_COVER_LIST, AUG_PRODUCT_TERMS__MAXIMUM_ENTRY_AGE_UNIT, AUG_PRODUCT_TERMS__MINIMUM_ENTRY_AGE_UNIT) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  MANDATORY_COVER_LIST: 'AUG_PRODUCT_TERMS__MANDATORY_COVER_LIST'
  MAXIMUM_ENTRY_AGE_UNIT: 'AUG_PRODUCT_TERMS__MAXIMUM_ENTRY_AGE_UNIT'
  MINIMUM_ENTRY_AGE_UNIT: 'AUG_PRODUCT_TERMS__MINIMUM_ENTRY_AGE_UNIT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
