{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_POLICY_RENEWAL member-end 'bjaz_grp_hlt_dtls'.
-- POLICY_FROM_HKEY is hashed with the EXACT SAME formula ('HUB_POLICY|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for POLICY_TO_HKEY.
-- POLICY_RENEWAL_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_dtls'
hashed_columns:
  POLICY_FROM_HKEY: 'POLICY_FROM_HKEY_NK'
  POLICY_TO_HKEY: 'POLICY_TO_HKEY_NK'
  POLICY_RENEWAL_HKEY: 'POLICY_RENEWAL_HKEY_NK'
derived_columns:
  POLICY_FROM_HKEY_NK: "'HUB_POLICY|' || policy_no"
  POLICY_TO_HKEY_NK: "'HUB_POLICY|' || prev_pol_ref"
  POLICY_RENEWAL_HKEY_NK: "'LNK_POLICY_RENEWAL|' || policy_no || '|' || prev_pol_ref"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
