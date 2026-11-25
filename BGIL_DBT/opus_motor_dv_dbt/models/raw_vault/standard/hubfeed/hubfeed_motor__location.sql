{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_LOCATION: unions the contributing stg2 models and exposes the business key
-- LOCATION_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select LOCATION_HKEY, LOCATION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v06_distribution_channel') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY, LOCATION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v07_location') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY, LOCATION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v08_org_unit') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY, LOCATION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v10_party') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY, LOCATION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v11_party') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY, LOCATION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v12_policy') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY, LOCATION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v15_policy') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY, LOCATION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v22_quote') }}
    where LOCATION_BK is not null
