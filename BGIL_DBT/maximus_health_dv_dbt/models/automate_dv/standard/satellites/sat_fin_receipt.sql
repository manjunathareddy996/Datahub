-- Standard sat() for SAT_FIN_RECEIPT (parent HUB_FINANCIAL_TRANSACTION, history SCD2), fed whole from central view stitch_v09_financial_transaction.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_fin_receipt'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_payload:
  - 'AMOUNT_RECEIVED'
  - 'INSTRUMENT_DATE'
  - 'INSTRUMENT_REFERENCE'
  - 'INSTRUMENT_TYPE'
  - 'PAYER_NAME'
  - 'REALISATION_STATUS'
  - 'RECEIPT_DATE'
  - 'RECEIPT_NUMBER'
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
