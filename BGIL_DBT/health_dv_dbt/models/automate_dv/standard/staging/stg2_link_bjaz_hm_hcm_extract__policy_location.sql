{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_POLICY_LOCATION member-end 'bjaz_hm_hcm_extract'.
-- LOCATION_HKEY is hashed with the EXACT SAME formula ('HUB_LOCATION|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for POLICY_HKEY.
-- POLICY_LOCATION_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hcm_extract'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_HKEY_NK'
  POLICY_HKEY: 'POLICY_HKEY_NK'
  POLICY_LOCATION_HKEY: 'POLICY_LOCATION_HKEY_NK'
derived_columns:
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || policy_location"
  POLICY_HKEY_NK: "'HUB_POLICY|' || policy"
  POLICY_LOCATION_HKEY_NK: "'LNK_POLICY_LOCATION|' || policy_location || '|' || policy"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HCM_EXTRACT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
