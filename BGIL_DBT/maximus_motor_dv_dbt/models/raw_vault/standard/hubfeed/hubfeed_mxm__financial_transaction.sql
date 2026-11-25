{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_FINANCIAL_TRANSACTION: unions the contributing stg2 models and exposes the business key
-- FINANCIAL_TRANSACTION_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v03_claim') }}
    where FINANCIAL_TRANSACTION_BK is not null
union all
    select FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v07_financial_transaction') }}
    where FINANCIAL_TRANSACTION_BK is not null
union all
    select FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v09_party') }}
    where FINANCIAL_TRANSACTION_BK is not null
union all
    select FINANCIAL_TRANSACTION_HKEY, FINANCIAL_TRANSACTION_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mxm__v14_risk_object') }}
    where FINANCIAL_TRANSACTION_BK is not null
