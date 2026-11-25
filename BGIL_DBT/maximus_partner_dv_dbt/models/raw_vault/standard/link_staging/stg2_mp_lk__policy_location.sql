{{ config(materialized='view', tags=['lnk_extra']) }}
-- stage() for LNK_POLICY_LOCATION: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mp_policy_location.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mp_policy_location'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  LOCATION_HKEY: 'LOCATION_NK'
  POLICY_LOCATION_HKEY: 'POLICY_LOCATION_NK'
derived_columns:
  POLICY_LOCATION_NK: "'LNK_POLICY_LOCATION|' || POLICY_BK || '|' || LOCATION_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
