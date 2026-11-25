{{ config(materialized='view', tags=['lnk_extra']) }}
-- BUILD-SIDE BUSINESS KEYS for LNK_POLICY_CHANNEL (Policy Channel): 1 feeder(s) over 2 hub leg(s).
-- Each feeder is a stg2_mp__ view in which every hub of this link has exactly ONE key slot.
-- The NK columns are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_partner_links_extra.py.
    select POLICY_NK as POLICY_NK, POLICY_BK as POLICY_BK, DISTRIBUTION_CHANNEL_NK as DISTRIBUTION_CHANNEL_NK, DISTRIBUTION_CHANNEL_BK as DISTRIBUTION_CHANNEL_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_sp_pv') }}
    where POLICY_BK is not null and DISTRIBUTION_CHANNEL_BK is not null
