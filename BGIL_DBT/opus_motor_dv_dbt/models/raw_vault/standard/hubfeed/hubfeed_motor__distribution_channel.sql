{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_DISTRIBUTION_CHANNEL: unions the contributing stg2 models and exposes the business key
-- DISTRIBUTION_CHANNEL_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v06_distribution_channel') }}
    where DISTRIBUTION_CHANNEL_BK is not null
union all
    select DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v09_party') }}
    where DISTRIBUTION_CHANNEL_BK is not null
union all
    select DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v11_party') }}
    where DISTRIBUTION_CHANNEL_BK is not null
union all
    select DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v12_policy') }}
    where DISTRIBUTION_CHANNEL_BK is not null
union all
    select DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v14_policy') }}
    where DISTRIBUTION_CHANNEL_BK is not null
union all
    select DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v16_policy') }}
    where DISTRIBUTION_CHANNEL_BK is not null
