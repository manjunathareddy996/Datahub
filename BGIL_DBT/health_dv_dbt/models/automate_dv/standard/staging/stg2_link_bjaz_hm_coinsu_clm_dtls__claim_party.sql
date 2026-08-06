{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_CLAIM_PARTY member-end 'bjaz_hm_coinsu_clm_dtls'.
-- CLAIM_HKEY is hashed with the EXACT SAME formula ('HUB_CLAIM|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PARTY_HKEY.
-- CLAIM_PARTY_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_coinsu_clm_dtls'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_HKEY_NK'
  PARTY_HKEY: 'PARTY_HKEY_NK'
  CLAIM_PARTY_HKEY: 'CLAIM_PARTY_HKEY_NK'
derived_columns:
  CLAIM_HKEY_NK: "'HUB_CLAIM|' || claim_id"
  PARTY_HKEY_NK: "'HUB_PARTY|' || ldr_pid"
  CLAIM_PARTY_HKEY_NK: "'LNK_CLAIM_PARTY|' || claim_id || '|' || ldr_pid"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_COINSU_CLM_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
