{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_POLICY_PARTY: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mp_policy_party for the feeders and generators/gen_partner_links_extra.py for the rule.
    select POLICY_PARTY_HKEY as POLICY_PARTY_HKEY, POLICY_HKEY as POLICY_HKEY, PARTY_HKEY as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_lk__policy_party') }}
    where POLICY_PARTY_HKEY is not null
