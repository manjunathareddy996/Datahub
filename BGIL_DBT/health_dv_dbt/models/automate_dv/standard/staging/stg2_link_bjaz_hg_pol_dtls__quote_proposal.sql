{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_QUOTE_PROPOSAL member-end 'bjaz_hg_pol_dtls'.
-- PROPOSAL_HKEY is hashed with the EXACT SAME formula ('HUB_PROPOSAL|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for QUOTE_HKEY.
-- QUOTE_PROPOSAL_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hg_pol_dtls'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_HKEY_NK'
  QUOTE_HKEY: 'QUOTE_HKEY_NK'
  QUOTE_PROPOSAL_HKEY: 'QUOTE_PROPOSAL_HKEY_NK'
derived_columns:
  PROPOSAL_HKEY_NK: "'HUB_PROPOSAL|' || quote_ref_no"
  QUOTE_HKEY_NK: "'HUB_QUOTE|' || quote_ref_no"
  QUOTE_PROPOSAL_HKEY_NK: "'LNK_QUOTE_PROPOSAL|' || quote_ref_no || '|' || quote_ref_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HG_POL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
