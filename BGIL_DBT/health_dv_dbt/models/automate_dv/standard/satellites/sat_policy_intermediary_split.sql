{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_POLICY_INTERMEDIARY_SPLIT (HUB_POLICY grain) -- single contributing table.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_generic_loader_log_table__policy_intermediary_split'
src_pk: 'POLICY_HK'
src_cdk:
  - 'INTERMEDIARY_REFERENCE_CK'
src_payload:
  - 'INTERMEDIARY_REFERENCE'
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
