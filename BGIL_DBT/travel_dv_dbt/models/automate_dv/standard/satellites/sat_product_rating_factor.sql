{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL ma_sat() for SAT_PRODUCT_RATING_FACTOR (parent HUB_PRODUCT), per data_5b
-- canonical childkey "Active Sequence Number".

{%- set yaml_metadata -%}
source_model:
  - 'stg2_product_rating_factor_bjaz_trv_rate_master_mv_0'
  - 'stg2_product_rating_factor_bjaz_trv_rate_master_mv_1'
  - 'stg2_product_rating_factor_bjaz_trv_rate_master_mv_2'
  - 'stg2_product_rating_factor_bjaz_trv_rate_master_mv_3'
src_pk: 'PRODUCT_HKEY'
src_cdk:
  - 'ACTIVE_SEQUENCE_NUMBER'
src_payload:
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
