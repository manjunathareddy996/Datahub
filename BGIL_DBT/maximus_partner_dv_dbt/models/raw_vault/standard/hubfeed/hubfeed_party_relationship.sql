{{ config(materialized='view') }}

-- Feed for LNK_PARTY_RELATIONSHIP: renames Maximus's PARTY_RELATIONSHIP_BK / PARTY_RELATIONSHIP_HKEY to the names
-- partner_dv_dbt already writes (PARENT_BK / PARTY_RELATIONSHIP_HKEY), so both projects populate ONE
-- set of columns in the shared table instead of two.

    select PARTY_RELATIONSHIP_HKEY as PARTY_RELATIONSHIP_HKEY, PARTY_RELATIONSHIP_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_relparty') }}
