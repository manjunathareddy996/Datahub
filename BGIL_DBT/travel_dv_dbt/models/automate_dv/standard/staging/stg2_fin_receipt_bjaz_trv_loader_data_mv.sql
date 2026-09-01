{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_FIN_RECEIPT, table 'BJAZ_TRV_LOADER_DATA_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AMOUNT_RECEIVED'
      - 'INSTRUMENT_DATE'
      - 'RECEIPT_NUMBER'
derived_columns:
  PARENT_BK: 'transactionid'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (transactionid)"
  AMOUNT_RECEIVED: 'caamt'
  INSTRUMENT_DATE: 'cadate'
  RECEIPT_NUMBER: 'receiptno'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
