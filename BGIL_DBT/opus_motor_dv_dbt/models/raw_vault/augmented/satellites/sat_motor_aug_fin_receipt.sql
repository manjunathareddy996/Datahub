-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_FIN_RECEIPT (parent HUB_FINANCIAL_TRANSACTION, history SCD2), fed whole from central view stitch_motor__v06_distribution_channel.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__fin_receipt'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_payload:
  - 'BANK_CHARGES_AMOUNT'
  - 'GATEWAY_RESPONSE_IDENTIFIER'
  - 'GATEWAY_TRACE_NUMBER'
  - 'PAYMENT_RECEIVED_INDICATOR'
  - 'PAYMENT_REQUEST_TIMESTAMP'
  - 'PAYMENT_RESPONSE_TIMESTAMP'
  - 'PAY_IN_SLIP_DATE'
  - 'PAY_IN_SLIP_NUMBER'
  - 'UNIQUE_PAYMENT_REFERENCE_NUMBER'
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
