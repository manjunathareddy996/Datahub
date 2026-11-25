{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_POLICY: unions the contributing stg2 models and exposes the business key
-- POLICY_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v01_claim') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v03_claim') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v05_coverage') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v06_distribution_channel') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v08_org_unit') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v10_party') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v11_party') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v12_policy') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v13_policy') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v14_policy') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v15_policy') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v16_policy') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v17_policy') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v18_policy') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v19_policy') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v21_product') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY, POLICY_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v25_risk_object') }}
    where POLICY_BK is not null
