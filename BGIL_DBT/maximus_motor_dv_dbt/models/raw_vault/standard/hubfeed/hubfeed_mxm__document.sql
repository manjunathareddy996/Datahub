{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_DOCUMENT: unions the contributing stg2 models and exposes the business key
-- DOCUMENT_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select DOCUMENT_HKEY, DOCUMENT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v01_assessment') }}
    where DOCUMENT_BK is not null
union all
    select DOCUMENT_HKEY, DOCUMENT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v06_document') }}
    where DOCUMENT_BK is not null
union all
    select DOCUMENT_HKEY, DOCUMENT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v14_risk_object') }}
    where DOCUMENT_BK is not null
