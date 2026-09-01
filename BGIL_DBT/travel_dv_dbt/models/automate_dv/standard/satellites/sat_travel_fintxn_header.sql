{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_FINTXN_HEADER (parent HUB_FINANCIAL_TRANSACTION).
-- New in round 2 -- previously unbuildable (its one contributing table,
-- BJAZ_TRV_LOADER_LOG_TABLE_MV, had no transaction key until the degenerate key was added).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_fintxn_header_bjaz_trv_loader_log_table_mv'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_payload:
  - 'GROSS_AMOUNT'
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
