{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_RISK_OBJECT: unions the contributing stg2 models and exposes the business key
-- RISK_OBJECT_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v01_claim') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v03_claim') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v05_coverage') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v06_distribution_channel') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v08_org_unit') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v09_party') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v10_party') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v11_party') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v12_policy') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v14_policy') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v15_policy') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v16_policy') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v22_quote') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v24_risk_object') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v25_risk_object') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v26_risk_object') }}
    where RISK_OBJECT_BK is not null
