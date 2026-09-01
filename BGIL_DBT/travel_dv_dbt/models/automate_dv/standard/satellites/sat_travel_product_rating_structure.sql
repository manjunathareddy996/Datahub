{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_PRODUCT_RATING_STRUCTURE (parent HUB_PRODUCT).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_product_rating_structure_bjaz_trv_rate_master_mv'
src_pk: 'PRODUCT_HKEY'
src_payload:
  - 'PRICING_EFFECTIVE_DATE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
