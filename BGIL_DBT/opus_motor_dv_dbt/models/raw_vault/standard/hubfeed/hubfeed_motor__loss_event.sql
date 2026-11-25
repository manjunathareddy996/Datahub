{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_LOSS_EVENT: unions the contributing stg2 models and exposes the business key
-- LOSS_EVENT_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select LOSS_EVENT_HKEY, LOSS_EVENT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v01_claim') }}
    where LOSS_EVENT_BK is not null
union all
    select LOSS_EVENT_HKEY, LOSS_EVENT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v02_claim') }}
    where LOSS_EVENT_BK is not null
