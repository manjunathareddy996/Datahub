{{ config(materialized='view') }}
-- stage() for LNK_RISK_OBJECT_LOCATION: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_risk_object_location.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_risk_object_location'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  LOCATION_HKEY: 'LOCATION_NK'
  RISK_OBJECT_LOCATION_HKEY: 'RISK_OBJECT_LOCATION_NK'
derived_columns:
  RISK_OBJECT_LOCATION_NK: "'LNK_RISK_OBJECT_LOCATION|' || RISK_OBJECT_BK || '|' || LOCATION_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
