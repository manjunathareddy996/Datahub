{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_FINTXN_COMMISSION, table 'BJAZ_TRV_LOADER_DATA_MV'.
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): see BA_TRV_DATA_POLICY_DTLS_MV's
-- stage file for the child-key rationale. Literal here too -- no real discriminator.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMMISSION_RATE'
derived_columns:
  PARENT_BK: 'transactionid'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (transactionid)"
  COMMISSION_TYPE_CK: '!Standard'
  COMMISSION_RATE: 'commissionrate'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
