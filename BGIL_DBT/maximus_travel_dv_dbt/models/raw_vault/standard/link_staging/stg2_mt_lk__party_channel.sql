{{ config(materialized='view', tags=['lnk_extra']) }}
-- stage() for LNK_PARTY_CHANNEL: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_party_channel.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_party_channel'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  PARTY_CHANNEL_HKEY: 'PARTY_CHANNEL_NK'
derived_columns:
  PARTY_CHANNEL_NK: "'LNK_PARTY_CHANNEL|' || PARTY_BK || '|' || DISTRIBUTION_CHANNEL_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
