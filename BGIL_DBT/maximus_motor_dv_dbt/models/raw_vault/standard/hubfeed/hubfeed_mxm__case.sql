{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_CASE: unions the contributing stg2 models and exposes the business key
-- CASE_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select CASE_HKEY, CASE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v02_case') }}
    where CASE_BK is not null
