{{ config(materialized='view', tags=['lnk_extra']) }}
-- BUILD-SIDE BUSINESS KEYS for LNK_POLICY_LOCATION (Policy Risk Location): 1 feeder(s) over 2 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select POLICY_NK as POLICY_NK, POLICY_BK as POLICY_BK, LOCATION_NK as LOCATION_NK, LOCATION_BK as LOCATION_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_disp') }}
    where POLICY_BK is not null and LOCATION_BK is not null
