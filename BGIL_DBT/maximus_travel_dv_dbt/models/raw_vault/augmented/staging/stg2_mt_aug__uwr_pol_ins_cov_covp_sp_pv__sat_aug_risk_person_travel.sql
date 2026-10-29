{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_RISK_PERSON_TRAVEL from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- ALIGNED to the OPUS sibling (BUILD_RULES 7.7). travel_dv_dbt already builds
-- SAT_AUG_RISK_PERSON_TRAVEL with src_pk RISK_OBJECT_HKEY, single-active, no child key and a bare
-- HASHDIFF. This EXTENDS that satellite's payload; a second Maximus-side satellite
-- for the same concept would be model invention wearing an AUG_ prefix.
--
-- 24 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_ins_cov_covp_sp_pv'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF_RISK_PERSON_TRAVEL:
    is_hashdiff: true
    columns:
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
derived_columns:
  RISK_OBJECT_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  ARRIVAL_COUNTRY: 'cast(null as varchar)'
  ARRIVAL_DATE: 'cast(null as varchar)'
  ARRIVAL_TIME: 'cast(null as varchar)'
  COVER_TRIP_TYPE: 'cast(null as varchar)'
  DEPARTURE_AIRPORT_CODE: 'cast(null as varchar)'
  DEPARTURE_COUNTRY: 'cast(null as varchar)'
  DEPARTURE_TIME: 'cast(null as varchar)'
  DESTINATION_CONTINENT: 'cast(null as varchar)'
  FLIGHT_ITINERARY_DETAIL: 'cast(null as varchar)'
  FLIGHT_NUMBER: 'cast(null as varchar)'
  GUIDED_TOUR_INDICATOR: 'cast(null as varchar)'
  OVERSEAS_STAY_DAYS: 'cast(null as varchar)'
  PLAN_NAME: 'cast(null as varchar)'
  PRIORITY_MEMBER_INDICATOR: 'cast(null as varchar)'
  RISK_COVER_EXPIRY_DATE: 'cast(null as varchar)'
  RISK_COVER_INCEPTION_DATE: 'cast(null as varchar)'
  RISK_PLAN_CODE: 'cast(null as varchar)'
  STANDARD_RISK_INDICATOR: 'cast(null as varchar)'
  TRIP_COVERAGE_BASIS: 'trip_coverage'
  TRIP_DESCRIPTION: 'cast(null as varchar)'
  TRIP_DURATION_TYPE: 'cast(null as varchar)'
  TRIP_ORIGIN_PLACE: 'cast(null as varchar)'
  UHC_CODE: 'cast(null as varchar)'
  VISA_APPLICATION_NUMBER: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
