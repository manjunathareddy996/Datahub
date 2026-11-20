{{ config(materialized='view') }}
-- FEED for LNK_FINTXN_CLAIM: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_fintxn_claim for the feeders and generators/gen_mt_links_extra.py for the rule.
    select FINTXN_CLAIM_HKEY as FINTXN_CLAIM_HKEY, FINANCIAL_TRANSACTION_HKEY as FINANCIAL_TRANSACTION_HKEY, CLAIM_HKEY as CLAIM_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__fintxn_claim') }}
    where FINTXN_CLAIM_HKEY is not null
