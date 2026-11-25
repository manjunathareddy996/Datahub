{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_PRODUCT: unions the contributing stg2 models and exposes the business key
-- PRODUCT_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v05_coverage') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v06_distribution_channel') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v08_org_unit') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v10_party') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v11_party') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v14_policy') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v15_policy') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v20_product') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY, PRODUCT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v21_product') }}
    where PRODUCT_BK is not null
