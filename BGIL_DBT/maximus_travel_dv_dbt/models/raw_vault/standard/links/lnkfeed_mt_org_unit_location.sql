{{ config(materialized='view') }}
-- FEED for LNK_ORG_UNIT_LOCATION: 2 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_org_unit_location for the feeders and generators/gen_mt_links_extra.py for the rule.
    select ORG_UNIT_LOCATION_HKEY as ORG_UNIT_LOCATION_HKEY, ORG_UNIT_HKEY as ORG_UNIT_HKEY, LOCATION_HKEY as LOCATION_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__org_unit_location') }}
    where ORG_UNIT_LOCATION_HKEY is not null
