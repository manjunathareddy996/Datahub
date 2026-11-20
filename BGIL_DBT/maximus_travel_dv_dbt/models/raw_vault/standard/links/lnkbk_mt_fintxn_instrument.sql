{{ config(materialized='view') }}
-- BUILD-SIDE BUSINESS KEYS for LNK_FINTXN_INSTRUMENT (Financial Txn Instrument): 2 feeder(s) over 2 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select FINANCIAL_TRANSACTION_NK__CLAIM_PAYMENT as FINANCIAL_TRANSACTION_NK, FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT as FINANCIAL_TRANSACTION_BK, PAYMENT_INSTRUMENT_NK__PAYEE_BANK_ACCOUNT as PAYMENT_INSTRUMENT_NK, PAYMENT_INSTRUMENT_BK__PAYEE_BANK_ACCOUNT as PAYMENT_INSTRUMENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmpay_payp_pv') }}
    where FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT is not null and PAYMENT_INSTRUMENT_BK__PAYEE_BANK_ACCOUNT is not null
union all
    select FINANCIAL_TRANSACTION_NK as FINANCIAL_TRANSACTION_NK, FINANCIAL_TRANSACTION_BK as FINANCIAL_TRANSACTION_BK, PAYMENT_INSTRUMENT_NK as PAYMENT_INSTRUMENT_NK, PAYMENT_INSTRUMENT_BK as PAYMENT_INSTRUMENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_policy_payment_information') }}
    where FINANCIAL_TRANSACTION_BK is not null and PAYMENT_INSTRUMENT_BK is not null
