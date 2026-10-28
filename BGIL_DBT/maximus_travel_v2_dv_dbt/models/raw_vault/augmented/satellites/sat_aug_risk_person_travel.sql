{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 sat() for SAT_AUG_RISK_PERSON_TRAVEL.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- src_pk, grain and src_cdk are the SIBLING's exactly (BUILD_RULES 7.2 / 7.7). The
-- sibling builds this satellite on its augmented track; where this map asks for a grain
-- the sibling does not carry, the SIBLING WINS and the difference is a modeller item
-- in the build report -- it is not resolved here.

{%- set yaml_metadata -%}
source_model: 'satfeed_mtv2_aug_sat_aug_risk_person_travel'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'ARRIVAL_COUNTRY'
  - 'ARRIVAL_DATE'
  - 'ARRIVAL_TIME'
  - 'COVER_TRIP_TYPE'
  - 'DEPARTURE_AIRPORT_CODE'
  - 'DEPARTURE_COUNTRY'
  - 'DEPARTURE_TIME'
  - 'DESTINATION_CONTINENT'
  - 'FLIGHT_ITINERARY_DETAIL'
  - 'FLIGHT_NUMBER'
  - 'GUIDED_TOUR_INDICATOR'
  - 'OVERSEAS_STAY_DAYS'
  - 'PLAN_NAME'
  - 'PRIORITY_MEMBER_INDICATOR'
  - 'RISK_COVER_EXPIRY_DATE'
  - 'RISK_COVER_INCEPTION_DATE'
  - 'RISK_PLAN_CODE'
  - 'STANDARD_RISK_INDICATOR'
  - 'TRIP_COVERAGE_BASIS'
  - 'TRIP_DESCRIPTION'
  - 'TRIP_DURATION_TYPE'
  - 'TRIP_ORIGIN_PLACE'
  - 'UHC_CODE'
  - 'VISA_APPLICATION_NUMBER'
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
