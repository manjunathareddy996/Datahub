{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_PARTY_ROLE: hub keys and the link key, hashed off stitch_travel__lnk_party_role.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_party_role'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  PARTY_ROLE_HKEY: 'PARTY_ROLE_NK'
derived_columns:
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  PARTY_ROLE_NK: "'LNK_PARTY_ROLE|' || PARTY_BK || '|' || ROLE_TYPE_CODE"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
