{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_CLAIM_POLICY: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_claim_policy for the feeders and generators/gen_mt_links_extra.py for the rule.
    select CLAIM_POLICY_HKEY as CLAIM_POLICY_HKEY, CLAIM_HKEY as CLAIM_HKEY, POLICY_HKEY as POLICY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__claim_policy') }}
    where CLAIM_POLICY_HKEY is not null
