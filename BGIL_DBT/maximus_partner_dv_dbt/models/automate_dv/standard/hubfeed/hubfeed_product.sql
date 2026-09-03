{{ config(materialized='view') }}

-- Feed for HUB_PRODUCT: renames Maximus's PRODUCT_BK / PRODUCT_HKEY to the names
-- partner_dv_dbt already writes (PARENT_BK / PRODUCT_HKEY), so both projects populate ONE
-- set of columns in the shared table instead of two.

    select PRODUCT_HKEY as PRODUCT_HKEY, PRODUCT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_sp_pv') }}
