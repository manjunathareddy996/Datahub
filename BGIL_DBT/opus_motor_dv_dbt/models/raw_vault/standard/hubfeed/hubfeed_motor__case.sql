{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_CASE: unions the contributing stg2 models and exposes the business key
-- CASE_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select CASE_HKEY, CASE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v02_claim') }}
    where CASE_BK is not null
union all
    select CASE_HKEY, CASE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v03_claim') }}
    where CASE_BK is not null
union all
    select CASE_HKEY, CASE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v09_party') }}
    where CASE_BK is not null
union all
    select CASE_HKEY, CASE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v11_party') }}
    where CASE_BK is not null
union all
    select CASE_HKEY, CASE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v13_policy') }}
    where CASE_BK is not null
