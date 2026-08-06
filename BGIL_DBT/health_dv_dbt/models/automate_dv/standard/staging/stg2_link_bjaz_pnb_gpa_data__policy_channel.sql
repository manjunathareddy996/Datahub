{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_POLICY_CHANNEL member-end 'bjaz_pnb_gpa_data'.
-- DISTRIBUTION_CHANNEL_HKEY is hashed with the EXACT SAME formula ('HUB_DISTRIBUTION_CHANNEL|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for POLICY_HKEY.
-- POLICY_CHANNEL_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_pnb_gpa_data'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_HKEY_NK'
  POLICY_HKEY: 'POLICY_HKEY_NK'
  POLICY_CHANNEL_HKEY: 'POLICY_CHANNEL_HKEY_NK'
derived_columns:
  DISTRIBUTION_CHANNEL_HKEY_NK: "'HUB_DISTRIBUTION_CHANNEL|' || imd_code"
  POLICY_HKEY_NK: "'HUB_POLICY|' || master_policy_no"
  POLICY_CHANNEL_HKEY_NK: "'LNK_POLICY_CHANNEL|' || imd_code || '|' || master_policy_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_PNB_GPA_DATA'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
