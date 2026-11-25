{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_PARTY: unions the contributing stg2 models and exposes the business key
-- PARTY_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select PARTY_HKEY, PARTY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v03_claim') }}
    where PARTY_BK is not null
union all
    select PARTY_HKEY, PARTY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v06_distribution_channel') }}
    where PARTY_BK is not null
union all
    select PARTY_HKEY, PARTY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v07_location') }}
    where PARTY_BK is not null
union all
    select PARTY_HKEY, PARTY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v09_party') }}
    where PARTY_BK is not null
union all
    select PARTY_HKEY, PARTY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v10_party') }}
    where PARTY_BK is not null
union all
    select PARTY_HKEY, PARTY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v11_party') }}
    where PARTY_BK is not null
union all
    select PARTY_HKEY, PARTY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v12_policy') }}
    where PARTY_BK is not null
union all
    select PARTY_HKEY, PARTY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v14_policy') }}
    where PARTY_BK is not null
