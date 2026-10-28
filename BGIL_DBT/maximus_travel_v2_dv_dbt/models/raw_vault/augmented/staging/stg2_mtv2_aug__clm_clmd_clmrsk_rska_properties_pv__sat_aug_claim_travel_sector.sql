{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_TRAVEL_SECTOR from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 16 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmrsk_rska_properties_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_TRAVEL_SECTOR:
    is_hashdiff: true
    columns:
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
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  ACTUAL_DEPARTURE_DATE: 'actual_flight_date'
  ACTUAL_DEPARTURE_TIME: 'actual_flight_time'
  AIRLINE_NAME: 'airlines_name'
  CONNECTING_FLIGHT_NUMBER: 'connecting_flight_number'
  FLIGHT_DELAY_DURATION: 'flight_delay'
  FLIGHT_NAME: 'flight_name'
  FLIGHT_NUMBER: 'flight_number'
  MODE_OF_TRAVEL: 'mode_of_travel'
  ORIGINALLY_SCHEDULED_TRAVEL_DATE: 'original_date'
  RESCHEDULED_DEPARTURE_DATE: 'rescheduled_date'
  RESCHEDULED_TRAVEL_CLASS: 'rescheduled_flight_class'
  SCHEDULED_ARRIVAL_DATE: 'flight_end_date'
  SCHEDULED_ARRIVAL_TIME: 'flight_end_time'
  SCHEDULED_DEPARTURE_DATE: 'flight_date'
  SCHEDULED_DEPARTURE_TIME: 'flight_time'
  TYPE_OF_TRANSPORT: 'type_of_transport'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
