{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_TRAVEL_DETAIL: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        ACCIDENTAL_INDICATOR,
        AFFECTED_ITEMS_DESCRIPTION,
        BAGGAGE_DELIVERY_DATE,
        BAGGAGE_DELIVERY_TIME,
        BENEFIT_DAYS_AVAILED,
        CLAIMED_EVENT_DURATION,
        CLAIM_LINE_INSURED_PERSON_RELATIONSHIP,
        INCIDENT_DESCRIPTION,
        INCIDENT_TIME,
        NUMBER_OF_BAGS_AFFECTED,
        PURPOSE_OF_VISIT,
        RELEASE_DATE,
        RELEASE_TIME,
        TRIP_DESTINATION_COUNTRY,
        WEATHER_CONDITION_AT_INCIDENT,
        HASHDIFF_CLAIM_TRAVEL_DETAIL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd__sat_aug_claim_travel_detail') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        ACCIDENTAL_INDICATOR,
        AFFECTED_ITEMS_DESCRIPTION,
        BAGGAGE_DELIVERY_DATE,
        BAGGAGE_DELIVERY_TIME,
        BENEFIT_DAYS_AVAILED,
        CLAIMED_EVENT_DURATION,
        CLAIM_LINE_INSURED_PERSON_RELATIONSHIP,
        INCIDENT_DESCRIPTION,
        INCIDENT_TIME,
        NUMBER_OF_BAGS_AFFECTED,
        PURPOSE_OF_VISIT,
        RELEASE_DATE,
        RELEASE_TIME,
        TRIP_DESTINATION_COUNTRY,
        WEATHER_CONDITION_AT_INCIDENT,
        HASHDIFF_CLAIM_TRAVEL_DETAIL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_clmrsk_rska_properties_pv__sat_aug_claim_travel_detail') }}
    where CLAIM_HKEY is not null
