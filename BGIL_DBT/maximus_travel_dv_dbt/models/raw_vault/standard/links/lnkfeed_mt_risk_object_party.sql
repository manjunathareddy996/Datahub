{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_RISK_OBJECT_PARTY: 2 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_risk_object_party for the feeders and generators/gen_mt_links_extra.py for the rule.
    select RISK_OBJECT_PARTY_HKEY as RISK_OBJECT_PARTY_HKEY, RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, PARTY_HKEY as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__risk_object_party') }}
    where RISK_OBJECT_PARTY_HKEY is not null
