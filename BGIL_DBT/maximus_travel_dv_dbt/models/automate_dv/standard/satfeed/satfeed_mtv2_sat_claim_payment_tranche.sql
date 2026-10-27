{{ config(materialized='view') }}

-- FEED for SAT_CLAIM_PAYMENT_TRANCHE (target track): unions 3 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 10 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_CLAIM_PAYMENT_TRANCHE to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        TRANCHE_NUMBER as TRANCHE_NUMBER,
        APPROVAL_REFERENCE as APPROVAL_REFERENCE,
        FINAL_INDICATOR as FINAL_INDICATOR,
        GROSS_AMOUNT as GROSS_AMOUNT,
        HOLD_INDICATOR as HOLD_INDICATOR,
        HOLD_REASON as HOLD_REASON,
        NET_AMOUNT as NET_AMOUNT,
        PAYMENT_DATE as PAYMENT_DATE,
        PAYMENT_MODE as PAYMENT_MODE,
        PAYMENT_TYPE as PAYMENT_TYPE,
        STATUS as STATUS,
        HASHDIFF_CLAIM_PAYMENT_TRANCHE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmpay') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        TRANCHE_NUMBER as TRANCHE_NUMBER,
        APPROVAL_REFERENCE as APPROVAL_REFERENCE,
        FINAL_INDICATOR as FINAL_INDICATOR,
        GROSS_AMOUNT as GROSS_AMOUNT,
        HOLD_INDICATOR as HOLD_INDICATOR,
        HOLD_REASON as HOLD_REASON,
        NET_AMOUNT as NET_AMOUNT,
        PAYMENT_DATE__SAT_CLAIM_PAYMENT_TRANCHE as PAYMENT_DATE,
        PAYMENT_MODE__SAT_CLAIM_PAYMENT_TRANCHE as PAYMENT_MODE,
        PAYMENT_TYPE as PAYMENT_TYPE,
        STATUS as STATUS,
        HASHDIFF_CLAIM_PAYMENT_TRANCHE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmpay_payp_pv') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        TRANCHE_NUMBER as TRANCHE_NUMBER,
        APPROVAL_REFERENCE as APPROVAL_REFERENCE,
        FINAL_INDICATOR as FINAL_INDICATOR,
        GROSS_AMOUNT as GROSS_AMOUNT,
        HOLD_INDICATOR as HOLD_INDICATOR,
        HOLD_REASON as HOLD_REASON,
        NET_AMOUNT as NET_AMOUNT,
        PAYMENT_DATE as PAYMENT_DATE,
        PAYMENT_MODE as PAYMENT_MODE,
        PAYMENT_TYPE as PAYMENT_TYPE,
        STATUS as STATUS,
        HASHDIFF_CLAIM_PAYMENT_TRANCHE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_HKEY is not null
