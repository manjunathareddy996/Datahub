{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_AGREEMENT: unions the contributing stg2 models and exposes the business key
-- AGREEMENT_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select AGREEMENT_HKEY, AGREEMENT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v12_policy') }}
    where AGREEMENT_BK is not null
