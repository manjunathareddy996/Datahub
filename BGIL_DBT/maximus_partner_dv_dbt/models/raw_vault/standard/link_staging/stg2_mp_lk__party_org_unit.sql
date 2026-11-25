{{ config(materialized='view', tags=['lnk_extra']) }}
-- stage() for LNK_PARTY_ORG_UNIT: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mp_party_org_unit.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mp_party_org_unit'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  PARTY_ORG_UNIT_HKEY: 'PARTY_ORG_UNIT_NK'
derived_columns:
  PARTY_ORG_UNIT_NK: "'LNK_PARTY_ORG_UNIT|' || PARTY_BK || '|' || ORG_UNIT_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
