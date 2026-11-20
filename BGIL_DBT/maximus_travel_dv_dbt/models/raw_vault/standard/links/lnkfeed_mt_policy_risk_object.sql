{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_POLICY_RISK_OBJECT: 2 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_policy_risk_object for the feeders and generators/gen_mt_links_extra.py for the rule.
    select POLICY_RISK_OBJECT_HKEY as POLICY_RISK_OBJECT_HKEY, POLICY_HKEY as POLICY_HKEY, RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__policy_risk_object') }}
    where POLICY_RISK_OBJECT_HKEY is not null
