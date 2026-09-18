{{ config(materialized='view') }}

-- Feed for HUB_ORG_UNIT: renames Maximus's ORG_UNIT_BK / ORG_UNIT_HKEY to the names
-- partner_dv_dbt already writes (PARENT_BK / ORG_UNIT_HKEY), so both projects populate ONE
-- set of columns in the shared table instead of two.

    select ORG_UNIT_HKEY as ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_msdp_pv') }}
    union all
    select ORG_UNIT_HKEY as ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_sp_pv') }}
