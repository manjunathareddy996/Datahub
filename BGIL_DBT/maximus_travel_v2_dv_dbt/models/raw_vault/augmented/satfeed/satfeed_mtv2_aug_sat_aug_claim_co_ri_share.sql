{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_CO_RI_SHARE: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        CO_INSURANCE_APPLICABLE_INDICATOR,
        CO_INSURANCE_LOSS_RESERVE_AMOUNT,
        CO_INSURANCE_TYPE,
        HASHDIFF_CLAIM_CO_RI_SHARE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmap_pv__sat_aug_claim_co_ri_share') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        CO_INSURANCE_APPLICABLE_INDICATOR,
        CO_INSURANCE_LOSS_RESERVE_AMOUNT,
        CO_INSURANCE_TYPE,
        HASHDIFF_CLAIM_CO_RI_SHARE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmrsk_rska_properties_pv__sat_aug_claim_co_ri_share') }}
    where CLAIM_HKEY is not null
