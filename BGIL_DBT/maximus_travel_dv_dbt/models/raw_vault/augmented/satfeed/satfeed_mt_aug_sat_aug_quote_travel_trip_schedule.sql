{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_QUOTE_TRAVEL_TRIP_SCHEDULE: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        QUOTE_HKEY as QUOTE_HKEY,
        PASSENGER_NAME_RECORD,
        TRIP_COVER_PERIOD,
        TRIP_DURATION_DAYS,
        TRIP_END_DATE,
        TRIP_LEG_DIRECTION,
        TRIP_SEQUENCE_NUMBER,
        TRIP_START_DATE,
        TRIP_TYPE_ON_COVER,
        TRIP_TYPE_ON_TRIP_CALCULATOR,
        HASHDIFF_QUOTE_TRAVEL_TRIP_SCHEDULE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_qpd_polp_msp_imsd_inp_pv__sat_aug_quote_travel_trip_schedule') }}
    where QUOTE_HKEY is not null
