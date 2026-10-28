{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_INSTRUMENT_DEFINITION: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        PAYMENT_INSTRUMENT_HKEY__PAYEE_BANK_ACCOUNT as PAYMENT_INSTRUMENT_HKEY,
        ACCOUNT_CATEGORY_CODE,
        BANK_BRANCH_CODE,
        HASHDIFF_INSTRUMENT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmpay_payp_pv__sat_aug_instrument_definition') }}
    where PAYMENT_INSTRUMENT_HKEY__PAYEE_BANK_ACCOUNT is not null
