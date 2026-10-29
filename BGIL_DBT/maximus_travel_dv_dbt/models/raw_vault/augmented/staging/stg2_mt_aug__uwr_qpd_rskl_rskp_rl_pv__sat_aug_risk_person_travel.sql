{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_RISK_PERSON_TRAVEL from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
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
source_model: 'resolved_mt__uwr_qpd_rskl_rskp_rl_pv'
hashed_columns:
  RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK: 'RISK_OBJECT_NK__QUOTED_TRAVELLER_RISK'
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
  RISK_OBJECT_BK__QUOTED_TRAVELLER_RISK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK__QUOTED_TRAVELLER_RISK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  ARRIVAL_COUNTRY: 'cast(null as varchar)'
  ARRIVAL_DATE: 'cast(null as varchar)'
  ARRIVAL_TIME: 'cast(null as varchar)'
  COVER_TRIP_TYPE: 'cast(null as varchar)'
  DEPARTURE_AIRPORT_CODE: 'cast(null as varchar)'
  DEPARTURE_COUNTRY: 'cast(null as varchar)'
  DEPARTURE_TIME: 'cast(null as varchar)'
  DESTINATION_CONTINENT: 'cast(null as varchar)'
  FLIGHT_ITINERARY_DETAIL: 'flight_details'
  FLIGHT_NUMBER: 'cast(null as varchar)'
  GUIDED_TOUR_INDICATOR: 'guided_tours'
  OVERSEAS_STAY_DAYS: 'total_stay_overseas_in_days'
  PLAN_NAME: 'plan_name'
  PRIORITY_MEMBER_INDICATOR: 'priority_member'
  RISK_COVER_EXPIRY_DATE: 'risk_expiry_date'
  RISK_COVER_INCEPTION_DATE: 'risk_inception_date'
  RISK_PLAN_CODE: 'risk_plan'
  STANDARD_RISK_INDICATOR: 'standard_risk_ace'
  TRIP_COVERAGE_BASIS: 'cast(null as varchar)'
  TRIP_DESCRIPTION: 'trip_details'
  TRIP_DURATION_TYPE: 'cast(null as varchar)'
  TRIP_ORIGIN_PLACE: 'place_of_origin'
  UHC_CODE: 'uhc_code'
  VISA_APPLICATION_NUMBER: 'visa_application_number'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
