{{ config(materialized='view') }}

-- FEED for SAT_FINTXN_CLAIM_PAYMENT (target track): unions 1 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 5 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_FINTXN_CLAIM_PAYMENT to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT as FINANCIAL_TRANSACTION_HKEY,
        CHEQUE_DATE as CHEQUE_DATE,
        CHEQUE_NUMBER as CHEQUE_NUMBER,
        PAYMENT_DATE as PAYMENT_DATE,
        PAYMENT_MODE as PAYMENT_MODE,
        UTR_NUMBER as UTR_NUMBER,
        HASHDIFF_FINTXN_CLAIM_PAYMENT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmpay_payp_pv') }}
    where FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT is not null
