-- Standard sat() for SAT_PRODUCT_DEFINITION (parent HUB_PRODUCT, history SCD2), fed whole from central view stitch_v32_product.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_product_definition'
src_pk: 'PRODUCT_HKEY'
src_payload:
  - 'LINE_OF_BUSINESS'
  - 'PRODUCT_CATEGORY'
  - 'PRODUCT_DESCRIPTION'
  - 'PRODUCT_DISPLAY_NAME'
  - 'PRODUCT_NAME'
  - 'PRODUCT_STATUS'
  - 'UIN'
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
