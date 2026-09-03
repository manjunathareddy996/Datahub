{{ config(materialized='view') }}

-- Feed for LNK_PARTY_ROLE: renames Maximus's PARTY_ROLE_BK / PARTY_ROLE_HKEY to the names
-- partner_dv_dbt already writes (PARENT_BK / PARTY_ROLE_HKEY), so both projects populate ONE
-- set of columns in the shared table instead of two.

    select PARTY_ROLE_HKEY as PARTY_ROLE_HKEY, PARTY_ROLE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_sp_pv') }}
