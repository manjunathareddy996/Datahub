-- Standard ma_sat() for SAT_FINTXN_TAX (parent HUB_FINANCIAL_TRANSACTION, history Multi-Active SCD2), fed whole from central view stitch_v26_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_fintxn_tax'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_cdk:
  - 'TAX_TYPE_CK'
src_payload:
  - 'CGST_AMOUNT'
  - 'IGST_AMOUNT'
  - 'SERVICE_TAX_AMOUNT'
  - 'SERVICE_TAX_RATE'
  - 'SERVICE_TAX_REGISTRATION_NUMBER'
  - 'SGST_AMOUNT'
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
