{{ config(materialized='view') }}
-- FEED for LNK_FINTXN_PARTY: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_fintxn_party for the feeders and generators/gen_mt_links_extra.py for the rule.
    select FINTXN_PARTY_HKEY as FINTXN_PARTY_HKEY, FINANCIAL_TRANSACTION_HKEY as FINANCIAL_TRANSACTION_HKEY, PARTY_HKEY as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__fintxn_party') }}
    where FINTXN_PARTY_HKEY is not null
