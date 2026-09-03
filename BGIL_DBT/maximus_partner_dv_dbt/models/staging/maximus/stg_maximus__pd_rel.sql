{{ config(materialized='view') }}

-- MAXIMUS PARTNER layer-1 cast for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION.

with source as (

    select
    nullif(trim(to_varchar("STAKE_NAME")), '') as stake_name,
    nullif(trim(to_varchar("START_DATE")), '') as start_date,
    nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
    nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
    nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash
    from {{ source('maximus_partner', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION') }}

)

select * from source
