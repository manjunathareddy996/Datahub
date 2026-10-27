{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_SETTLEMENT: unions 3 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        INTEREST_APPLICABLE_INDICATOR,
        LINKED_CLAIM_PAYABLE_AMOUNT,
        ONE_TIME_SETTLEMENT_INDICATOR,
        HASHDIFF_CLAIM_SETTLEMENT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmap_pv__sat_aug_claim_settlement') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        INTEREST_APPLICABLE_INDICATOR,
        LINKED_CLAIM_PAYABLE_AMOUNT,
        ONE_TIME_SETTLEMENT_INDICATOR,
        HASHDIFF_CLAIM_SETTLEMENT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmrsk_rska_msp_msd_prop_pv__sat_aug_claim_settlement') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        INTEREST_APPLICABLE_INDICATOR,
        LINKED_CLAIM_PAYABLE_AMOUNT,
        ONE_TIME_SETTLEMENT_INDICATOR,
        HASHDIFF_CLAIM_SETTLEMENT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmrsk_rska_properties_pv__sat_aug_claim_settlement') }}
    where CLAIM_HKEY is not null
