{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_RISK_PERSON_TRAVEL, table
-- 'BJAZ_TRV_LOADER_DATA_MV', traveller MEMBER1. Reads from the stitch
-- (stitch_risk_person_travel_trip_attrs.sql), not the raw per-table stage --
-- see that file's header for what it joins and why (round 3). GEOGRAPHICAL_ZONE/
-- DESTINATION_COUNTRY/TRIP_DURATION are COALESCE'd between this table's own value
-- and the joined BA_TRV_DATA_POLICY_DTLS_MV value -- data_5b has a single slot for
-- each, not separate per-source variants (own-table value preferred; see stitch
-- header for the reasoning).

{%- set yaml_metadata -%}
source_model: 'stitch_risk_person_travel_trip_attrs'
hashed_columns:
  RISK_OBJECT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PASSPORT_NUMBER'
      - 'GEOGRAPHICAL_ZONE'
      - 'TRIP_DURATION'
      - 'TRIP_TYPE'
      - 'TRIP_START_DATE'
      - 'TRIP_END_DATE'
      - 'DESTINATION_COUNTRY'
      - 'VISA_TYPE'
derived_columns:
  PARENT_BK: "policy_ref || '|MEMBER1'"
  PARENT_NK: "'HUB_RISK_OBJECT|' || (policy_ref || '|MEMBER1')"
  PASSPORT_NUMBER: 'member1passportno'
  GEOGRAPHICAL_ZONE: 'coalesce(areaplan, travel_area_plan_no, travel_area_plan_nm)'
  TRIP_DURATION: 'coalesce(noofjourneydays, no_of_days)'
  TRIP_TYPE: 'prjourney'
  TRIP_START_DATE: 'departuredate'
  TRIP_END_DATE: 'returndate'
  DESTINATION_COUNTRY: 'destination'
  VISA_TYPE: 'type_of_visa'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
