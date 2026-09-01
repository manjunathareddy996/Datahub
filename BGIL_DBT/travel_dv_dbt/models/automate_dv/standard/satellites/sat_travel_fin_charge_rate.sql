{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL ma_sat() for SAT_FIN_CHARGE_RATE (parent HUB_FINANCIAL_TRANSACTION).
-- Round-2: added BJAZ_TRV_LOADER_LOG_TABLE_MV via the new degenerate transaction key.
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): converted sat() -> ma_sat(), child
-- key CHARGE_TYPE_CK. BA_TRV_DATA_POLICY_DTLS_MV split into two branches (service charge
-- vs. additional loading were previously forced onto one row -- see its stage file header).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_fin_charge_rate_ba_trv_data_policy_dtls_mv'
  - 'stg2_fin_charge_rate_ba_trv_data_policy_dtls_mv_loading'
  - 'stg2_fin_charge_rate_bjaz_trv_loader_log_table_mv'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_cdk:
  - 'CHARGE_TYPE_CK'
src_payload:
  - 'ADDITIONAL_LOADING_RATE'
  - 'CHARGE_AMOUNT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model']) }}
