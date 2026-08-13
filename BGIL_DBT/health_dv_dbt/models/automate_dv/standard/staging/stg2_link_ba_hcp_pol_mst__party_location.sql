{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_PARTY_LOCATION member-end 'ba_hcp_pol_mst'.
-- LOCATION_HKEY is hashed with the EXACT SAME formula ('HUB_LOCATION|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PARTY_HKEY.
-- PARTY_LOCATION_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_pol_mst'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_HKEY_NK'
  PARTY_HKEY: 'PARTY_HKEY_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_HKEY_NK'
derived_columns:
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || child_loc_code"
  PARTY_HKEY_NK: "'HUB_PARTY|' || user_id"
  PARTY_LOCATION_HKEY_NK: "'LNK_PARTY_LOCATION|' || child_loc_code || '|' || user_id"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_POL_MST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
