{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_RISK_TRAVEL_TRIP_ITINERARY from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 10 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF_RISK_TRAVEL_TRIP_ITINERARY:
    is_hashdiff: true
    columns:
      - 'ARRIVAL_DATE'
      - 'ARRIVAL_TIME'
      - 'DEPARTURE_AIRPORT_CODE'
      - 'DEPARTURE_COUNTRY'
      - 'DEPARTURE_TIME'
      - 'FLIGHT_NUMBER'
      - 'ONWARD_OR_RETURN_INDICATOR'
      - 'PNR_NUMBER'
      - 'TRAVEL_DATE'
      - 'TRIP_NUMBER'
derived_columns:
  RISK_OBJECT_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  ARRIVAL_DATE: 'arrival_date'
  ARRIVAL_TIME: 'arrival_time'
  DEPARTURE_AIRPORT_CODE: 'departure_airport_code'
  DEPARTURE_COUNTRY: 'departure_country'
  DEPARTURE_TIME: 'departure_time'
  FLIGHT_NUMBER: 'flight_no'
  ONWARD_OR_RETURN_INDICATOR: 'onward_return'
  PNR_NUMBER: 'pnr'
  TRAVEL_DATE: 'travel_date'
  TRIP_NUMBER: 'trip_no'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
