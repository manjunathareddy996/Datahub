{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_ASSESSMENT: unions the contributing stg2 models and exposes the business key
-- ASSESSMENT_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select ASSESSMENT_HKEY, ASSESSMENT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v01_claim') }}
    where ASSESSMENT_BK is not null
union all
    select ASSESSMENT_HKEY, ASSESSMENT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v09_party') }}
    where ASSESSMENT_BK is not null
union all
    select ASSESSMENT_HKEY, ASSESSMENT_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v10_party') }}
    where ASSESSMENT_BK is not null
