{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_ORG_UNIT: unions the contributing stg2 models and exposes the business key
-- ORG_UNIT_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v03_claim') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v06_distribution_channel') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v08_org_unit') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v11_party') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v12_policy') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v14_policy') }}
    where ORG_UNIT_BK is not null
