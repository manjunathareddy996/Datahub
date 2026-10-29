{{ config(materialized='view') }}

-- FEED for SAT_QUOTE_RATING_INPUT (target track): unions 5 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 3 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_QUOTE_RATING_INPUT to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        QUOTE_HKEY as QUOTE_HKEY,
        FACTOR_CODE as FACTOR_CODE,
        FACTOR_VALUE as FACTOR_VALUE,
        PREMIUM_IMPACT as PREMIUM_IMPACT,
        RELATIVITY_APPLIED as RELATIVITY_APPLIED,
        HASHDIFF_QUOTE_RATING_INPUT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_up__uwr_qpd_polp_msp_imsd_inp_pv__sat_quote_rating_input') }}
    where QUOTE_HKEY is not null
union all
    select
        QUOTE_HKEY as QUOTE_HKEY,
        FACTOR_CODE as FACTOR_CODE,
        FACTOR_VALUE as FACTOR_VALUE,
        PREMIUM_IMPACT as PREMIUM_IMPACT,
        RELATIVITY_APPLIED as RELATIVITY_APPLIED,
        HASHDIFF_QUOTE_RATING_INPUT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_up__uwr_qpd_polp_rl_pv__sat_quote_rating_input') }}
    where QUOTE_HKEY is not null
union all
    select
        QUOTE_HKEY as QUOTE_HKEY,
        FACTOR_CODE as FACTOR_CODE,
        FACTOR_VALUE as FACTOR_VALUE,
        PREMIUM_IMPACT as PREMIUM_IMPACT,
        RELATIVITY_APPLIED as RELATIVITY_APPLIED,
        HASHDIFF_QUOTE_RATING_INPUT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_msp_imsd_inp_pv') }}
    where QUOTE_HKEY is not null
union all
    select
        QUOTE_HKEY as QUOTE_HKEY,
        FACTOR_CODE as FACTOR_CODE,
        FACTOR_VALUE as FACTOR_VALUE,
        PREMIUM_IMPACT as PREMIUM_IMPACT,
        RELATIVITY_APPLIED as RELATIVITY_APPLIED,
        HASHDIFF_QUOTE_RATING_INPUT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskc_rskc_prop_rl_pv') }}
    where QUOTE_HKEY is not null
union all
    select
        QUOTE_HKEY as QUOTE_HKEY,
        FACTOR_CODE as FACTOR_CODE,
        FACTOR_VALUE as FACTOR_VALUE,
        PREMIUM_IMPACT as PREMIUM_IMPACT,
        RELATIVITY_APPLIED as RELATIVITY_APPLIED,
        HASHDIFF_QUOTE_RATING_INPUT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
    where QUOTE_HKEY is not null
