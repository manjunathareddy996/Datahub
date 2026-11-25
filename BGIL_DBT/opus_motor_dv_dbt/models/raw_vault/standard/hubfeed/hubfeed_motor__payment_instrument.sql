{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_PAYMENT_INSTRUMENT: unions the contributing stg2 models and exposes the business key
-- PAYMENT_INSTRUMENT_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select PAYMENT_INSTRUMENT_HKEY, PAYMENT_INSTRUMENT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v06_distribution_channel') }}
    where PAYMENT_INSTRUMENT_BK is not null
