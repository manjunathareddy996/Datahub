{{ config(materialized='view') }}

-- FEED for SAT_QUOTE_RATING (target track): unions 3 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 6 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_QUOTE_RATING to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        QUOTE_HKEY as QUOTE_HKEY,
        BASE_PREMIUM as BASE_PREMIUM,
        DISCOUNT_AMOUNT as DISCOUNT_AMOUNT,
        GROSS_PREMIUM as GROSS_PREMIUM,
        LOADING_AMOUNT as LOADING_AMOUNT,
        NET_PREMIUM as NET_PREMIUM,
        PREMIUM_FREQUENCY as PREMIUM_FREQUENCY,
        HASHDIFF_QUOTE_RATING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd') }}
    where QUOTE_HKEY is not null
union all
    select
        QUOTE_HKEY as QUOTE_HKEY,
        BASE_PREMIUM as BASE_PREMIUM,
        DISCOUNT_AMOUNT as DISCOUNT_AMOUNT,
        GROSS_PREMIUM as GROSS_PREMIUM,
        LOADING_AMOUNT as LOADING_AMOUNT,
        NET_PREMIUM as NET_PREMIUM,
        PREMIUM_FREQUENCY as PREMIUM_FREQUENCY,
        HASHDIFF_QUOTE_RATING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
    where QUOTE_HKEY is not null
union all
    select
        QUOTE_HKEY as QUOTE_HKEY,
        BASE_PREMIUM as BASE_PREMIUM,
        DISCOUNT_AMOUNT as DISCOUNT_AMOUNT,
        GROSS_PREMIUM as GROSS_PREMIUM,
        LOADING_AMOUNT as LOADING_AMOUNT,
        NET_PREMIUM as NET_PREMIUM,
        PREMIUM_FREQUENCY as PREMIUM_FREQUENCY,
        HASHDIFF_QUOTE_RATING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
    where QUOTE_HKEY is not null
