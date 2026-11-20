{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_AGREEMENT_PARTY: hub keys and the link key, hashed off stitch_travel__lnk_agreement_party.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_agreement_party'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_NK'
  PARTY_HKEY: 'PARTY_NK'
  AGREEMENT_PARTY_HKEY: 'AGREEMENT_PARTY_NK'
derived_columns:
  AGREEMENT_NK: "'HUB_AGREEMENT|' || AGREEMENT_BK"
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  AGREEMENT_PARTY_NK: "'LNK_AGREEMENT_PARTY|' || AGREEMENT_BK || '|' || PARTY_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
