{{ config(materialized='view', tags=['lnk_extra']) }}
-- stage() for LNK_ORG_UNIT_LOCATION: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mp_org_unit_location.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mp_org_unit_location'
hashed_columns:
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  LOCATION_HKEY: 'LOCATION_NK'
  ORG_UNIT_LOCATION_HKEY: 'ORG_UNIT_LOCATION_NK'
derived_columns:
  ORG_UNIT_LOCATION_NK: "'LNK_ORG_UNIT_LOCATION|' || ORG_UNIT_BK || '|' || LOCATION_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
