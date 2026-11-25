{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_LOCATION: unions the contributing stg2 models and exposes the business key
-- LOCATION_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select LOCATION_HKEY, LOCATION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v08_location') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY, LOCATION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v09_party') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY, LOCATION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v12_policy') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY, LOCATION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v14_risk_object') }}
    where LOCATION_BK is not null
