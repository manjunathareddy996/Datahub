{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_FINTXN_TAX, table 'BA_TRV_DATA_POLICY_DTLS_MV', column 'EDU_CESS_AMT' -> Cess Amount [{'TAX_TYPE': 'cess'}].

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls_mv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CESS_AMOUNT'
      - 'TAX_TYPE'
derived_columns:
  PARENT_BK: 'transaction_id'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (transaction_id)"
  TAX_TYPE: '!cess'
  CESS_AMOUNT: 'edu_cess_amt'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_TRV_DATA_POLICY_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
