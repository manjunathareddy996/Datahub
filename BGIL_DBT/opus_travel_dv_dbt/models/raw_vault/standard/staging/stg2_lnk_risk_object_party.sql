{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_RISK_OBJECT_PARTY: hub keys and the link key, hashed off stitch_travel__lnk_risk_object_party.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_risk_object_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  RISK_OBJECT_PARTY_HKEY: 'RISK_OBJECT_PARTY_NK'
derived_columns:
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  RISK_OBJECT_PARTY_NK: "'LNK_RISK_OBJECT_PARTY|' || PARTY_BK || '|' || RISK_OBJECT_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
