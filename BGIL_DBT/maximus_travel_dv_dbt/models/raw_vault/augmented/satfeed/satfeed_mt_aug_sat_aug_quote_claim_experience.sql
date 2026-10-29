{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_QUOTE_CLAIM_EXPERIENCE: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        QUOTE_HKEY as QUOTE_HKEY,
        CLAIMS_OUTSTANDING_AMOUNT,
        CLAIMS_PAID_AMOUNT,
        CLAIM_EXPENSES_AMOUNT,
        HASHDIFF_QUOTE_CLAIM_EXPERIENCE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_qpd_polp_msp_imsd_inp_pv__sat_aug_quote_claim_experience') }}
    where QUOTE_HKEY is not null
