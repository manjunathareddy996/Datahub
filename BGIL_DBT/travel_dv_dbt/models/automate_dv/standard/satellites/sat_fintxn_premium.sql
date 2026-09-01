{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_FINTXN_PREMIUM (parent HUB_FINANCIAL_TRANSACTION).
-- Round-2: added BJAZ_TRV_LOADER_LOG_TABLE_MV via the new degenerate transaction key.
-- data_7 sync (MAPPER_NOTE_TRAVEL_DATA7_SYNC.md): DISCOUNT_PERCENTAGE folded in from
-- SAT_AUG_FINTXN_PREMIUM -- see stg2_fintxn_premium_ba_trv_data_policy_dtls_mv.sql's
-- header. Only that one branch populates it; AutomateDV nulls it for the other two
-- source_model entries automatically.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_fintxn_premium_ba_trv_data_policy_dtls_mv'
  - 'stg2_fintxn_premium_bjaz_trv_loader_data_mv'
  - 'stg2_fintxn_premium_bjaz_trv_loader_log_table_mv'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_payload:
  - 'BASE_PREMIUM'
  - 'COLLECTION_MODE'
  - 'DISCOUNT_AMOUNT'
  - 'DISCOUNT_PERCENTAGE'
  - 'GROSS_PREMIUM'
  - 'LOADING_AMOUNT'
  - 'NET_PREMIUM'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
