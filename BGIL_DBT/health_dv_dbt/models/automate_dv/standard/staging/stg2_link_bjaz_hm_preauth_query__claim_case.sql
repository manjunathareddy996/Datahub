{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_CLAIM_CASE member-end 'bjaz_hm_preauth_query'.
-- CASE_HKEY is hashed with the EXACT SAME formula ('HUB_CASE|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for CLAIM_HKEY.
-- CLAIM_CASE_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_preauth_query'
hashed_columns:
  CASE_HKEY: 'CASE_HKEY_NK'
  CLAIM_HKEY: 'CLAIM_HKEY_NK'
  CLAIM_CASE_HKEY: 'CLAIM_CASE_HKEY_NK'
derived_columns:
  CASE_HKEY_NK: "'HUB_CASE|' || query_ref_id"
  CLAIM_HKEY_NK: "'HUB_CLAIM|' || clid"
  CLAIM_CASE_HKEY_NK: "'LNK_CLAIM_CASE|' || query_ref_id || '|' || clid"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_PREAUTH_QUERY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
