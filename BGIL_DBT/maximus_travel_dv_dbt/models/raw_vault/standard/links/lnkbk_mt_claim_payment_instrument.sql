{{ config(materialized='view') }}
-- BUILD-SIDE BUSINESS KEYS for LNK_CLAIM_PAYMENT_INSTRUMENT (Claim Payment Instrument): 1 feeder(s) over 2 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select CLAIM_NK as CLAIM_NK, CLAIM_BK as CLAIM_BK, PAYMENT_INSTRUMENT_NK__PAYEE_BANK_ACCOUNT as PAYMENT_INSTRUMENT_NK, PAYMENT_INSTRUMENT_BK__PAYEE_BANK_ACCOUNT as PAYMENT_INSTRUMENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmpay_payp_pv') }}
    where CLAIM_BK is not null and PAYMENT_INSTRUMENT_BK__PAYEE_BANK_ACCOUNT is not null
