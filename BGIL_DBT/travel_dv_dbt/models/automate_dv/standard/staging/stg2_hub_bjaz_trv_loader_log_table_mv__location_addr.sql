{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_LOCATION, address-point branch on
-- 'BJAZ_TRV_LOADER_LOG_TABLE_MV'. Round-2 mapper correction -- same reasoning as the
-- BJAZ_TRV_LOADER_DATA_MV address-point branch (content-hash of the full normalized
-- address, not PINCODE alone). This table ALSO has a genuine transit-point HUB_LOCATION
-- branch (TRANSITFROM/TRANSITTO, see stg2_hub_bjaz_trv_loader_log_table_mv__location_*.sql)
-- -- that one is a different location concept (trip endpoints) and is untouched by this fix.
-- BUG FIX NOTE: the original build wrongly reused TRANSITFROM as this address's key (a
-- leftover from a stage-filename collision bug in the hub generator -- see hub_location.sql
-- history) -- an unrelated trip-transit code has nothing to do with a person's home address.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_log_table_mv'
hashed_columns:
  LOCATION_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: "coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(city, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '') || '|' || coalesce(country, '')"
  PARENT_NK: "'HUB_LOCATION|' || (coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(city, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '') || '|' || coalesce(country, ''))"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_LOG_TABLE_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
