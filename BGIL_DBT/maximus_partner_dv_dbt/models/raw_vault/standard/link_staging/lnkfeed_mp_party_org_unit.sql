{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_PARTY_ORG_UNIT: 2 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mp_party_org_unit for the feeders and generators/gen_partner_links_extra.py for the rule.
    select PARTY_ORG_UNIT_HKEY as PARTY_ORG_UNIT_HKEY, PARTY_HKEY as PARTY_HKEY, ORG_UNIT_HKEY as ORG_UNIT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_lk__party_org_unit') }}
    where PARTY_ORG_UNIT_HKEY is not null
