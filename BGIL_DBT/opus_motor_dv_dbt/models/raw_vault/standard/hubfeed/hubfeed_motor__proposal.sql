{{ config(materialized='view', tags=['hubfeed']) }}
-- FEED for HUB_PROPOSAL: unions the contributing stg2 models and exposes the business key
-- PROPOSAL_BK as PARENT_BK, the shared HUB column name used by partner and travel.
    select PROPOSAL_HKEY, PROPOSAL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v06_distribution_channel') }}
    where PROPOSAL_BK is not null
union all
    select PROPOSAL_HKEY, PROPOSAL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v09_party') }}
    where PROPOSAL_BK is not null
union all
    select PROPOSAL_HKEY, PROPOSAL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v10_party') }}
    where PROPOSAL_BK is not null
union all
    select PROPOSAL_HKEY, PROPOSAL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v11_party') }}
    where PROPOSAL_BK is not null
union all
    select PROPOSAL_HKEY, PROPOSAL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v14_policy') }}
    where PROPOSAL_BK is not null
union all
    select PROPOSAL_HKEY, PROPOSAL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v15_policy') }}
    where PROPOSAL_BK is not null
union all
    select PROPOSAL_HKEY, PROPOSAL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v21_product') }}
    where PROPOSAL_BK is not null
union all
    select PROPOSAL_HKEY, PROPOSAL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v22_quote') }}
    where PROPOSAL_BK is not null
union all
    select PROPOSAL_HKEY, PROPOSAL_BK as PARENT_BK, LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_motor__v24_risk_object') }}
    where PROPOSAL_BK is not null
