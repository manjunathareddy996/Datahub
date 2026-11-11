-- Standard sat() for SAT_COMMON_MONETARY_CONTEXT (parent HUB_FINANCIAL_TRANSACTION, history SCD2), fed whole from central view stitch_v09_financial_transaction.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_common_monetary_context'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_payload:
  - 'BASE_CURRENCY_CODE'
  - 'CURRENCY_CODE'
  - 'EXCHANGE_RATE'
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
