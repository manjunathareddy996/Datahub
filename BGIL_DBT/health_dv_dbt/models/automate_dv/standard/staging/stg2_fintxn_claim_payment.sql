{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_fintxn_claim_payment -- serves SAT_FINTXN_CLAIM_PAYMENT.
-- The ONE place FINANCIAL_TRANSACTION_HK gets hashed for this cluster (namespaced: 'HUB_FINANCIAL_TRANSACTION|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_fintxn_claim_payment'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHEQUE_DATE'
      - 'CHEQUE_DISPATCH_DATE'
      - 'CHEQUE_RECEIVED_DATE'
      - 'NET_PAID_AMOUNT'
      - 'PAYMENT_DATE'
      - 'PAYMENT_MODE'
      - 'PAYMENT_STATUS'
      - 'TDS_ON_CLAIM_AMOUNT'
      - 'UTR_NUMBER'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "'HUB_FINANCIAL_TRANSACTION|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
