{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL ma_sat() for SAT_FINTXN_COMMISSION (parent HUB_FINANCIAL_TRANSACTION).
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): converted sat() -> ma_sat(),
-- child key COMMISSION_TYPE_CK, per data_7's Phase 7 grain change for this satellite.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_fintxn_commission_ba_trv_data_policy_dtls_mv'
  - 'stg2_fintxn_commission_bjaz_trv_loader_data_mv'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_cdk:
  - 'COMMISSION_TYPE_CK'
src_payload:
  - 'COMMISSION_AMOUNT'
  - 'COMMISSION_RATE'
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
