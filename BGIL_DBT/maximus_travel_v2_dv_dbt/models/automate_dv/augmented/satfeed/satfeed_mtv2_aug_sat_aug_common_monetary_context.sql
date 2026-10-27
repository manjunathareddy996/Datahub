{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_COMMON_MONETARY_CONTEXT: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM as FINANCIAL_TRANSACTION_HKEY,
        BASE_CURRENCY_EXCHANGE_RATE,
        HASHDIFF_COMMON_MONETARY_CONTEXT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd__sat_aug_common_monetary_context') }}
    where FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM is not null
