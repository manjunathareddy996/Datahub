-- Staging model for source table BJAZ_HM_POLICY_USERMAPPING (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("LOGINNAME")), '') as loginname,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref
    from {{ source('health_raw', 'BJAZ_HM_POLICY_USERMAPPING') }}

)

select * from source
