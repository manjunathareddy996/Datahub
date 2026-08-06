{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() -- table 'BJAZ_AZBJ_PART_EXT_HIST'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_azbj_part_ext_hist'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  LOCATION_HKEY: 'LOCATION_HKEY_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_HKEY_NK'
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || part_id"
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || mail_add_id"
  PARTY_LOCATION_HKEY_NK: "'LNK_PARTY_LOCATION|' || part_id || '|' || mail_add_id"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_AZBJ_PART_EXT_HIST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
