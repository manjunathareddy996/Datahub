-- Staging model for source table BJAZ_GRP_HLT_IMD_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
    nullif(trim("IMD_NAME"::varchar), '') as imd_name,
    nullif(trim(to_varchar("PRODUCT")), '') as product,
    nullif(trim(to_varchar("QUOTE_NO")), '') as quote_no,
    nullif(trim(to_varchar("QUOTE_SUB_NO")), '') as quote_sub_no,
    nullif(trim(to_varchar("REG_NO")), '') as reg_no,
    nullif(trim(to_varchar("RM_CODE")), '') as rm_code,
    nullif(trim("RM_NAME"::varchar), '') as rm_name,
    nullif(trim(to_varchar("SUB_IMD_CODE")), '') as sub_imd_code,
    nullif(trim("SUB_IMD_NAME"::varchar), '') as sub_imd_name
    from {{ source('health_raw', 'BJAZ_GRP_HLT_IMD_DTLS') }}

)

select * from source
