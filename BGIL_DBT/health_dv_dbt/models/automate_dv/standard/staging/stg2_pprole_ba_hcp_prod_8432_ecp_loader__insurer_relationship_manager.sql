{{ config(materialized='view') }}

-- STANDARD-MODEL per-branch stage() for SAT_LNK_POLICY_PARTY_ROLE (data_5a.js M2),
-- branch 'BA_HCP_PROD_8432_ECP_LOADER::insurer-relationship-manager', role = 'insurer-relationship-manager'.
-- PARTY_HKEY/POLICY_HKEY/POLICY_PARTY_HKEY reuse the EXACT SAME formula as
-- stg2_link_ba_hcp_prod_8432_ecp_loader__policy_party.sql -- guaranteed to match a real
-- LNK_POLICY_PARTY row, not independently re-derived.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8432_ecp_loader'
hashed_columns:
  POLICY_PARTY_HKEY: 'POLICY_PARTY_HKEY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PARTY_ROLE_TYPE'
derived_columns:
  POLICY_PARTY_HKEY_NK: "'LNK_POLICY_PARTY|' || pd_premium_payer_id || '|' || pol_serial_no"
  PARTY_ROLE_TYPE: '!insurer-relationship-manager'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8432_ECP_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
