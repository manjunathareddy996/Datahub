{{ config(materialized='view') }}

-- Feed for HUB_POLICY: renames Maximus's POLICY_BK / POLICY_HKEY to the names
-- partner_dv_dbt already writes (PARENT_BK / POLICY_HKEY), so both projects populate ONE
-- set of columns in the shared table instead of two.

    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_sp_pv') }}
