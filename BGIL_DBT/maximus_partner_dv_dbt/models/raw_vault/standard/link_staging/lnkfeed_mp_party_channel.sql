{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_PARTY_CHANNEL: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mp_party_channel for the feeders and generators/gen_partner_links_extra.py for the rule.
    select PARTY_CHANNEL_HKEY as PARTY_CHANNEL_HKEY, PARTY_HKEY as PARTY_HKEY, DISTRIBUTION_CHANNEL_HKEY as DISTRIBUTION_CHANNEL_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_lk__party_channel') }}
    where PARTY_CHANNEL_HKEY is not null
