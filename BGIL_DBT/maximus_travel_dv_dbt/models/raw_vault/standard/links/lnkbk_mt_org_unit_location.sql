{{ config(materialized='view', tags=['lnk_extra']) }}
-- BUILD-SIDE BUSINESS KEYS for LNK_ORG_UNIT_LOCATION (Org Unit Location): 2 feeder(s) over 2 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select ORG_UNIT_NK__OFFICE_ADDRESS as ORG_UNIT_NK, ORG_UNIT_BK__OFFICE_ADDRESS as ORG_UNIT_BK, LOCATION_NK__OFFICE_ADDRESS as LOCATION_NK, LOCATION_BK__OFFICE_ADDRESS as LOCATION_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_off_oa') }}
    where ORG_UNIT_BK__OFFICE_ADDRESS is not null and LOCATION_BK__OFFICE_ADDRESS is not null
union all
    select ORG_UNIT_NK as ORG_UNIT_NK, ORG_UNIT_BK as ORG_UNIT_BK, LOCATION_NK as LOCATION_NK, LOCATION_BK as LOCATION_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_off_oa_address_prop_pv') }}
    where ORG_UNIT_BK is not null and LOCATION_BK is not null
