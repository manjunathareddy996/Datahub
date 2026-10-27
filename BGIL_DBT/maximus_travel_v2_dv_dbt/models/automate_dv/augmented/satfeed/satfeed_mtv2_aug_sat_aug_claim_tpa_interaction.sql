{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_TPA_INTERACTION: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        TPA_FEE_AMOUNT,
        TPA_FEE_CURRENCY_CODE,
        HASHDIFF_CLAIM_TPA_INTERACTION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmrsk_rska_msp_msd_prop_pv__sat_aug_claim_tpa_interaction') }}
    where CLAIM_HKEY is not null
