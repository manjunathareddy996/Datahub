{{ config(materialized='view') }}

-- FEED for SAT_COMMON_MONETARY_CONTEXT (target track): unions 4 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 4 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_COMMON_MONETARY_CONTEXT to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        FINANCIAL_TRANSACTION_HKEY__POLICY_PREMIUM as FINANCIAL_TRANSACTION_HKEY,
        BASE_CURRENCY_CODE as BASE_CURRENCY_CODE,
        CURRENCY_CODE as CURRENCY_CODE,
        EXCHANGE_RATE as EXCHANGE_RATE,
        BASE_CURRENCY_EXCHANGE_RATE as BASE_CURRENCY_EXCHANGE_RATE,
        HASHDIFF_COMMON_MONETARY_CONTEXT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where FINANCIAL_TRANSACTION_HKEY__POLICY_PREMIUM is not null
union all
    select
        FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM as FINANCIAL_TRANSACTION_HKEY,
        BASE_CURRENCY_CODE as BASE_CURRENCY_CODE,
        CURRENCY_CODE as CURRENCY_CODE,
        EXCHANGE_RATE as EXCHANGE_RATE,
        BASE_CURRENCY_EXCHANGE_RATE as BASE_CURRENCY_EXCHANGE_RATE,
        HASHDIFF_COMMON_MONETARY_CONTEXT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd') }}
    where FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM is not null
union all
    select
        FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM as FINANCIAL_TRANSACTION_HKEY,
        BASE_CURRENCY_CODE as BASE_CURRENCY_CODE,
        CURRENCY_CODE as CURRENCY_CODE,
        EXCHANGE_RATE as EXCHANGE_RATE,
        BASE_CURRENCY_EXCHANGE_RATE as BASE_CURRENCY_EXCHANGE_RATE,
        HASHDIFF_COMMON_MONETARY_CONTEXT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }}
    where FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM is not null
union all
    select
        FINANCIAL_TRANSACTION_HKEY__QUOTE_RISK_PREMIUM as FINANCIAL_TRANSACTION_HKEY,
        BASE_CURRENCY_CODE as BASE_CURRENCY_CODE,
        CURRENCY_CODE as CURRENCY_CODE,
        EXCHANGE_RATE as EXCHANGE_RATE,
        BASE_CURRENCY_EXCHANGE_RATE as BASE_CURRENCY_EXCHANGE_RATE,
        HASHDIFF_COMMON_MONETARY_CONTEXT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl') }}
    where FINANCIAL_TRANSACTION_HKEY__QUOTE_RISK_PREMIUM is not null
