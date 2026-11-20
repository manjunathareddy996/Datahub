{{ config(materialized='view', tags=['lnk_extra']) }}
-- stage() for LNK_CLAIM_LOCATION: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_claim_location.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_claim_location'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  LOCATION_HKEY: 'LOCATION_NK'
  CLAIM_LOCATION_HKEY: 'CLAIM_LOCATION_NK'
derived_columns:
  CLAIM_LOCATION_NK: "'LNK_CLAIM_LOCATION|' || CLAIM_BK || '|' || LOCATION_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
