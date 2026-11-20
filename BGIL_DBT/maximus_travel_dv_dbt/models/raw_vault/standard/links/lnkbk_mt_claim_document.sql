{{ config(materialized='view', tags=['lnk_extra']) }}
-- BUILD-SIDE BUSINESS KEYS for LNK_CLAIM_DOCUMENT (Claim Document): 2 feeder(s) over 2 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select CLAIM_NK as CLAIM_NK, CLAIM_BK as CLAIM_BK, DOCUMENT_NK__CLAIM_INWARD_DOCUMENT_SET as DOCUMENT_NK, DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET as DOCUMENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clma_msp_msd_prop_pv') }}
    where CLAIM_BK is not null and DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET is not null
union all
    select CLAIM_NK as CLAIM_NK, CLAIM_BK as CLAIM_BK, DOCUMENT_NK as DOCUMENT_NK, DOCUMENT_BK as DOCUMENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmcov_msd_prop_pv') }}
    where CLAIM_BK is not null and DOCUMENT_BK is not null
