{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_FINANCIAL_TRANSACTION, degenerate branch on
-- 'BJAZ_TRV_LOADER_LOG_TABLE_MV'. Round-2 mapper correction (docs/MAPPER_QUESTIONS_TRAVEL.md /
-- MAPPER_REPLIES_TRAVEL.md, Correction B): this table has no dedicated transaction/receipt
-- ID -- one premium record per policy -- so this mints a degenerate financial-transaction
-- key by reusing POLICYNUMBER (same value as this table's own HUB_POLICY key, re-namespaced
-- 'HUB_FINANCIAL_TRANSACTION|'), the standard degenerate-hub move when there's no separate
-- receipt/transaction id. Same pattern already used for this table's HUB_RISK_OBJECT key.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_log_table_mv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'policynumber'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (policynumber)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_LOG_TABLE_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
