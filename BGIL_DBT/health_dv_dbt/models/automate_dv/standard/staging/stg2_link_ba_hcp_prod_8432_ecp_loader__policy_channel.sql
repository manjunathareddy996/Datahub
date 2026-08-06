{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_POLICY_CHANNEL member-end 'ba_hcp_prod_8432_ecp_loader'.
-- DISTRIBUTION_CHANNEL_HKEY is hashed with the EXACT SAME formula ('HUB_DISTRIBUTION_CHANNEL|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for POLICY_HKEY.
-- POLICY_CHANNEL_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8432_ecp_loader'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_HKEY_NK'
  POLICY_HKEY: 'POLICY_HKEY_NK'
  POLICY_CHANNEL_HKEY: 'POLICY_CHANNEL_HKEY_NK'
derived_columns:
  DISTRIBUTION_CHANNEL_HKEY_NK: "'HUB_DISTRIBUTION_CHANNEL|' || pd_partner_id"
  POLICY_HKEY_NK: "'HUB_POLICY|' || pol_serial_no"
  POLICY_CHANNEL_HKEY_NK: "'LNK_POLICY_CHANNEL|' || pd_partner_id || '|' || pol_serial_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8432_ECP_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
