-- Staging model for source table BJAZ_CTNGY_SCHEME_MST (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("HEALTH_PRODUCT"::varchar), '') as health_product,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim(to_varchar("SCHEME_CODE")), '') as scheme_code,
    nullif(trim("SCHEME_DESC"::varchar), '') as scheme_desc
    from {{ source('health_raw', 'BJAZ_CTNGY_SCHEME_MST') }}

)

select * from source
