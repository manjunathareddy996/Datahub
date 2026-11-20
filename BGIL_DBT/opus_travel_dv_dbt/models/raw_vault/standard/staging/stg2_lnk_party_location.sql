{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_PARTY_LOCATION: hub keys and the link key, hashed off stitch_travel__lnk_party_location.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_party_location'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  PARTY_HKEY: 'PARTY_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_NK'
derived_columns:
  LOCATION_NK: "'HUB_LOCATION|' || LOCATION_BK"
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  PARTY_LOCATION_NK: "'LNK_PARTY_LOCATION|' || LOCATION_BK || '|' || PARTY_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
