{{ config(materialized='view') }}
-- BUILD-SIDE BUSINESS KEYS for LNK_QUOTE_PARTY (Quote Party): 3 feeder(s) over 2 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select QUOTE_NK as QUOTE_NK, QUOTE_BK as QUOTE_BK, PARTY_NK__POLICYHOLDER as PARTY_NK, PARTY_BK__POLICYHOLDER as PARTY_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd') }}
    where QUOTE_BK is not null and PARTY_BK__POLICYHOLDER is not null
union all
    select QUOTE_NK as QUOTE_NK, QUOTE_BK as QUOTE_BK, PARTY_NK__NOMINEE as PARTY_NK, PARTY_BK__NOMINEE as PARTY_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_msp_imsd_inp_pv') }}
    where QUOTE_BK is not null and PARTY_BK__NOMINEE is not null
union all
    select QUOTE_NK as QUOTE_NK, QUOTE_BK as QUOTE_BK, PARTY_NK__POLICYHOLDER as PARTY_NK, PARTY_BK__POLICYHOLDER as PARTY_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
    where QUOTE_BK is not null and PARTY_BK__POLICYHOLDER is not null
