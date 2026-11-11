-- automate_dv.stage() for SAT_PRODUCT_TERMS, read off central view stitch_v31_product.
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
      - 'FAMILY_DEFINITION'
      - 'RENEWABILITY_TYPE'
derived_columns:
  PRODUCT_NK: "case when coalesce(PRODUCT_TERMS__FAMILY_DEFINITION, PRODUCT_TERMS__RENEWABILITY_TYPE) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  FAMILY_DEFINITION: 'PRODUCT_TERMS__FAMILY_DEFINITION'
  RENEWABILITY_TYPE: 'PRODUCT_TERMS__RENEWABILITY_TYPE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v31_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
