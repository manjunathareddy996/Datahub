{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 sat() for SAT_AUG_CLAIM_TRAVEL_SECTOR.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, CLAIM_HKEY, single-active.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mtv2_aug_sat_aug_claim_travel_sector'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ACTUAL_DEPARTURE_DATE'
  - 'ACTUAL_DEPARTURE_TIME'
  - 'AIRLINE_NAME'
  - 'CONNECTING_FLIGHT_NUMBER'
  - 'FLIGHT_DELAY_DURATION'
  - 'FLIGHT_NAME'
  - 'FLIGHT_NUMBER'
  - 'MODE_OF_TRAVEL'
  - 'ORIGINALLY_SCHEDULED_TRAVEL_DATE'
  - 'RESCHEDULED_DEPARTURE_DATE'
  - 'RESCHEDULED_TRAVEL_CLASS'
  - 'SCHEDULED_ARRIVAL_DATE'
  - 'SCHEDULED_ARRIVAL_TIME'
  - 'SCHEDULED_DEPARTURE_DATE'
  - 'SCHEDULED_DEPARTURE_TIME'
  - 'TYPE_OF_TRANSPORT'
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
