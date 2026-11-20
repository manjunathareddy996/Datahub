{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_PROPOSAL_ASSESSMENT: hub keys and the link key, hashed off stitch_travel__lnk_proposal_assessment.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_proposal_assessment'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  PROPOSAL_ASSESSMENT_HKEY: 'PROPOSAL_ASSESSMENT_NK'
derived_columns:
  ASSESSMENT_NK: "'HUB_ASSESSMENT|' || ASSESSMENT_BK"
  PROPOSAL_NK: "'HUB_PROPOSAL|' || PROPOSAL_BK"
  PROPOSAL_ASSESSMENT_NK: "'LNK_PROPOSAL_ASSESSMENT|' || ASSESSMENT_BK || '|' || PROPOSAL_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
