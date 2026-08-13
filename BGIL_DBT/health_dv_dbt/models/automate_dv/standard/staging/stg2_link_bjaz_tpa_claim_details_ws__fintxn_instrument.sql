{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_FINTXN_INSTRUMENT member-end 'bjaz_tpa_claim_details_ws'.
-- FINANCIAL_TRANSACTION_HKEY is hashed with the EXACT SAME formula ('HUB_FINANCIAL_TRANSACTION|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PAYMENT_INSTRUMENT_HKEY.
-- FINTXN_INSTRUMENT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_HKEY_NK'
  PAYMENT_INSTRUMENT_HKEY: 'PAYMENT_INSTRUMENT_HKEY_NK'
  FINTXN_INSTRUMENT_HKEY: 'FINTXN_INSTRUMENT_HKEY_NK'
derived_columns:
  FINANCIAL_TRANSACTION_HKEY_NK: "'HUB_FINANCIAL_TRANSACTION|' || tpa_trans_key"
  PAYMENT_INSTRUMENT_HKEY_NK: "'HUB_PAYMENT_INSTRUMENT|' || cheque_no"
  FINTXN_INSTRUMENT_HKEY_NK: "'LNK_FINTXN_INSTRUMENT|' || tpa_trans_key || '|' || cheque_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
