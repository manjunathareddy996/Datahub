{{ config(materialized='view') }}

-- FEED for SAT_INSTRUMENT_DEFINITION (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 5 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_INSTRUMENT_DEFINITION to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PAYMENT_INSTRUMENT_HKEY__PAYEE_BANK_ACCOUNT as PAYMENT_INSTRUMENT_HKEY,
        ACCOUNT_TYPE as ACCOUNT_TYPE,
        BANK_NAME as BANK_NAME,
        INSTRUMENT_STATUS as INSTRUMENT_STATUS,
        ACCOUNT_CATEGORY_CODE as ACCOUNT_CATEGORY_CODE,
        BANK_BRANCH_CODE as BANK_BRANCH_CODE,
        HASHDIFF_INSTRUMENT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmpay_payp_pv') }}
    where PAYMENT_INSTRUMENT_HKEY__PAYEE_BANK_ACCOUNT is not null
union all
    select
        PAYMENT_INSTRUMENT_HKEY as PAYMENT_INSTRUMENT_HKEY,
        ACCOUNT_TYPE as ACCOUNT_TYPE,
        BANK_NAME as BANK_NAME,
        INSTRUMENT_STATUS as INSTRUMENT_STATUS,
        ACCOUNT_CATEGORY_CODE as ACCOUNT_CATEGORY_CODE,
        BANK_BRANCH_CODE as BANK_BRANCH_CODE,
        HASHDIFF_INSTRUMENT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_policy_payment_information') }}
    where PAYMENT_INSTRUMENT_HKEY is not null
