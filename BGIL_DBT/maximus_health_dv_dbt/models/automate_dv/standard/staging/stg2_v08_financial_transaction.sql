-- automate_dv.stage() over central view stitch_v08_financial_transaction: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v08_financial_transaction'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  PAYMENT_INSTRUMENT_HKEY: 'PAYMENT_INSTRUMENT_NK'
  POLICY_HKEY: 'POLICY_NK'
  FINTXN_INSTRUMENT_HKEY: 'FINTXN_INSTRUMENT_NK'
  FINTXN_POLICY_HKEY: 'FINTXN_POLICY_NK'
  POLICY_PAYMENT_INSTRUMENT_HKEY: 'POLICY_PAYMENT_INSTRUMENT_NK'
derived_columns:
  FINANCIAL_TRANSACTION_BK: 'FINANCIAL_TRANSACTION_BK'
  FINANCIAL_TRANSACTION_NK: "'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK"
  PAYMENT_INSTRUMENT_BK: 'PAYMENT_INSTRUMENT_BK'
  PAYMENT_INSTRUMENT_NK: "'HUB_PAYMENT_INSTRUMENT|' || PAYMENT_INSTRUMENT_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  FINTXN_INSTRUMENT_NK: "case when __LNK_FINTXN_INSTRUMENT = 1 then 'LNK_FINTXN_INSTRUMENT|' || FINANCIAL_TRANSACTION_BK || '|' || PAYMENT_INSTRUMENT_BK end"
  FINTXN_POLICY_NK: "case when __LNK_FINTXN_POLICY = 1 then 'LNK_FINTXN_POLICY|' || FINANCIAL_TRANSACTION_BK || '|' || POLICY_BK end"
  POLICY_PAYMENT_INSTRUMENT_NK: "case when __LNK_POLICY_PAYMENT_INSTRUMENT = 1 then 'LNK_POLICY_PAYMENT_INSTRUMENT|' || PAYMENT_INSTRUMENT_BK || '|' || POLICY_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v08_financial_transaction'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
