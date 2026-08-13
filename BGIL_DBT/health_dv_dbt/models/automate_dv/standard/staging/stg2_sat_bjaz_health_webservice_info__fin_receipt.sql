{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_FIN_RECEIPT, table 'BJAZ_HEALTH_WEBSERVICE_INFO' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_health_webservice_info'
hashed_columns:
  FINANCIAL_TRANSACTION_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BANK_REFERENCE'
      - 'CHEQUE_TYPE'
      - 'RECEIPT_NUMBER'
derived_columns:
  PARENT_BK: 'ptransaction_id'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (ptransaction_id)"
  BANK_REFERENCE: 'advice_no'
  CHEQUE_TYPE: 'cheque_type'
  RECEIPT_NUMBER: 'receipt_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HEALTH_WEBSERVICE_INFO'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
