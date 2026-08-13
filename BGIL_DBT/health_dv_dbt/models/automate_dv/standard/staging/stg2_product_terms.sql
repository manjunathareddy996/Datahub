{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_product_terms -- serves SAT_PRODUCT_TERMS.
-- The ONE place PRODUCT_HK gets hashed for this cluster (namespaced: 'HUB_PRODUCT|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_product_terms'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FAMILY_DEFINITION'
derived_columns:
  PRODUCT_NK: "'HUB_PRODUCT|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
