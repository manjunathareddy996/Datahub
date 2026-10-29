{{ config(materialized='view') }}

-- FEED for SAT_CLAIM_PROVIDER_BILLING (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 5 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_CLAIM_PROVIDER_BILLING to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        BILL_NUMBER as BILL_NUMBER,
        APPROVED_AMOUNT as APPROVED_AMOUNT,
        BILLED_AMOUNT as BILLED_AMOUNT,
        BILL_STATUS_TYPE as BILL_STATUS_TYPE,
        DISALLOWANCE_REASON as DISALLOWANCE_REASON,
        DISALLOWED_AMOUNT as DISALLOWED_AMOUNT,
        HASHDIFF_CLAIM_PROVIDER_BILLING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmpay_payp_pv') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        BILL_NUMBER as BILL_NUMBER,
        APPROVED_AMOUNT as APPROVED_AMOUNT,
        BILLED_AMOUNT as BILLED_AMOUNT,
        BILL_STATUS_TYPE as BILL_STATUS_TYPE,
        DISALLOWANCE_REASON as DISALLOWANCE_REASON,
        DISALLOWED_AMOUNT as DISALLOWED_AMOUNT,
        HASHDIFF_CLAIM_PROVIDER_BILLING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_HKEY is not null
