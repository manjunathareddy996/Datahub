{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_CLAIM_RESERVE (HUB_CLAIM grain) -- single contributing table.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_hm_hcm_extract__claim_reserve'
src_pk: 'CLAIM_HK'
src_cdk:
  - 'RESERVE_HEAD_CK'
src_payload:
  - 'CURRENT_RESERVE_AMOUNT'
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
