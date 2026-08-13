{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_FINTXN_TAX, table 'BJAZ_HEALTH_WEBSERVICE_INFO' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_health_webservice_info'
hashed_columns:
  FINANCIAL_TRANSACTION_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CGST_AMOUNT'
      - 'IGST_AMOUNT'
      - 'SERVICE_TAX_AMOUNT'
      - 'SGST_AMOUNT'
derived_columns:
  PARENT_BK: 'ptransaction_id'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (ptransaction_id)"
  TAX_TYPE_CK: '!'
  CGST_AMOUNT: 'central_gst'
  IGST_AMOUNT: 'i_gst'
  SERVICE_TAX_AMOUNT: 'service_tax_amt'
  SGST_AMOUNT: 'state_gst'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HEALTH_WEBSERVICE_INFO'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
