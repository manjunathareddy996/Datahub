{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS (parent HUB_PARTY).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_party_individual_demographics_bjaz_trv_loader_data_mv_payer'
  - 'stg2_party_individual_demographics_bjaz_trv_loader_log_table_mv_payer'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'MARITAL_STATUS'
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
