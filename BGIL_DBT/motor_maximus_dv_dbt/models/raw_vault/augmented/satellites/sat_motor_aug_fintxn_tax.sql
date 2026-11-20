-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_FINTXN_TAX (parent HUB_FINANCIAL_TRANSACTION, history SCD2), fed whole from central view stitch_mxm__v07_financial_transaction.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__fintxn_tax'
src_pk:
  - 'FINANCIAL_TRANSACTION_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'TAX_TYPE_CK'
src_payload:
  - 'TAX_PAYMENT_CYCLE_REFERENCE_NUMBER'
  - 'TDS_APPLICABILITY_BASIS'
  - 'TDS_CERTIFICATE_REFERENCE'
  - 'TDS_DEMAND_DRAFT_PAYABLE_AT'
  - 'TDS_DEMAND_DRAFT_STATE'
  - 'TDS_NON_DEDUCTION_INDICATOR'
  - 'TDS_NON_DEDUCTION_REASON'
  - 'TDS_ON_INTEREST_AMOUNT'
  - 'TDS_PAYMENT_MODE'
  - 'TDS_PORTAL_PAYMENT_REFERENCE_NUMBER'
  - 'TDS_SEPARATE_CHEQUE_INDICATOR'
  - 'TDS_SEPARATE_PAYMENT_INDICATOR'
  - 'TDS_SOURCE_SYSTEM_REFERENCE_NUMBER'
  - 'TDS_WAIVER_INDICATOR'
  - 'TDS_WAIVER_REASON'
  - 'TOTAL_GST_RATE'
  - 'UTGST_AMOUNT'
  - 'UTGST_RATE'
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
