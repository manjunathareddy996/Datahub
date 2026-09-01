{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_PARTY_IDENTIFICATION, table 'BJAZ_TRV_LOADER_DATA_MV', column 'EIANO' -> eIA Number [{'IDENTIFICATION_TYPE_CODE': 'eia'}].

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EIA_NUMBER'
      - 'IDENTIFICATION_TYPE_CODE'
derived_columns:
  PARENT_BK: 'premiumpayerid'
  PARENT_NK: "'HUB_PARTY|' || (premiumpayerid)"
  IDENTIFICATION_TYPE_CODE: '!eia'
  EIA_NUMBER: 'eiano'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
