{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_FINTXN_CLAIM_PAYMENT: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT as FINANCIAL_TRANSACTION_HKEY,
        INSTRUMENT_PAYABLE_AT_LOCATION,
        INSTRUMENT_PRINT_LOCATION_CODE,
        NEFT_APPROVAL_REFERENCE,
        HASHDIFF_FINTXN_CLAIM_PAYMENT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmpay_payp_pv__sat_aug_fintxn_claim_payment') }}
    where FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT is not null
