{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_FINTXN_PARTY: hub keys and the link key, hashed off stitch_travel__lnk_fintxn_party.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_fintxn_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  PARTY_HKEY: 'PARTY_NK'
  FINTXN_PARTY_HKEY: 'FINTXN_PARTY_NK'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK"
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  FINTXN_PARTY_NK: "'LNK_FINTXN_PARTY|' || FINANCIAL_TRANSACTION_BK || '|' || PARTY_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
