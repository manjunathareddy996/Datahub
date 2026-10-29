{{ config(materialized='view') }}

-- FEED for SAT_CLAIM_SETTLEMENT (target track): unions 1 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 1 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_CLAIM_SETTLEMENT to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        INTEREST_PAID_AMOUNT as INTEREST_PAID_AMOUNT,
        HASHDIFF_CLAIM_SETTLEMENT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_HKEY is not null
