{{ config(materialized='view') }}

-- FEED for SAT_CLAIM_RESERVE (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 5 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_CLAIM_RESERVE to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        RESERVE_HEAD as RESERVE_HEAD,
        CURRENT_RESERVE_AMOUNT as CURRENT_RESERVE_AMOUNT,
        INITIAL_RESERVE_AMOUNT as INITIAL_RESERVE_AMOUNT,
        OUTSTANDING_RESERVE_AMOUNT as OUTSTANDING_RESERVE_AMOUNT,
        PAID_TO_DATE_AMOUNT as PAID_TO_DATE_AMOUNT,
        RESERVE_TYPE as RESERVE_TYPE,
        HASHDIFF_CLAIM_RESERVE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmpay_payp_pv') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        RESERVE_HEAD as RESERVE_HEAD,
        CURRENT_RESERVE_AMOUNT as CURRENT_RESERVE_AMOUNT,
        INITIAL_RESERVE_AMOUNT as INITIAL_RESERVE_AMOUNT,
        OUTSTANDING_RESERVE_AMOUNT as OUTSTANDING_RESERVE_AMOUNT,
        PAID_TO_DATE_AMOUNT as PAID_TO_DATE_AMOUNT,
        RESERVE_TYPE as RESERVE_TYPE,
        HASHDIFF_CLAIM_RESERVE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_claim_reserve') }}
    where CLAIM_HKEY is not null
