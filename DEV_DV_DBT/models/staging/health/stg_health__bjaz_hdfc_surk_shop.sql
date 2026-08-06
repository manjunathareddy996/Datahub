-- Staging model for source table BJAZ_HDFC_SURK_SHOP (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
    nullif(trim(to_varchar("MASTER_POLICY_NO")), '') as master_policy_no,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim("PREEXISTING_DISEASE"::varchar), '') as preexisting_disease,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    nullif(trim(to_varchar("QUOTE_NO")), '') as quote_no,
    nullif(trim(to_varchar("SUBIMD_ID")), '') as subimd_id,
    nullif(trim(to_varchar("USER_ID")), '') as user_id
    from {{ source('health_raw', 'BJAZ_HDFC_SURK_SHOP') }}

)

select * from source
