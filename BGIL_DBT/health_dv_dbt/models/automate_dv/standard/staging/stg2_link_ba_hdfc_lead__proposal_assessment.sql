{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_PROPOSAL_ASSESSMENT member-end 'ba_hdfc_lead'.
-- ASSESSMENT_HKEY is hashed with the EXACT SAME formula ('HUB_ASSESSMENT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PROPOSAL_HKEY.
-- PROPOSAL_ASSESSMENT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hdfc_lead'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_HKEY_NK'
  PROPOSAL_HKEY: 'PROPOSAL_HKEY_NK'
  PROPOSAL_ASSESSMENT_HKEY: 'PROPOSAL_ASSESSMENT_HKEY_NK'
derived_columns:
  ASSESSMENT_HKEY_NK: "'HUB_ASSESSMENT|' || scrutiny_no"
  PROPOSAL_HKEY_NK: "'HUB_PROPOSAL|' || ba_lead_no"
  PROPOSAL_ASSESSMENT_HKEY_NK: "'LNK_PROPOSAL_ASSESSMENT|' || scrutiny_no || '|' || ba_lead_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HDFC_LEAD'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
