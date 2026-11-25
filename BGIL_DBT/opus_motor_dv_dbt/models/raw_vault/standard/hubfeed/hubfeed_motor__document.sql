{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_DOCUMENT: unions the contributing stg2 models and exposes the business key
-- DOCUMENT_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select DOCUMENT_HKEY, DOCUMENT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v02_claim') }}
    where DOCUMENT_BK is not null
