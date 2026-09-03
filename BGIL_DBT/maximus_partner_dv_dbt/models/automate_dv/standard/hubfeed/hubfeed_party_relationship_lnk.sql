{{ config(materialized='view') }}

-- Feed for LNK_PARTY_RELATIONSHIP: renames Maximus's PARTY_RELATIONSHIP_HKEY to the model's key name.

    select PARTY_RELATIONSHIP_HKEY as PARTY_RELATIONSHIP_HKEY, PARTY_HKEY, RELATED_PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_relparty') }}
