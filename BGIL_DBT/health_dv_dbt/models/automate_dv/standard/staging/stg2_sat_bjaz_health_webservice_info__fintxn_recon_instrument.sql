{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_FINTXN_RECON_INSTRUMENT, table 'BJAZ_HEALTH_WEBSERVICE_INFO' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_health_webservice_info'
hashed_columns:
  FINANCIAL_TRANSACTION_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INSTRUMENT_AMOUNT'
      - 'INSTRUMENT_DATE'
      - 'INSTRUMENT_REFERENCE'
derived_columns:
  PARENT_BK: 'ptransaction_id'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (ptransaction_id)"
  INSTRUMENT_SEQUENCE_CK: '!'
  INSTRUMENT_AMOUNT: 'instrument_amt'
  INSTRUMENT_DATE: 'instr_date'
  INSTRUMENT_REFERENCE: 'instr_number'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HEALTH_WEBSERVICE_INFO'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
