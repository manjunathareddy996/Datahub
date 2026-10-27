{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_TRAVEL_SECTOR: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        ACTUAL_DEPARTURE_DATE,
        ACTUAL_DEPARTURE_TIME,
        AIRLINE_NAME,
        CONNECTING_FLIGHT_NUMBER,
        FLIGHT_DELAY_DURATION,
        FLIGHT_NAME,
        FLIGHT_NUMBER,
        MODE_OF_TRAVEL,
        ORIGINALLY_SCHEDULED_TRAVEL_DATE,
        RESCHEDULED_DEPARTURE_DATE,
        RESCHEDULED_TRAVEL_CLASS,
        SCHEDULED_ARRIVAL_DATE,
        SCHEDULED_ARRIVAL_TIME,
        SCHEDULED_DEPARTURE_DATE,
        SCHEDULED_DEPARTURE_TIME,
        TYPE_OF_TRANSPORT,
        HASHDIFF_CLAIM_TRAVEL_SECTOR as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmrsk_rska_properties_pv__sat_aug_claim_travel_sector') }}
    where CLAIM_HKEY is not null
