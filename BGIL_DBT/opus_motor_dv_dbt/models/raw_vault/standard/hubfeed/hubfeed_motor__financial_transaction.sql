{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_FINANCIAL_TRANSACTION: unions the contributing stg2 models and exposes the business key
-- FINANCIAL_TRANSACTION_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v03_claim') }}
    where FINANCIAL_TRANSACTION_BK is not null
union all
    select FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v06_distribution_channel') }}
    where FINANCIAL_TRANSACTION_BK is not null
union all
    select FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v08_org_unit') }}
    where FINANCIAL_TRANSACTION_BK is not null
union all
    select FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v11_party') }}
    where FINANCIAL_TRANSACTION_BK is not null
union all
    select FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v16_policy') }}
    where FINANCIAL_TRANSACTION_BK is not null
union all
    select FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v18_policy') }}
    where FINANCIAL_TRANSACTION_BK is not null
