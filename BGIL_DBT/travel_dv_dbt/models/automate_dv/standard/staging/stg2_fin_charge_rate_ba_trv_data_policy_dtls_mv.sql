{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_FIN_CHARGE_RATE, table 'BA_TRV_DATA_POLICY_DTLS_MV'.
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): this table previously forced two
-- genuinely different charge concepts (LOADING_PER, an additional loading rate, and
-- SERVICE_CHARGE, a service charge amount) onto one row -- same shape as the collision the
-- note flagged for Health's SAT_POLICY_PREMIUM_HEAD. Split: this branch now carries only
-- the service charge; the loading rate moved to a second branch
-- (stg2_fin_charge_rate_ba_trv_data_policy_dtls_mv_loading.sql).

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls_mv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHARGE_AMOUNT'
derived_columns:
  PARENT_BK: 'transaction_id'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (transaction_id)"
  CHARGE_TYPE_CK: '!Service Charge'
  CHARGE_AMOUNT: 'service_charge'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BA_TRV_DATA_POLICY_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
