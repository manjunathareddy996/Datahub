{{ config(materialized='view') }}

-- MAXIMUS PARTNER layer-1 cast for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY.

with source as (

    select
    nullif(trim(to_varchar("PARTY_CODE")), '') as party_code,
    nullif(trim(to_varchar("STAKE_CODE")), '') as stake_code,
    nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
    nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
    nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash
    from {{ source('maximus_partner', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY') }}

)

select * from source
