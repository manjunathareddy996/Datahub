{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_LOCATION, address-point branch on
-- 'BJAZ_TRV_LOADER_DATA_MV'. Round-2 mapper correction (docs/MAPPER_QUESTIONS_TRAVEL.md /
-- MAPPER_REPLIES_TRAVEL.md): SAT_COMMON_ADDRESS is single-active, and a pincode covers many
-- distinct addresses, so PINCODE alone would collapse unrelated addresses onto one row.
-- Key is a content hash of the full normalized address (address-point grain), deduped by
-- content -- same composite-key pattern already used for HUB_RISK_OBJECT in this project.
-- This is a SEPARATE HUB_LOCATION branch from any trip-transit-point columns on this table
-- (none exist here) -- a location hub can have more than one kind of location per table.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  LOCATION_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: "coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '')"
  PARENT_NK: "'HUB_LOCATION|' || (coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, ''))"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
