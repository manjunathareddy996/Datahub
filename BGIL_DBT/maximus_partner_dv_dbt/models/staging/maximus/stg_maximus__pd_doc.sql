{{ config(materialized='view') }}

-- MAXIMUS PARTNER layer-1 cast for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL.

with source as (

    select
    nullif(trim(to_varchar("DOCUMENT_GENERATION_DATE")), '') as document_generation_date,
    nullif(trim(to_varchar("DOCUMENT_ID")), '') as document_id,
    nullif(trim(to_varchar("DOCUMENT_NAME")), '') as document_name,
    nullif(trim(to_varchar("DOCUMENT_TYPE")), '') as document_type,
    nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
    nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
    nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash
    from {{ source('maximus_partner', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL') }}

)

select * from source
