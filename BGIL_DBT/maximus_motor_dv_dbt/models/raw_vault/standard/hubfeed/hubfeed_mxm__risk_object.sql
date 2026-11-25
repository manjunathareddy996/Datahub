{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_RISK_OBJECT: unions the contributing stg2 models and exposes the business key
-- RISK_OBJECT_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v01_assessment') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v04_claim') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v09_party') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v12_policy') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v14_risk_object') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v15_risk_object') }}
    where RISK_OBJECT_BK is not null
