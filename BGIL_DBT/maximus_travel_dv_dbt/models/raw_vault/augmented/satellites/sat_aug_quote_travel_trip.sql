{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL sat() for SAT_AUG_QUOTE_TRAVEL_TRIP.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, QUOTE_HKEY, single-active.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_quote_travel_trip'
src_pk: 'QUOTE_HKEY'
src_payload:
  - 'ARRIVAL_COUNTRY'
  - 'ARRIVAL_DATE'
  - 'ARRIVAL_TIME'
  - 'DEPARTURE_AIRPORT_CODE'
  - 'DEPARTURE_COUNTRY'
  - 'DEPARTURE_TIME'
  - 'DESTINATION_CONTINENT'
  - 'DESTINATION_COUNTRY'
  - 'FLIGHT_NUMBER'
  - 'GEOGRAPHICAL_ZONE'
  - 'TRIP_DURATION_TYPE'
  - 'TRIP_START_DATE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
