{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_RISK_TRAVEL_RATING_INPUT: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        RATING_INPUT_CODE,
        PREMIUM_COMPONENT_AMOUNT,
        PREMIUM_RATE_VALUE,
        PREMIUM_TYPE,
        HASHDIFF_RISK_TRAVEL_RATING_INPUT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_ins_rskp_msp_msd_prop_pv__sat_aug_risk_travel_rating_input') }}
    where RISK_OBJECT_HKEY is not null
