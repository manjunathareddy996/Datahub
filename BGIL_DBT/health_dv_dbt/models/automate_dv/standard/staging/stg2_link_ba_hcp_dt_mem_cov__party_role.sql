{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_PARTY_ROLE member-end 'ba_hcp_dt_mem_cov'.
-- PARTY_HKEY is hashed with the EXACT SAME formula ('HUB_PARTY|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for LINK_INSTANCE_HKEY.
-- PARTY_ROLE_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_dt_mem_cov'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  LINK_INSTANCE_HKEY: 'LINK_INSTANCE_HKEY_NK'
  PARTY_ROLE_HKEY: 'PARTY_ROLE_HKEY_NK'
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || part_id"
  LINK_INSTANCE_HKEY_NK: "'LNK_PARTY_ROLE|' || mem_seqno"
  PARTY_ROLE_HKEY_NK: "'LNK_PARTY_ROLE|' || part_id || '|' || mem_seqno"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_DT_MEM_COV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
