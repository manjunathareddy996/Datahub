{{ config(materialized='view') }}
-- FEED for LNK_RISK_OBJECT_LOCATION: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_risk_object_location for the feeders and generators/gen_mt_links_extra.py for the rule.
    select RISK_OBJECT_LOCATION_HKEY as RISK_OBJECT_LOCATION_HKEY, RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, LOCATION_HKEY as LOCATION_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__risk_object_location') }}
    where RISK_OBJECT_LOCATION_HKEY is not null
