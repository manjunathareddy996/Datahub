{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_POLICY_CHANNEL: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mp_policy_channel for the feeders and generators/gen_partner_links_extra.py for the rule.
    select POLICY_CHANNEL_HKEY as POLICY_CHANNEL_HKEY, POLICY_HKEY as POLICY_HKEY, DISTRIBUTION_CHANNEL_HKEY as DISTRIBUTION_CHANNEL_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_lk__policy_channel') }}
    where POLICY_CHANNEL_HKEY is not null
