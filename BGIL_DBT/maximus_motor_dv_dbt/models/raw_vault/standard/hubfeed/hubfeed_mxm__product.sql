{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_PRODUCT: unions the contributing stg2 models and exposes the business key
-- PRODUCT_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v04_claim') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v09_party') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v12_policy') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v14_risk_object') }}
    where PRODUCT_BK is not null
