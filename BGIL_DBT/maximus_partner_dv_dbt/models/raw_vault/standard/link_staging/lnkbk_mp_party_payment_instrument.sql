{{ config(materialized='view', tags=['lnk_extra']) }}
-- BUILD-SIDE BUSINESS KEYS for LNK_PARTY_PAYMENT_INSTRUMENT (Party Payment Instrument): 1 feeder(s) over 2 hub leg(s).
-- Each feeder is a stg2_mp__ view in which every hub of this link has exactly ONE key slot.
-- The NK columns are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_partner_links_extra.py.
    select PARTY_NK as PARTY_NK, PARTY_BK as PARTY_BK, PAYMENT_INSTRUMENT_NK as PAYMENT_INSTRUMENT_NK, PAYMENT_INSTRUMENT_BK as PAYMENT_INSTRUMENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_msdp_pv') }}
    where PARTY_BK is not null and PAYMENT_INSTRUMENT_BK is not null
