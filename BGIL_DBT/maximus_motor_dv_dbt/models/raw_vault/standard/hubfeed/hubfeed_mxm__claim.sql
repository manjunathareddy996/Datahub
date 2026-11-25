{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_CLAIM: unions the contributing stg2 models and exposes the business key
-- CLAIM_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select CLAIM_HKEY, CLAIM_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v01_assessment') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY, CLAIM_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v03_claim') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY, CLAIM_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v04_claim') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY, CLAIM_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v06_document') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY, CLAIM_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v09_party') }}
    where CLAIM_BK is not null
