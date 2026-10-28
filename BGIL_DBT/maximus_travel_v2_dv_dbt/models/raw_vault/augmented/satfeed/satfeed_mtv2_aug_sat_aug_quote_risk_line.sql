{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_QUOTE_RISK_LINE: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        QUOTE_HKEY as QUOTE_HKEY,
        BILLING_STAKE_CODE,
        DISCOUNT_AMOUNT,
        LOADING_AMOUNT,
        RISK_EXPIRY_DATE,
        RISK_INCEPTION_DATE,
        HASHDIFF_QUOTE_RISK_LINE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_rskl__sat_aug_quote_risk_line') }}
    where QUOTE_HKEY is not null
