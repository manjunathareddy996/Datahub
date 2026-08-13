{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_PROPOSAL_PRODUCT member-end 'bjaz_pnb_gpa_data'.
-- PRODUCT_HKEY is hashed with the EXACT SAME formula ('HUB_PRODUCT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PROPOSAL_HKEY.
-- PROPOSAL_PRODUCT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_pnb_gpa_data'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_HKEY_NK'
  PROPOSAL_HKEY: 'PROPOSAL_HKEY_NK'
  PROPOSAL_PRODUCT_HKEY: 'PROPOSAL_PRODUCT_HKEY_NK'
derived_columns:
  PRODUCT_HKEY_NK: "'HUB_PRODUCT|' || product_code"
  PROPOSAL_HKEY_NK: "'HUB_PROPOSAL|' || ba_lead_no"
  PROPOSAL_PRODUCT_HKEY_NK: "'LNK_PROPOSAL_PRODUCT|' || product_code || '|' || ba_lead_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_PNB_GPA_DATA'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
