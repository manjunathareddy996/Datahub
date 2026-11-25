{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_COVERAGE: unions the contributing stg2 models and exposes the business key
-- COVERAGE_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select COVERAGE_HKEY, COVERAGE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v01_assessment') }}
    where COVERAGE_BK is not null
union all
    select COVERAGE_HKEY, COVERAGE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v05_coverage') }}
    where COVERAGE_BK is not null
union all
    select COVERAGE_HKEY, COVERAGE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v07_financial_transaction') }}
    where COVERAGE_BK is not null
union all
    select COVERAGE_HKEY, COVERAGE_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v14_risk_object') }}
    where COVERAGE_BK is not null
