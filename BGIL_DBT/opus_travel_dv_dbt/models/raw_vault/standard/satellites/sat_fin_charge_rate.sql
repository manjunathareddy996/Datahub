{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL ma_sat() for SAT_FIN_CHARGE_RATE (parent HUB_FINANCIAL_TRANSACTION).
-- Round-2: added BJAZ_TRV_LOADER_LOG_TABLE via the new degenerate transaction key.
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): converted sat() -> ma_sat(), child
-- key CHARGE_TYPE_CK. BA_TRV_DATA_POLICY_DTLS split into two branches (service charge
-- vs. additional loading were previously forced onto one row -- see its stage file header).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_fin_charge_rate_ba_trv_data_policy_dtls'
  - 'stg2_fin_charge_rate_ba_trv_data_policy_dtls_loading'
  - 'stg2_fin_charge_rate_bjaz_trv_loader_log_table'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_cdk:
  - 'CHARGE_TYPE_CK'
src_payload:
  - 'ADDITIONAL_LOADING_RATE'
  - 'CHARGE_AMOUNT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_fin_charge_rate_ba_trv_data_policy_dtls: 'OPUS'
  stg2_fin_charge_rate_ba_trv_data_policy_dtls_loading: 'OPUS'
  stg2_fin_charge_rate_bjaz_trv_loader_log_table: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ ma_sat_multi_source(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model'],
                       src_record_source_map=metadata_dict['src_record_source_map']) }}
