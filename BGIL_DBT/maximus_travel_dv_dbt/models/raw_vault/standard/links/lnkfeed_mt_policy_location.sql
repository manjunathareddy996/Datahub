{{ config(materialized='view') }}
-- FEED for LNK_POLICY_LOCATION: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_policy_location for the feeders and generators/gen_mt_links_extra.py for the rule.
    select POLICY_LOCATION_HKEY as POLICY_LOCATION_HKEY, POLICY_HKEY as POLICY_HKEY, LOCATION_HKEY as LOCATION_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__policy_location') }}
    where POLICY_LOCATION_HKEY is not null
