{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_POLICY_PARTY member-end 'ba_hcp_prod_8428_gpg_loader'.
-- PARTY_HKEY is hashed with the EXACT SAME formula ('HUB_PARTY|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for POLICY_HKEY.
-- POLICY_PARTY_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8428_gpg_loader'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  POLICY_HKEY: 'POLICY_HKEY_NK'
  POLICY_PARTY_HKEY: 'POLICY_PARTY_HKEY_NK'
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || pd_premium_payer_id"
  POLICY_HKEY_NK: "'HUB_POLICY|' || pol_serial_no"
  POLICY_PARTY_HKEY_NK: "'LNK_POLICY_PARTY|' || pd_premium_payer_id || '|' || pol_serial_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8428_GPG_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
