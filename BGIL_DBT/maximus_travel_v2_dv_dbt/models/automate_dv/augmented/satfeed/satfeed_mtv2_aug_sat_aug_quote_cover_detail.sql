{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_QUOTE_COVER_DETAIL: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        QUOTE_HKEY as QUOTE_HKEY,
        COVERAGE_REFERENCE,
        COVERAGE_SEQUENCE,
        BENEFIT_UNIT_IN_HOURS,
        COVER_PERIOD,
        COVER_PREMIUM_AMOUNT,
        COVER_PREMIUM_AMOUNT_IN_BASE_CURRENCY,
        COVER_SUM_INSURED,
        COVER_SUM_INSURED_ACE_VARIANT,
        COVER_SUM_INSURED_FOR_ABROAD_IN_USD,
        COVER_SUM_INSURED_FOR_INDIA_IN_INR,
        PAYOUT_OPTION,
        PRIOR_COVER_PREMIUM_AMOUNT,
        SUB_LIMIT_DETAIL,
        SUM_INSURED_BREAK_UP_DETAIL,
        SUM_INSURED_PER_UNIT,
        TOTAL_COVER_SUM_INSURED,
        TRIP_DELAY_OPTION,
        HASHDIFF_QUOTE_COVER_DETAIL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_rskl_rskc_rskc_prop_rl_pv__sat_aug_quote_cover_detail') }}
    where QUOTE_HKEY is not null
