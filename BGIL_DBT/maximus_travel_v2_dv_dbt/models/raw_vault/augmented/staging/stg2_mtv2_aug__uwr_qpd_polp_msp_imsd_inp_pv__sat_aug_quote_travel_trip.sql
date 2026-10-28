{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_QUOTE_TRAVEL_TRIP from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 12 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_QUOTE_TRAVEL_TRIP:
    is_hashdiff: true
    columns:
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
derived_columns:
  QUOTE_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  ARRIVAL_COUNTRY: 'arrival_country'
  ARRIVAL_DATE: 'arrival_date'
  ARRIVAL_TIME: 'arrival_time'
  DEPARTURE_AIRPORT_CODE: 'departure_airport_code'
  DEPARTURE_COUNTRY: 'departure_country'
  DEPARTURE_TIME: 'departure_time'
  DESTINATION_CONTINENT: 'destination_continent'
  DESTINATION_COUNTRY: 'destination_country'
  FLIGHT_NUMBER: 'flight_no'
  GEOGRAPHICAL_ZONE: 'geographical_coverage'
  TRIP_DURATION_TYPE: 'duration_type'
  TRIP_START_DATE: 'departure_date'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
