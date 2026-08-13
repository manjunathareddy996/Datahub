-- Staging model for source table BJAZ_CLM_WG_TRANS_DTLS_HIST (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim("DIAGONSIS_REMARKS"::varchar), '') as diagonsis_remarks,
    nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code
    from {{ source('health_raw', 'BJAZ_CLM_WG_TRANS_DTLS_HIST') }}

)

select * from source
