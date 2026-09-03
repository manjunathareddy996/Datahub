{{ config(materialized='view') }}

-- Feed for HUB_FINANCIAL_ACCOUNT: renames Maximus's FINANCIAL_ACCOUNT_BK / FINANCIAL_ACCOUNT_HKEY to the names
-- partner_dv_dbt already writes (PARENT_BK / FINANCIAL_ACCOUNT_HKEY), so both projects populate ONE
-- set of columns in the shared table instead of two.

    select FINANCIAL_ACCOUNT_HKEY as FINANCIAL_ACCOUNT_HKEY, FINANCIAL_ACCOUNT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_msdp_pv') }}
