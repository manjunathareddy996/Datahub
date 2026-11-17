-- Standard ma_sat() for SAT_PRODUCT_RATING_FACTOR (parent HUB_PRODUCT, history Multi-Active SCD2), fed whole from central view stitch_motor__v20_product.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__product_rating_factor'
src_pk: 'PRODUCT_HKEY'
src_cdk:
  - 'ACTIVE_SEQUENCE_NUMBER_CK'
src_payload:
  - 'BASE_TARIFF_RATE'
  - 'EFFECTIVE_DATE'
  - 'RATING_FACTOR_CODE'
  - 'VALUE_RANGE_FROM'
  - 'VALUE_RANGE_TO'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
