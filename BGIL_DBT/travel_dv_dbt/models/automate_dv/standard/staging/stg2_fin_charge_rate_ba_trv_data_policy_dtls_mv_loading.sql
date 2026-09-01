{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_FIN_CHARGE_RATE, table
-- 'BA_TRV_DATA_POLICY_DTLS_MV' (loading-rate branch). Cross-LOB rekey
-- (MAPPER_NOTE_MULTIACTIVE_REKEY.md): second branch off this table -- see
-- stg2_fin_charge_rate_ba_trv_data_policy_dtls_mv.sql's header for why this table was
-- split into two charge-type branches (LOADING_PER is a distinct charge concept from
-- SERVICE_CHARGE, not the same charge type).

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls_mv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDITIONAL_LOADING_RATE'
derived_columns:
  PARENT_BK: 'transaction_id'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (transaction_id)"
  CHARGE_TYPE_CK: '!Additional Loading'
  ADDITIONAL_LOADING_RATE: 'loading_per'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BA_TRV_DATA_POLICY_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
