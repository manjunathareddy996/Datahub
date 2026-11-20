{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_POLICY_COVERAGE_RISK: 1 feeder(s) over 3 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_policy_coverage_risk for the feeders and generators/gen_mt_links_extra.py for the rule.
    select POLICY_COVERAGE_RISK_HKEY as POLICY_COVERAGE_RISK_HKEY, POLICY_HKEY as POLICY_HKEY, COVERAGE_HKEY as COVERAGE_HKEY, RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__policy_coverage_risk') }}
    where POLICY_COVERAGE_RISK_HKEY is not null
