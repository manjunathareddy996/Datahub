{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_FNOL: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        ADD_ON_CLAIM_ELECTED_INDICATOR,
        CLAIM_PERSON_NAME,
        DELAYED_INTIMATION_REASON,
        INTIMATED_CAUSE_OF_CLAIM,
        REGISTRATION_FLAGS,
        REPORTED_BY_EMAIL,
        THIRD_PARTY_INVOLVEMENT_INDICATOR,
        HASHDIFF_CLAIM_FNOL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmap_pv__sat_aug_claim_fnol') }}
    where CLAIM_HKEY is not null
