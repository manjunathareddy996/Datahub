{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_COMMON_ADDRESS, table
-- 'BJAZ_TRV_LOADER_LOG_TABLE_MV' (insured). Reuses the exact address-point content-hash key
-- formula from stg2_hub_bjaz_trv_loader_log_table_mv__location_addr.sql -- round-2 fix: this
-- previously (wrongly) used TRANSITFROM (a trip-transit code, unrelated to this person's
-- home address) due to a stage-filename collision bug in the hub generator.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_log_table_mv'
hashed_columns:
  LOCATION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BUILDING_NAME'
      - 'CITY'
      - 'COUNTRY_NAME'
      - 'POSTAL_CODE'
      - 'STATE_NAME'
      - 'STREET_NAME'
derived_columns:
  PARENT_BK: "coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(city, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '') || '|' || coalesce(country, '')"
  PARENT_NK: "'HUB_LOCATION|' || (coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(city, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '') || '|' || coalesce(country, ''))"
  BUILDING_NAME: 'building'
  CITY: 'city'
  COUNTRY_NAME: 'country'
  POSTAL_CODE: 'pincode'
  STATE_NAME: 'state'
  STREET_NAME: 'streetname'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_LOG_TABLE_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
