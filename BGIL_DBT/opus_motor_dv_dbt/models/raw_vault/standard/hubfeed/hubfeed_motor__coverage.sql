{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_COVERAGE: unions the contributing stg2 models and exposes the business key
-- COVERAGE_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select COVERAGE_HKEY, COVERAGE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v04_coverage') }}
    where COVERAGE_BK is not null
union all
    select COVERAGE_HKEY, COVERAGE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v05_coverage') }}
    where COVERAGE_BK is not null
union all
    select COVERAGE_HKEY, COVERAGE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v21_product') }}
    where COVERAGE_BK is not null
