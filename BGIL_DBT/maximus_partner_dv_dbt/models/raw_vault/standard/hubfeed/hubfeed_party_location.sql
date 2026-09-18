{{ config(materialized='view') }}

-- Feed for LNK_PARTY_LOCATION: renames Maximus's PARTY_LOCATION_BK / PARTY_LOCATION_HKEY to the names
-- partner_dv_dbt already writes (PARENT_BK / PARTY_LOCATION_HKEY), so both projects populate ONE
-- set of columns in the shared table instead of two.

    select PARTY_LOCATION_HKEY as PARTY_LOCATION_HKEY, PARTY_LOCATION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_addr') }}
    union all
    select PARTY_LOCATION_HKEY as PARTY_LOCATION_HKEY, PARTY_LOCATION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_sp_pv') }}
    union all
    select PARTY_LOCATION_HKEY as PARTY_LOCATION_HKEY, PARTY_LOCATION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_up__pd_prop_sp_pv__party_contact_address_link') }}
