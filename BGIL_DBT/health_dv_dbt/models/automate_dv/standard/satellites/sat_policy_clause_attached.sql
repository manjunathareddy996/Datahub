{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_POLICY_CLAUSE_ATTACHED (HUB_POLICY grain) -- single contributing table.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_grp_hlt_dtls__policy_clause_attached'
src_pk: 'POLICY_HK'
src_cdk:
  - 'CLAUSE_CODE_CK'
src_payload:
  - 'CLAUSE_TITLE'
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
