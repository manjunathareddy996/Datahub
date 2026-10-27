{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_RISK_TRAVEL_TRIP_ITINERARY: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        ARRIVAL_DATE,
        ARRIVAL_TIME,
        DEPARTURE_AIRPORT_CODE,
        DEPARTURE_COUNTRY,
        DEPARTURE_TIME,
        FLIGHT_NUMBER,
        ONWARD_OR_RETURN_INDICATOR,
        PNR_NUMBER,
        TRAVEL_DATE,
        TRIP_NUMBER,
        HASHDIFF_RISK_TRAVEL_TRIP_ITINERARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_rskp_msp_msd_prop_pv__sat_aug_risk_travel_trip_itinerary') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        ARRIVAL_DATE,
        ARRIVAL_TIME,
        DEPARTURE_AIRPORT_CODE,
        DEPARTURE_COUNTRY,
        DEPARTURE_TIME,
        FLIGHT_NUMBER,
        ONWARD_OR_RETURN_INDICATOR,
        PNR_NUMBER,
        TRAVEL_DATE,
        TRIP_NUMBER,
        HASHDIFF_RISK_TRAVEL_TRIP_ITINERARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_rskl_msp_imsd_inp_pv__sat_aug_risk_travel_trip_itinerary') }}
    where RISK_OBJECT_HKEY is not null
