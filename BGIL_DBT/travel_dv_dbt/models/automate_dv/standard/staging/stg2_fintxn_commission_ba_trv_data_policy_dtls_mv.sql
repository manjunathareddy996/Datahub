{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_FINTXN_COMMISSION, table 'BA_TRV_DATA_POLICY_DTLS_MV'.
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): data_7 made this satellite
-- multi-active, child key 'Commission Type + Intermediary Reference'. No real
-- commission-type discriminator on this table, so COMMISSION_TYPE_CK is a literal.

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls_mv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMMISSION_AMOUNT'
      - 'COMMISSION_RATE'
derived_columns:
  PARENT_BK: 'transaction_id'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (transaction_id)"
  COMMISSION_TYPE_CK: '!Standard'
  COMMISSION_AMOUNT: 'commission_amt'
  COMMISSION_RATE: 'commission_rate'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_TRV_DATA_POLICY_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
