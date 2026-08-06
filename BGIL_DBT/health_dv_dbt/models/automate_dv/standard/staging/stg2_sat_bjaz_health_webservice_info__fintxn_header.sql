{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_FINTXN_HEADER, table 'BJAZ_HEALTH_WEBSERVICE_INFO' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_health_webservice_info'
hashed_columns:
  FINANCIAL_TRANSACTION_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NARRATION'
      - 'ORIGINATING_SYSTEM_REFERENCE'
      - 'SOURCE_REFERENCE_NUMBER'
derived_columns:
  PARENT_BK: 'ptransaction_id'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (ptransaction_id)"
  NARRATION: 'remarks'
  ORIGINATING_SYSTEM_REFERENCE: 'banca_ref_id'
  SOURCE_REFERENCE_NUMBER: 'order_number'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HEALTH_WEBSERVICE_INFO'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
