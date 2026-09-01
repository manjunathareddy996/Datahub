{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL ma_sat() for SAT_FINTXN_TAX (parent HUB_FINANCIAL_TRANSACTION), per data_5b
-- canonical childkey "Tax Type".

-- Round-2: added BJAZ_TRV_LOADER_LOG_TABLE_MV.SERVICETAX via the new degenerate txn key.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_fintxn_tax_ba_trv_data_policy_dtls_mv_0'
  - 'stg2_fintxn_tax_ba_trv_data_policy_dtls_mv_1'
  - 'stg2_fintxn_tax_bjaz_trv_loader_log_table_mv_2'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_cdk:
  - 'TAX_TYPE'
src_payload:
  - 'CESS_AMOUNT'
  - 'SERVICE_TAX_AMOUNT'
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
