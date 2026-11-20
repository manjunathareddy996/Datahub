{{ config(materialized='view') }}
-- FEED for LNK_QUOTE_RISK_OBJECT: 4 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_quote_risk_object for the feeders and generators/gen_mt_links_extra.py for the rule.
    select QUOTE_RISK_OBJECT_HKEY as QUOTE_RISK_OBJECT_HKEY, QUOTE_HKEY as QUOTE_HKEY, RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__quote_risk_object') }}
    where QUOTE_RISK_OBJECT_HKEY is not null
