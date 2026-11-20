-- Standard sat() for SAT_FINTXN_HEADER (parent HUB_FINANCIAL_TRANSACTION, history SCD2), fed whole from central view stitch_mxm__v07_financial_transaction.
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | SAT_FINTXN_HEADER | Tax Amount | claim-payment: emits TAX_AMOUNT; withheld TAX_AMT
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__fintxn_header'
src_pk:
  - 'FINANCIAL_TRANSACTION_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'APPROVAL_STATUS'
  - 'GROSS_AMOUNT'
  - 'NARRATION'
  - 'SOURCE_REFERENCE_NUMBER'
  - 'SOURCE_REFERENCE_TYPE'
  - 'TAX_AMOUNT'
  - 'TRANSACTION_DATE'
  - 'TRANSACTION_NUMBER'
  - 'TRANSACTION_STATUS'
  - 'TRANSACTION_SUB_TYPE'
  - 'TRANSACTION_TYPE'
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
