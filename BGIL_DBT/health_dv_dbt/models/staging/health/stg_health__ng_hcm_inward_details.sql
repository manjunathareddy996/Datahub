-- Staging model for source table NG_HCM_INWARD_DETAILS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("INWARD_ID")), '') as inward_id,
    nullif(trim(to_varchar("LOCATIONCODE")), '') as locationcode
    from {{ source('health_raw', 'NG_HCM_INWARD_DETAILS') }}

)

select * from source
