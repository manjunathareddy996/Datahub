{{ config(materialized='view', tags=['lnk_extra']) }}
-- stage() for LNK_QUOTE_PARTY: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_quote_party.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_quote_party'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  PARTY_HKEY: 'PARTY_NK'
  QUOTE_PARTY_HKEY: 'QUOTE_PARTY_NK'
derived_columns:
  QUOTE_PARTY_NK: "'LNK_QUOTE_PARTY|' || QUOTE_BK || '|' || PARTY_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
