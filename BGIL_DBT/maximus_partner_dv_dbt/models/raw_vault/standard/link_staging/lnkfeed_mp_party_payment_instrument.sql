{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_PARTY_PAYMENT_INSTRUMENT: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mp_party_payment_instrument for the feeders and generators/gen_partner_links_extra.py for the rule.
    select PARTY_PAYMENT_INSTRUMENT_HKEY as PARTY_PAYMENT_INSTRUMENT_HKEY, PARTY_HKEY as PARTY_HKEY, PAYMENT_INSTRUMENT_HKEY as PAYMENT_INSTRUMENT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_lk__party_payment_instrument') }}
    where PARTY_PAYMENT_INSTRUMENT_HKEY is not null
