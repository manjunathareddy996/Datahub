{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_POLICY: unions the contributing stg2 models and exposes the business key
-- POLICY_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v01_assessment') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v03_claim') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v04_claim') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v07_financial_transaction') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v09_party') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v10_party') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v12_policy') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v13_policy') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v14_risk_object') }}
    where POLICY_BK is not null
