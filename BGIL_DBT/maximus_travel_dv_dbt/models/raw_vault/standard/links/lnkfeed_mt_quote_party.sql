{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_QUOTE_PARTY: 3 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_quote_party for the feeders and generators/gen_mt_links_extra.py for the rule.
    select QUOTE_PARTY_HKEY as QUOTE_PARTY_HKEY, QUOTE_HKEY as QUOTE_HKEY, PARTY_HKEY as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__quote_party') }}
    where QUOTE_PARTY_HKEY is not null
