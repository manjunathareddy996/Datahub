{{ config(materialized='view', tags=['lnk_extra']) }}
-- BUILD-SIDE BUSINESS KEYS for LNK_PARTY_DOCUMENT (Party Document): 1 feeder(s) over 2 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select PARTY_NK__POLICYHOLDER as PARTY_NK, PARTY_BK__POLICYHOLDER as PARTY_BK, DOCUMENT_NK as DOCUMENT_NK, DOCUMENT_BK as DOCUMENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd') }}
    where PARTY_BK__POLICYHOLDER is not null and DOCUMENT_BK is not null
