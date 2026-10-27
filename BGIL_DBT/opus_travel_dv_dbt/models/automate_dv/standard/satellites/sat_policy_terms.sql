{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_POLICY_TERMS (parent HUB_POLICY).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_policy_terms_ba_trv_data_policy_dtls_mv'
  - 'stg2_policy_terms_bjaz_trv_loader_log_table_mv'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'SPECIAL_CONDITIONS'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_policy_terms_ba_trv_data_policy_dtls_mv: 'OPUS'
  stg2_policy_terms_bjaz_trv_loader_log_table_mv: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map']) }}
