{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_EXPENSE_LINE: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        EXPENSE_AMOUNT,
        EXPENSE_FEE_HEAD_CODE,
        EXPENSE_FEE_HEAD_DESCRIPTION,
        EXPENSE_PAYMENT_AMOUNT,
        EXPENSE_PAYMENT_APPROVER_REFERENCE,
        EXPENSE_PAYMENT_DATE,
        EXPENSE_PAYMENT_MODE,
        EXPENSE_PAYMENT_NARRATION,
        EXPENSE_PAYMENT_PORTAL_REFERENCE_NUMBER,
        EXPENSE_PAYMENT_REFERENCE_NUMBER,
        EXPENSE_PAYMENT_TYPE,
        EXPENSE_TYPE,
        HASHDIFF_CLAIM_EXPENSE_LINE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmrsk_rska_msp_msd_prop_pv__sat_aug_claim_expense_line') }}
    where CLAIM_HKEY is not null
