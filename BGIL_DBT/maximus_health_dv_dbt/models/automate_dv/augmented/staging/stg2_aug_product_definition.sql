-- automate_dv.stage() for SAT_AUG_PRODUCT_DEFINITION, read off central view stitch_v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v11_party'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRODUCT_DETAILS_TEXT'
derived_columns:
  PRODUCT_NK: "case when AUG_PRODUCT_DEFINITION__PRODUCT_DETAILS_TEXT is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  PRODUCT_DETAILS_TEXT: 'AUG_PRODUCT_DEFINITION__PRODUCT_DETAILS_TEXT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
