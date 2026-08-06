{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_CLAIM_POLICY member-end 'bjaz_tpa_claim_details_ws'.
-- CLAIM_HKEY is hashed with the EXACT SAME formula ('HUB_CLAIM|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for POLICY_HKEY.
-- CLAIM_POLICY_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_HKEY_NK'
  POLICY_HKEY: 'POLICY_HKEY_NK'
  CLAIM_POLICY_HKEY: 'CLAIM_POLICY_HKEY_NK'
derived_columns:
  CLAIM_HKEY_NK: "'HUB_CLAIM|' || bjaz_claim_id"
  POLICY_HKEY_NK: "'HUB_POLICY|' || policy_no"
  CLAIM_POLICY_HKEY_NK: "'LNK_CLAIM_POLICY|' || bjaz_claim_id || '|' || policy_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
