{{ config(materialized='view', tags=['lnk_extra']) }}
-- BUILD-SIDE BUSINESS KEYS for LNK_POLICY_ORG_UNIT (Policy Org Unit): 1 feeder(s) over 2 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select POLICY_NK as POLICY_NK, POLICY_BK as POLICY_BK, ORG_UNIT_NK as ORG_UNIT_NK, ORG_UNIT_BK as ORG_UNIT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol') }}
    where POLICY_BK is not null and ORG_UNIT_BK is not null
