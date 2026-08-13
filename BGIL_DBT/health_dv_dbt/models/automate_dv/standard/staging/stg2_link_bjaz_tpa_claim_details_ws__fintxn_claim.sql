{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_FINTXN_CLAIM member-end 'bjaz_tpa_claim_details_ws'.
-- CLAIM_HKEY is hashed with the EXACT SAME formula ('HUB_CLAIM|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for FINANCIAL_TRANSACTION_HKEY.
-- FINTXN_CLAIM_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_HKEY_NK'
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_HKEY_NK'
  FINTXN_CLAIM_HKEY: 'FINTXN_CLAIM_HKEY_NK'
derived_columns:
  CLAIM_HKEY_NK: "'HUB_CLAIM|' || bjaz_claim_id"
  FINANCIAL_TRANSACTION_HKEY_NK: "'HUB_FINANCIAL_TRANSACTION|' || tpa_trans_key"
  FINTXN_CLAIM_HKEY_NK: "'LNK_FINTXN_CLAIM|' || bjaz_claim_id || '|' || tpa_trans_key"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
