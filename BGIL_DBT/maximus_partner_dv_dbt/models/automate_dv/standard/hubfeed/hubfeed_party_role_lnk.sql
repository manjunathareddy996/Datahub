{{ config(materialized='view') }}

-- Feed for LNK_PARTY_ROLE: renames Maximus's PARTY_ROLE_HKEY to the model's key name.

    select PARTY_ROLE_HKEY as PARTY_ROLE_HKEY, PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_sp_pv') }}
