{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_PARTY_CHANNEL member-end 'bjaz_ihg_mem_dtls_extn'.
-- DISTRIBUTION_CHANNEL_HKEY is hashed with the EXACT SAME formula ('HUB_DISTRIBUTION_CHANNEL|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PARTY_HKEY.
-- PARTY_CHANNEL_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_ihg_mem_dtls_extn'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_HKEY_NK'
  PARTY_HKEY: 'PARTY_HKEY_NK'
  PARTY_CHANNEL_HKEY: 'PARTY_CHANNEL_HKEY_NK'
derived_columns:
  DISTRIBUTION_CHANNEL_HKEY_NK: "'HUB_DISTRIBUTION_CHANNEL|' || partner_id"
  PARTY_HKEY_NK: "'HUB_PARTY|' || member_no"
  PARTY_CHANNEL_HKEY_NK: "'LNK_PARTY_CHANNEL|' || partner_id || '|' || member_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_IHG_MEM_DTLS_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
