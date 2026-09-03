{{ config(materialized='view') }}

-- Feed for HUB_LOCATION: renames Maximus's LOCATION_BK / LOCATION_HKEY to the names
-- partner_dv_dbt already writes (PARENT_BK / LOCATION_HKEY), so both projects populate ONE
-- set of columns in the shared table instead of two.

    select LOCATION_HKEY as LOCATION_HKEY, LOCATION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_addr') }}
    union all
    select LOCATION_HKEY as LOCATION_HKEY, LOCATION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_party_addr_prop_pv') }}
    union all
    select LOCATION_HKEY as LOCATION_HKEY, LOCATION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_sp_pv') }}
