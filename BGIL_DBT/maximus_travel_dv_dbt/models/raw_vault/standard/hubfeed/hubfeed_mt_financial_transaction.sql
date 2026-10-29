{{ config(materialized='view') }}

-- FEED for HUB_FINANCIAL_TRANSACTION: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 10 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_FINANCIAL_TRANSACTION|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mt_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT as FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmpay_payp_pv') }}
    where FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT is not null
union all
    select FINANCIAL_TRANSACTION_HKEY__CLAIM_BILL_INVOICE as FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK__CLAIM_BILL_INVOICE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where FINANCIAL_TRANSACTION_BK__CLAIM_BILL_INVOICE is not null
union all
    select FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT as FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT is not null
union all
    select FINANCIAL_TRANSACTION_HKEY as FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_policy_payment_information') }}
    where FINANCIAL_TRANSACTION_BK is not null
union all
    select FINANCIAL_TRANSACTION_HKEY__POLICY_PREMIUM as FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK__POLICY_PREMIUM as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
    where FINANCIAL_TRANSACTION_BK__POLICY_PREMIUM is not null
union all
    select FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM as FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK__QUOTE_PREMIUM as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd') }}
    where FINANCIAL_TRANSACTION_BK__QUOTE_PREMIUM is not null
union all
    select FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM as FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK__QUOTE_PREMIUM as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
    where FINANCIAL_TRANSACTION_BK__QUOTE_PREMIUM is not null
union all
    select FINANCIAL_TRANSACTION_HKEY__QUOTE_RISK_PREMIUM as FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK__QUOTE_RISK_PREMIUM as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl') }}
    where FINANCIAL_TRANSACTION_BK__QUOTE_RISK_PREMIUM is not null
union all
    select FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT as FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_up__clm_clmd_clmpay_payp_pv__sat_fintxn_tax') }}
    where FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT is not null
union all
    select FINANCIAL_TRANSACTION_HKEY__CLAIM_BILL_INVOICE as FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK__CLAIM_BILL_INVOICE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_up__clm_clmd_clmrsk_rska_msp_msd_prop_pv__sat_fintxn_tax') }}
    where FINANCIAL_TRANSACTION_BK__CLAIM_BILL_INVOICE is not null
