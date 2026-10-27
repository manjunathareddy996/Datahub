{{ config(materialized='view') }}

-- FEED for SAT_CLAIM_CO_RI_SHARE (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 3 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_CLAIM_CO_RI_SHARE to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        CO_INSURANCE_OUR_SHARE_PERCENTAGE as CO_INSURANCE_OUR_SHARE_PERCENTAGE,
        EXPENSE_SHARE_AMOUNT as EXPENSE_SHARE_AMOUNT,
        LEADER_INDICATOR as LEADER_INDICATOR,
        HASHDIFF_CLAIM_CO_RI_SHARE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        CO_INSURANCE_OUR_SHARE_PERCENTAGE as CO_INSURANCE_OUR_SHARE_PERCENTAGE,
        EXPENSE_SHARE_AMOUNT as EXPENSE_SHARE_AMOUNT,
        LEADER_INDICATOR as LEADER_INDICATOR,
        HASHDIFF_CLAIM_CO_RI_SHARE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_HKEY is not null
