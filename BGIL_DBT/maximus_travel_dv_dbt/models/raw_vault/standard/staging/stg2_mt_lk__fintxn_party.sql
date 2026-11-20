{{ config(materialized='view') }}
-- stage() for LNK_FINTXN_PARTY: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_fintxn_party.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_fintxn_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  PARTY_HKEY: 'PARTY_NK'
  FINTXN_PARTY_HKEY: 'FINTXN_PARTY_NK'
derived_columns:
  FINTXN_PARTY_NK: "'LNK_FINTXN_PARTY|' || FINANCIAL_TRANSACTION_BK || '|' || PARTY_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
