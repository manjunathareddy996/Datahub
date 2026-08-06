{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() -- table 'CLM_SUPPLIERS'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__clm_suppliers'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  LOCATION_HKEY: 'LOCATION_HKEY_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_HKEY_NK'
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || part_id"
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || loc_code"
  PARTY_LOCATION_HKEY_NK: "'LNK_PARTY_LOCATION|' || part_id || '|' || loc_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!CLM_SUPPLIERS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
