{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_FINTXN_INSTRUMENT: 2 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_fintxn_instrument for the feeders and generators/gen_mt_links_extra.py for the rule.
    select FINTXN_INSTRUMENT_HKEY as FINTXN_INSTRUMENT_HKEY, FINANCIAL_TRANSACTION_HKEY as FINANCIAL_TRANSACTION_HKEY, PAYMENT_INSTRUMENT_HKEY as PAYMENT_INSTRUMENT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__fintxn_instrument') }}
    where FINTXN_INSTRUMENT_HKEY is not null
