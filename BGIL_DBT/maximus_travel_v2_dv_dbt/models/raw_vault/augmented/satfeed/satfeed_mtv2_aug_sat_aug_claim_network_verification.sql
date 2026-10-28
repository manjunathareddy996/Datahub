{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_NETWORK_VERIFICATION: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        PROVIDER_EMAIL_ADDRESS,
        VENDOR_PERFORMANCE_SCORE,
        HASHDIFF_CLAIM_NETWORK_VERIFICATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmap_pv__sat_aug_claim_network_verification') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        PROVIDER_EMAIL_ADDRESS,
        VENDOR_PERFORMANCE_SCORE,
        HASHDIFF_CLAIM_NETWORK_VERIFICATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmrsk_rska_properties_pv__sat_aug_claim_network_verification') }}
    where CLAIM_HKEY is not null
