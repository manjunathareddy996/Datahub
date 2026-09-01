{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_COMMON_CONTACT, table 'BJAZ_TRV_LOADER_DATA_MV', column 'TELEPHONE' -> Landline Number [{'CONTACT_POINT_TYPE': 'landline', 'CONTACT_PRIORITY_ORDER': '1'}].

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LANDLINE_NUMBER'
      - 'CONTACT_POINT_TYPE'
      - 'CONTACT_PRIORITY_ORDER'
derived_columns:
  PARENT_BK: 'premiumpayerid'
  PARENT_NK: "'HUB_PARTY|' || (premiumpayerid)"
  CONTACT_POINT_TYPE: '!landline'
  CONTACT_PRIORITY_ORDER: '!1'
  LANDLINE_NUMBER: 'telephone'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
