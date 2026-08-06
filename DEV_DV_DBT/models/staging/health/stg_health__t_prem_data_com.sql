-- Staging model for source table T_PREM_DATA_COM (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("BRANCH_CODE")), '') as branch_code,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim(to_varchar("COVER_CODE")), '') as cover_code,
    nullif(trim(to_varchar("DEPARTMENT_CODE")), '') as department_code,
    "MEMBER_AGE"::number as member_age,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code
    from {{ source('health_raw', 'T_PREM_DATA_COM') }}

)

select * from source
