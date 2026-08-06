{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_CHANNEL_ORG_UNIT member-end 'ba_hcp_prod_8428_gpg_loader'.
-- DISTRIBUTION_CHANNEL_HKEY is hashed with the EXACT SAME formula ('HUB_DISTRIBUTION_CHANNEL|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for ORG_UNIT_HKEY.
-- CHANNEL_ORG_UNIT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8428_gpg_loader'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_HKEY_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_HKEY_NK'
  CHANNEL_ORG_UNIT_HKEY: 'CHANNEL_ORG_UNIT_HKEY_NK'
derived_columns:
  DISTRIBUTION_CHANNEL_HKEY_NK: "'HUB_DISTRIBUTION_CHANNEL|' || pd_partner_id"
  ORG_UNIT_HKEY_NK: "'HUB_ORG_UNIT|' || pd_location_code"
  CHANNEL_ORG_UNIT_HKEY_NK: "'LNK_CHANNEL_ORG_UNIT|' || pd_partner_id || '|' || pd_location_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8428_GPG_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
