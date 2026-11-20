-- Standard ma_sat() for SAT_FINTXN_TAX (parent HUB_FINANCIAL_TRANSACTION, history Multi-Active SCD2), fed whole from central view stitch_mxm__v07_financial_transaction.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__fintxn_tax'
src_pk:
  - 'FINANCIAL_TRANSACTION_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'TAX_TYPE_CK'
src_payload:
  - 'CGST_AMOUNT'
  - 'IGST_AMOUNT'
  - 'SGST_AMOUNT'
  - 'SGST_RATE'
  - 'TAXABLE_VALUE'
  - 'TAX_APPLICABLE_INDICATOR'
  - 'TAX_INVOICE_DATE'
  - 'TAX_INVOICE_NUMBER'
  - 'TAX_RATE'
  - 'TDS_AMOUNT'
  - 'TDS_RATE'
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
