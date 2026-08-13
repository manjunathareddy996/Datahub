{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_QUOTE_PARTY member-end 'bjaz_grp_hlt_imd_dtls'.
-- PARTY_HKEY is hashed with the EXACT SAME formula ('HUB_PARTY|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for QUOTE_HKEY.
-- QUOTE_PARTY_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_imd_dtls'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  QUOTE_HKEY: 'QUOTE_HKEY_NK'
  QUOTE_PARTY_HKEY: 'QUOTE_PARTY_HKEY_NK'
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || rm_code"
  QUOTE_HKEY_NK: "'HUB_QUOTE|' || quote_sub_no"
  QUOTE_PARTY_HKEY_NK: "'LNK_QUOTE_PARTY|' || rm_code || '|' || quote_sub_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_IMD_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
