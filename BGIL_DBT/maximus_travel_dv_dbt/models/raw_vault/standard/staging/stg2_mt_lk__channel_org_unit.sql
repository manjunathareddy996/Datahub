{{ config(materialized='view') }}
-- stage() for LNK_CHANNEL_ORG_UNIT: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_channel_org_unit.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_channel_org_unit'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  CHANNEL_ORG_UNIT_HKEY: 'CHANNEL_ORG_UNIT_NK'
derived_columns:
  CHANNEL_ORG_UNIT_NK: "'LNK_CHANNEL_ORG_UNIT|' || DISTRIBUTION_CHANNEL_BK || '|' || ORG_UNIT_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
