{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_RISK_OBJECT_PARTY member-end 'ba_hcp_prod_8428_gpg_loader'.
-- PARTY_HKEY is hashed with the EXACT SAME formula ('HUB_PARTY|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for RISK_OBJECT_HKEY.
-- RISK_OBJECT_PARTY_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8428_gpg_loader'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_HKEY_NK'
  RISK_OBJECT_PARTY_HKEY: 'RISK_OBJECT_PARTY_HKEY_NK'
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || pd_premium_payer_id"
  RISK_OBJECT_HKEY_NK: "'HUB_RISK_OBJECT|' || md_seq_no"
  RISK_OBJECT_PARTY_HKEY_NK: "'LNK_RISK_OBJECT_PARTY|' || pd_premium_payer_id || '|' || md_seq_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8428_GPG_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
