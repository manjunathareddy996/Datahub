{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_PROVIDER_BILLING: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        BILL_NUMBER,
        ADMISSIBLE_AMOUNT_IN_INR,
        APPLICABLE_TERM_END_DATE,
        APPLICABLE_TERM_START_DATE,
        ASSISTANCE_COMPANY_REPRICING_DISCOUNT_AMOUNT,
        BALANCE_SUM_INSURED_AMOUNT,
        BILLED_AMOUNT_IN_BILL_CURRENCY,
        BILL_AMOUNT_BREAKUP,
        BILL_CURRENCY_CODE,
        BILL_DISCOUNT_AMOUNT,
        BILL_LINE_PARTICULARS,
        BILL_PAYABLE_REASON,
        DEDUCTION_AMOUNT_IN_SUM_INSURED_CURRENCY,
        DISALLOWANCE_BREAKUP,
        EXCHANGE_RATE_APPLICABLE_DATE,
        EXCHANGE_RATE_TO_INR,
        EXCHANGE_RATE_TO_POLICY_SUM_INSURED_CURRENCY,
        FINAL_ADMISSIBLE_AMOUNT_IN_BILL_CURRENCY,
        FINAL_ADMISSIBLE_AMOUNT_IN_POLICY_SUM_INSURED_CURRENCY,
        NON_ADMISSIBLE_AMOUNT,
        NON_ADMISSIBLE_REMARKS,
        PROVIDER_FACILITY_NAME,
        REVIEWED_AMOUNT,
        REVIEW_DESCRIPTION,
        HASHDIFF_CLAIM_PROVIDER_BILLING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmrsk_rska_msp_msd_prop_pv__sat_aug_claim_provider_billing') }}
    where CLAIM_HKEY is not null
