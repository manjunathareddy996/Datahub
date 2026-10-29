{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL sat() for SAT_AUG_CLAIM_TRAVEL_DETAIL.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, CLAIM_HKEY, single-active.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_claim_travel_detail'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ACCIDENTAL_INDICATOR'
  - 'AFFECTED_ITEMS_DESCRIPTION'
  - 'BAGGAGE_DELIVERY_DATE'
  - 'BAGGAGE_DELIVERY_TIME'
  - 'BENEFIT_DAYS_AVAILED'
  - 'CLAIMED_EVENT_DURATION'
  - 'CLAIM_LINE_INSURED_PERSON_RELATIONSHIP'
  - 'INCIDENT_DESCRIPTION'
  - 'INCIDENT_TIME'
  - 'NUMBER_OF_BAGS_AFFECTED'
  - 'PURPOSE_OF_VISIT'
  - 'RELEASE_DATE'
  - 'RELEASE_TIME'
  - 'TRIP_DESTINATION_COUNTRY'
  - 'WEATHER_CONDITION_AT_INCIDENT'
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
