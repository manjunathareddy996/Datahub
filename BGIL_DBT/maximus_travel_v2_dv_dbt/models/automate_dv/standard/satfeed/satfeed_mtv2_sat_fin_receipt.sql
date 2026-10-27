{{ config(materialized='view') }}

-- FEED for SAT_FIN_RECEIPT (target track): unions 3 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 6 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_FIN_RECEIPT to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        FINANCIAL_TRANSACTION_HKEY as FINANCIAL_TRANSACTION_HKEY,
        AMOUNT_RECEIVED as AMOUNT_RECEIVED,
        PAYMENT_GATEWAY_REFERENCE as PAYMENT_GATEWAY_REFERENCE,
        REALISATION_DATE as REALISATION_DATE,
        RECEIPT_DATE as RECEIPT_DATE,
        RECEIPT_NUMBER as RECEIPT_NUMBER,
        RECEIPT_TYPE as RECEIPT_TYPE,
        HASHDIFF_FIN_RECEIPT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_policy_payment_information') }}
    where FINANCIAL_TRANSACTION_HKEY is not null
union all
    select
        FINANCIAL_TRANSACTION_HKEY__POLICY_PREMIUM as FINANCIAL_TRANSACTION_HKEY,
        AMOUNT_RECEIVED as AMOUNT_RECEIVED,
        PAYMENT_GATEWAY_REFERENCE as PAYMENT_GATEWAY_REFERENCE,
        REALISATION_DATE as REALISATION_DATE,
        RECEIPT_DATE as RECEIPT_DATE,
        RECEIPT_NUMBER as RECEIPT_NUMBER,
        RECEIPT_TYPE as RECEIPT_TYPE,
        HASHDIFF_FIN_RECEIPT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where FINANCIAL_TRANSACTION_HKEY__POLICY_PREMIUM is not null
union all
    select
        FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM as FINANCIAL_TRANSACTION_HKEY,
        AMOUNT_RECEIVED as AMOUNT_RECEIVED,
        PAYMENT_GATEWAY_REFERENCE as PAYMENT_GATEWAY_REFERENCE,
        REALISATION_DATE as REALISATION_DATE,
        RECEIPT_DATE as RECEIPT_DATE,
        RECEIPT_NUMBER as RECEIPT_NUMBER,
        RECEIPT_TYPE as RECEIPT_TYPE,
        HASHDIFF_FIN_RECEIPT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }}
    where FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM is not null
