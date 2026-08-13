{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_PARTY_PAYMENT_INSTRUMENT member-end 'bjaz_tpa_claim_details_ws'.
-- PARTY_HKEY is hashed with the EXACT SAME formula ('HUB_PARTY|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PAYMENT_INSTRUMENT_HKEY.
-- PARTY_PAYMENT_INSTRUMENT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  PAYMENT_INSTRUMENT_HKEY: 'PAYMENT_INSTRUMENT_HKEY_NK'
  PARTY_PAYMENT_INSTRUMENT_HKEY: 'PARTY_PAYMENT_INSTRUMENT_HKEY_NK'
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || customer_id"
  PAYMENT_INSTRUMENT_HKEY_NK: "'HUB_PAYMENT_INSTRUMENT|' || cheque_no"
  PARTY_PAYMENT_INSTRUMENT_HKEY_NK: "'LNK_PARTY_PAYMENT_INSTRUMENT|' || customer_id || '|' || cheque_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
