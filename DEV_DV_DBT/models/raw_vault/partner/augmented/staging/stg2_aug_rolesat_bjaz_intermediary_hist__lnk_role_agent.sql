{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for SAT_AUG_LNK_ROLE_AGENT
-- (HUB_PARTY grain, role-special: 'agent'), table 'BJAZ_INTERMEDIARY_HIST'.
-- Reuses the exact PARTY_HKEY formula (intermediary_id) from the matching standard-model
-- stg2_rolesat_*__lnk_role_agent.sql. Same as BJAZ_INTERMEDIARY -- history variant, same structure/grain.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_intermediary_hist'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INTERMEDIARY_LICENCE_NUMBER'
derived_columns:
  PARENT_BK: 'intermediary_id'
  PARENT_NK: "'HUB_PARTY|' || (intermediary_id)"
  INTERMEDIARY_LICENCE_NUMBER: 'license_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_INTERMEDIARY_HIST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
