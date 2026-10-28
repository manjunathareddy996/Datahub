{{ config(materialized='view') }}

-- FEED for HUB_PAYMENT_INSTRUMENT: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 2 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_PAYMENT_INSTRUMENT|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mtv2_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select PAYMENT_INSTRUMENT_HKEY__PAYEE_BANK_ACCOUNT as PAYMENT_INSTRUMENT_HKEY, PAYMENT_INSTRUMENT_BK__PAYEE_BANK_ACCOUNT as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmpay_payp_pv') }}
    where PAYMENT_INSTRUMENT_BK__PAYEE_BANK_ACCOUNT is not null
union all
    select PAYMENT_INSTRUMENT_HKEY as PAYMENT_INSTRUMENT_HKEY, PAYMENT_INSTRUMENT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_policy_payment_information') }}
    where PAYMENT_INSTRUMENT_BK is not null
