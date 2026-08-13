{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stage() pass for stitch_product_definition -- serves SAT_PRODUCT_DEFINITION.
-- PRODUCT_HKEY hashed once here (namespaced: 'HUB_PRODUCT|' || raw key).

{%- set yaml_metadata -%}
source_model: 'stitch_product_definition'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRODUCTCATEGORY'
      - 'PRODUCTGENERATION'
      - 'PRODUCTNAME'
derived_columns:
  PRODUCT_NK: "'HUB_PRODUCT|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
