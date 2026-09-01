{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_FIN_CHARGE_RATE, table
-- 'BJAZ_TRV_LOADER_LOG_TABLE_MV'. Round-2 fix: reuses the degenerate
-- HUB_FINANCIAL_TRANSACTION key (POLICYNUMBER) -- previously unbuildable, no transaction key
-- at all on this table.
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): data_7 made this satellite
-- multi-active, child key 'Charge Type'. CHARGE_TYPE_CK literal matches the "Service
-- Charge" branch on BA_TRV_DATA_POLICY_DTLS_MV since this is the same charge concept.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_log_table_mv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHARGE_AMOUNT'
derived_columns:
  PARENT_BK: 'policynumber'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (policynumber)"
  CHARGE_TYPE_CK: '!Service Charge'
  CHARGE_AMOUNT: 'servicecharge'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_LOG_TABLE_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
