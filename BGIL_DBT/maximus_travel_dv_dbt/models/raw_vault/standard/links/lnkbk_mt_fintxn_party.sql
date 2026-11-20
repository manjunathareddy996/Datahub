{{ config(materialized='view', tags=['lnk_extra']) }}
-- BUILD-SIDE BUSINESS KEYS for LNK_FINTXN_PARTY (Financial Txn Party): 1 feeder(s) over 2 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select FINANCIAL_TRANSACTION_NK__QUOTE_PREMIUM as FINANCIAL_TRANSACTION_NK, FINANCIAL_TRANSACTION_BK__QUOTE_PREMIUM as FINANCIAL_TRANSACTION_BK, PARTY_NK__POLICYHOLDER as PARTY_NK, PARTY_BK__POLICYHOLDER as PARTY_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd') }}
    where FINANCIAL_TRANSACTION_BK__QUOTE_PREMIUM is not null and PARTY_BK__POLICYHOLDER is not null
