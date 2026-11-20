{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_QUOTE_PROPOSAL: hub keys and the link key, hashed off stitch_travel__lnk_quote_proposal.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_quote_proposal'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  QUOTE_HKEY: 'QUOTE_NK'
  QUOTE_PROPOSAL_HKEY: 'QUOTE_PROPOSAL_NK'
derived_columns:
  PROPOSAL_NK: "'HUB_PROPOSAL|' || PROPOSAL_BK"
  QUOTE_NK: "'HUB_QUOTE|' || QUOTE_BK"
  QUOTE_PROPOSAL_NK: "'LNK_QUOTE_PROPOSAL|' || PROPOSAL_BK || '|' || QUOTE_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
