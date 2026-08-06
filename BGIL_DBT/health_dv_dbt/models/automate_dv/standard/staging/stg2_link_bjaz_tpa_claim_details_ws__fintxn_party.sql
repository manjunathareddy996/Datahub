{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_FINTXN_PARTY member-end 'bjaz_tpa_claim_details_ws'.
-- FINANCIAL_TRANSACTION_HKEY is hashed with the EXACT SAME formula ('HUB_FINANCIAL_TRANSACTION|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PARTY_HKEY.
-- FINTXN_PARTY_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_HKEY_NK'
  PARTY_HKEY: 'PARTY_HKEY_NK'
  FINTXN_PARTY_HKEY: 'FINTXN_PARTY_HKEY_NK'
derived_columns:
  FINANCIAL_TRANSACTION_HKEY_NK: "'HUB_FINANCIAL_TRANSACTION|' || tpa_trans_key"
  PARTY_HKEY_NK: "'HUB_PARTY|' || customer_id"
  FINTXN_PARTY_HKEY_NK: "'LNK_FINTXN_PARTY|' || tpa_trans_key || '|' || customer_id"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
