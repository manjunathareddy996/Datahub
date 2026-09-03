{{ config(materialized='view') }}

-- Feed for HUB_DISTRIBUTION_CHANNEL: renames Maximus's DISTRIBUTION_CHANNEL_BK / DISTRIBUTION_CHANNEL_HKEY to the names
-- partner_dv_dbt already writes (PARENT_BK / DISTRIBUTION_CHANNEL_HKEY), so both projects populate ONE
-- set of columns in the shared table instead of two.

    select DISTRIBUTION_CHANNEL_HKEY as DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_sp_pv') }}
