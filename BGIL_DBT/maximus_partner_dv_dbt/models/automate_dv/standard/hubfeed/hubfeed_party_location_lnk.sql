{{ config(materialized='view') }}

-- Feed for LNK_PARTY_LOCATION: renames Maximus's PARTY_LOCATION_HKEY to the model's key name.

    select PARTY_LOCATION_HKEY as PARTY_LOCATION_HKEY, PARTY_HKEY, LOCATION_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_addr') }}
    union all
    select PARTY_LOCATION_HKEY as PARTY_LOCATION_HKEY, PARTY_HKEY, LOCATION_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_sp_pv') }}
