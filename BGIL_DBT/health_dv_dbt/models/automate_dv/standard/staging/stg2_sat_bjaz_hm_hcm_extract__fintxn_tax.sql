{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_FINTXN_TAX, table 'BJAZ_HM_HCM_EXTRACT' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hcm_extract'
hashed_columns:
  FINANCIAL_TRANSACTION_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SERVICE_TAX_AMOUNT'
      - 'SERVICE_TAX_RATE'
      - 'TDS_RATE'
derived_columns:
  PARENT_BK: "nullif(trim(to_varchar(claim_no)), '') || '|' || nullif(trim(to_varchar(utr_no)), '')"
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (nullif(trim(to_varchar(claim_no)), '') || '|' || nullif(trim(to_varchar(utr_no)), ''))"
  TAX_TYPE_CK: '!'
  SERVICE_TAX_AMOUNT: 'service_tax_amount'
  SERVICE_TAX_RATE: 'service_tax_rate'
  TDS_RATE: 'tds_rate'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HCM_EXTRACT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
