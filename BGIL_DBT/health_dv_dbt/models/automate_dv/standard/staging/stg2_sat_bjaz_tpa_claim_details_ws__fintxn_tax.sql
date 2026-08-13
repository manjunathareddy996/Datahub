{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_FINTXN_TAX, table 'BJAZ_TPA_CLAIM_DETAILS_WS' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
hashed_columns:
  FINANCIAL_TRANSACTION_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SERVICE_TAX_AMOUNT'
      - 'SERVICE_TAX_REGISTRATION_NUMBER'
derived_columns:
  PARENT_BK: 'tpa_trans_key'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (tpa_trans_key)"
  TAX_TYPE_CK: '!'
  SERVICE_TAX_AMOUNT: 'service_tax_amount'
  SERVICE_TAX_REGISTRATION_NUMBER: 'service_tax_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
