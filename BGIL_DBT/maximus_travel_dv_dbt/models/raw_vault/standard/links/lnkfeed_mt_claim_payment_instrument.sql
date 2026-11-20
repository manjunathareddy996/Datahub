{{ config(materialized='view') }}
-- FEED for LNK_CLAIM_PAYMENT_INSTRUMENT: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_claim_payment_instrument for the feeders and generators/gen_mt_links_extra.py for the rule.
    select CLAIM_PAYMENT_INSTRUMENT_HKEY as CLAIM_PAYMENT_INSTRUMENT_HKEY, CLAIM_HKEY as CLAIM_HKEY, PAYMENT_INSTRUMENT_HKEY as PAYMENT_INSTRUMENT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__claim_payment_instrument') }}
    where CLAIM_PAYMENT_INSTRUMENT_HKEY is not null
