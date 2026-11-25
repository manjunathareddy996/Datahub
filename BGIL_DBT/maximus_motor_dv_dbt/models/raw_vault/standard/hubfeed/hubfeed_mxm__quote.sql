{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_QUOTE: unions the contributing stg2 models and exposes the business key
-- QUOTE_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select QUOTE_HKEY, QUOTE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v01_assessment') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY, QUOTE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v04_claim') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY, QUOTE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v09_party') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY, QUOTE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v11_party') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY, QUOTE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v14_risk_object') }}
    where QUOTE_BK is not null
