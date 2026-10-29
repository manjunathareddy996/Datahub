{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_TRAVEL_TERMS: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        BAGGAGE_TRACKING_SERVICE_INDICATOR,
        COVER_HOURS_COUNT,
        CRUISE_DAYS_COUNT,
        CRUISE_SEGMENT_INDICATOR,
        MAXIMUM_TRIP_ALTITUDE,
        MODE_OF_TRANSPORT,
        MULTIPLE_DESTINATION_CITY_INDICATOR,
        TRIP_DESTINATION_COUNTRY,
        TRIP_DESTINATION_DETAILS,
        HASHDIFF_POLICY_TRAVEL_TERMS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_polp_sp_pv__sat_aug_policy_travel_terms') }}
    where POLICY_HKEY is not null
