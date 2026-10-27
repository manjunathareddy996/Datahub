{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_PAYMENT_TRANCHE: unions 3 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        TRANCHE_NUMBER,
        AOL_MODE_CODE,
        CASHLESS_CLAIM_TYPE,
        DAMAGE_TYPE_CODE,
        FIXED_DEPOSIT_RECEIPT_FAVOURING_NAME,
        FIXED_DEPOSIT_RECEIPT_TENURE,
        INTEREST_AMOUNT,
        PAYABLE_INDICATOR,
        PAYMENT_AUTHORISATION_DATE,
        PAYMENT_DUE_DATE,
        PAYMENT_NARRATION,
        PAYMENT_REFERENCE_NUMBER,
        PAYMENT_RELEASE_CONFIRMED_INDICATOR,
        PAYMENT_REMARKS,
        POLICY_SECTION_CODE,
        PORTAL_PAYMENT_REFERENCE_NUMBER,
        RESERVE_HEAD_CODE,
        HASHDIFF_CLAIM_PAYMENT_TRANCHE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmpay__sat_aug_claim_payment_tranche') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        TRANCHE_NUMBER,
        AOL_MODE_CODE,
        CASHLESS_CLAIM_TYPE,
        DAMAGE_TYPE_CODE,
        FIXED_DEPOSIT_RECEIPT_FAVOURING_NAME,
        FIXED_DEPOSIT_RECEIPT_TENURE,
        INTEREST_AMOUNT,
        PAYABLE_INDICATOR,
        PAYMENT_AUTHORISATION_DATE,
        PAYMENT_DUE_DATE,
        PAYMENT_NARRATION,
        PAYMENT_REFERENCE_NUMBER,
        PAYMENT_RELEASE_CONFIRMED_INDICATOR,
        PAYMENT_REMARKS,
        POLICY_SECTION_CODE,
        PORTAL_PAYMENT_REFERENCE_NUMBER,
        RESERVE_HEAD_CODE,
        HASHDIFF_CLAIM_PAYMENT_TRANCHE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmpay_payp_pv__sat_aug_claim_payment_tranche') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        TRANCHE_NUMBER,
        AOL_MODE_CODE,
        CASHLESS_CLAIM_TYPE,
        DAMAGE_TYPE_CODE,
        FIXED_DEPOSIT_RECEIPT_FAVOURING_NAME,
        FIXED_DEPOSIT_RECEIPT_TENURE,
        INTEREST_AMOUNT,
        PAYABLE_INDICATOR,
        PAYMENT_AUTHORISATION_DATE,
        PAYMENT_DUE_DATE,
        PAYMENT_NARRATION,
        PAYMENT_REFERENCE_NUMBER,
        PAYMENT_RELEASE_CONFIRMED_INDICATOR,
        PAYMENT_REMARKS,
        POLICY_SECTION_CODE,
        PORTAL_PAYMENT_REFERENCE_NUMBER,
        RESERVE_HEAD_CODE,
        HASHDIFF_CLAIM_PAYMENT_TRANCHE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmrsk_rska_msp_msd_prop_pv__sat_aug_claim_payment_tranche') }}
    where CLAIM_HKEY is not null
