{{ config(materialized='view') }}

-- UNPIVOT STAGE for SAT_FINTXN_TAX from clm_clmd_clmpay_payp_pv.
-- Hashes once over the fanned-out rows. include_source_columns is FALSE and every
-- column is listed explicitly: a stage that passes its source's columns through makes
-- the satellite's real feeder columns invisible to anything reading the YAML, which is
-- how a set of child keys went missing on an earlier build (BUILD_RULES 6.2).

{%- set yaml_metadata -%}
source_model: 'up_mtv2__clm_clmd_clmpay_payp_pv__sat_fintxn_tax'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT: 'FINANCIAL_TRANSACTION_NK__CLAIM_PAYMENT'
  HASHDIFF_FINTXN_TAX:
    is_hashdiff: true
    columns:
      - 'TAX_TYPE'
      - 'CGST_AMOUNT'
      - 'CGST_RATE'
      - 'IGST_AMOUNT'
      - 'IGST_RATE'
      - 'PLACE_OF_SUPPLY'
      - 'SGST_AMOUNT'
      - 'SGST_RATE'
      - 'TAX_APPLICABLE_INDICATOR'
      - 'TAX_INVOICE_DATE'
      - 'TAX_INVOICE_NUMBER'
      - 'TAX_RATE'
      - 'TDS_AMOUNT'
      - 'TDS_RATE'
derived_columns:
  FINANCIAL_TRANSACTION_NK__CLAIM_PAYMENT: "'HUB_FINANCIAL_TRANSACTION|' || (FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT)"
  FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT: 'FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT'
  TAX_TYPE: 'TAX_TYPE'
  CGST_AMOUNT: 'CGST_AMOUNT'
  CGST_RATE: 'CGST_RATE'
  IGST_AMOUNT: 'IGST_AMOUNT'
  IGST_RATE: 'IGST_RATE'
  PLACE_OF_SUPPLY: 'PLACE_OF_SUPPLY'
  SGST_AMOUNT: 'SGST_AMOUNT'
  SGST_RATE: 'SGST_RATE'
  TAX_APPLICABLE_INDICATOR: 'TAX_APPLICABLE_INDICATOR'
  TAX_INVOICE_DATE: 'TAX_INVOICE_DATE'
  TAX_INVOICE_NUMBER: 'TAX_INVOICE_NUMBER'
  TAX_RATE: 'TAX_RATE'
  TDS_AMOUNT: 'TDS_AMOUNT'
  TDS_RATE: 'TDS_RATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
