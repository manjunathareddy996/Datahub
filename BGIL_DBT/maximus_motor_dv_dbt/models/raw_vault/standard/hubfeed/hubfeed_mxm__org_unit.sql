{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_ORG_UNIT: unions the contributing stg2 models and exposes the business key
-- ORG_UNIT_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v04_claim') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v08_location') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v09_party') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v12_policy') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v14_risk_object') }}
    where ORG_UNIT_BK is not null
