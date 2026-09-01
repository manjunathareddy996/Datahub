{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL ma_sat() for SAT_POLICY_CLASSIFICATION (parent HUB_POLICY), per data_5b
-- canonical childkey "Classification Type".

{%- set yaml_metadata -%}
source_model:
  - 'stg2_policy_classification_ba_trv_data_policy_dtls_mv_0'
  - 'stg2_policy_classification_ba_trv_data_policy_dtls_mv_1'
  - 'stg2_policy_classification_ba_trv_data_policy_dtls_mv_2'
  - 'stg2_policy_classification_bjaz_trv_loader_data_mv_3'
  - 'stg2_policy_classification_bjaz_trv_loader_log_table_mv_4'
  - 'stg2_policy_classification_bjaz_trv_loader_log_table_mv_5'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'CLASSIFICATION_TYPE'
src_payload:
  - 'CLASSIFICATION_VALUE'
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
