{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_CHANNEL_ORG_UNIT: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mp_channel_org_unit for the feeders and generators/gen_partner_links_extra.py for the rule.
    select CHANNEL_ORG_UNIT_HKEY as CHANNEL_ORG_UNIT_HKEY, DISTRIBUTION_CHANNEL_HKEY as DISTRIBUTION_CHANNEL_HKEY, ORG_UNIT_HKEY as ORG_UNIT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_lk__channel_org_unit') }}
    where CHANNEL_ORG_UNIT_HKEY is not null
