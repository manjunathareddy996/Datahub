{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_POLICY_ORG_UNIT: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_policy_org_unit for the feeders and generators/gen_mt_links_extra.py for the rule.
    select POLICY_ORG_UNIT_HKEY as POLICY_ORG_UNIT_HKEY, POLICY_HKEY as POLICY_HKEY, ORG_UNIT_HKEY as ORG_UNIT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__policy_org_unit') }}
    where POLICY_ORG_UNIT_HKEY is not null
