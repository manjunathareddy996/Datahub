{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_PROPOSAL_POLICY member-end 'bjaz_gp_hospital_cash'.
-- POLICY_HKEY is hashed with the EXACT SAME formula ('HUB_POLICY|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PROPOSAL_HKEY.
-- PROPOSAL_POLICY_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_gp_hospital_cash'
hashed_columns:
  POLICY_HKEY: 'POLICY_HKEY_NK'
  PROPOSAL_HKEY: 'PROPOSAL_HKEY_NK'
  PROPOSAL_POLICY_HKEY: 'PROPOSAL_POLICY_HKEY_NK'
derived_columns:
  POLICY_HKEY_NK: "'HUB_POLICY|' || master_policy_no"
  PROPOSAL_HKEY_NK: "'HUB_PROPOSAL|' || kgc_proposal_number"
  PROPOSAL_POLICY_HKEY_NK: "'LNK_PROPOSAL_POLICY|' || master_policy_no || '|' || kgc_proposal_number"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GP_HOSPITAL_CASH'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
