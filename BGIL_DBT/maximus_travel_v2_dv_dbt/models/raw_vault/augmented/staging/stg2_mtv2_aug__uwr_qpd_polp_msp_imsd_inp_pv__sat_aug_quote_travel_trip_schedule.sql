{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_QUOTE_TRAVEL_TRIP_SCHEDULE from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 9 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_QUOTE_TRAVEL_TRIP_SCHEDULE:
    is_hashdiff: true
    columns:
      - 'PASSENGER_NAME_RECORD'
      - 'TRIP_COVER_PERIOD'
      - 'TRIP_DURATION_DAYS'
      - 'TRIP_END_DATE'
      - 'TRIP_LEG_DIRECTION'
      - 'TRIP_SEQUENCE_NUMBER'
      - 'TRIP_START_DATE'
      - 'TRIP_TYPE_ON_COVER'
      - 'TRIP_TYPE_ON_TRIP_CALCULATOR'
derived_columns:
  QUOTE_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  PASSENGER_NAME_RECORD: 'pnr'
  TRIP_COVER_PERIOD: 'period'
  TRIP_DURATION_DAYS: 'trip_duration_in_days'
  TRIP_END_DATE: 'return_date'
  TRIP_LEG_DIRECTION: 'onward_return'
  TRIP_SEQUENCE_NUMBER: 'trip_no'
  TRIP_START_DATE: 'travel_date'
  TRIP_TYPE_ON_COVER: 'trip_type_incov'
  TRIP_TYPE_ON_TRIP_CALCULATOR: 'trip_type_tripcal'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
