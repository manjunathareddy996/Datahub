-- Staging model for source table BJAZ_HCP_TRANSCRIPT_URL (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("BUSINESS_TYPE"::varchar), '') as business_type,
    nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
    nullif(trim("PARTNER_MAIL_ID"::varchar), '') as partner_mail_id,
    nullif(trim("PARTNER_MOBILE_NO"::varchar), '') as partner_mobile_no,
    nullif(trim("PA_COVER"::varchar), '') as pa_cover,
    nullif(trim("PA_COVER_DTI"::varchar), '') as pa_cover_dti,
    nullif(trim("PA_COVER_OCC"::varchar), '') as pa_cover_occ,
    nullif(trim("PA_COVER_PPD"::varchar), '') as pa_cover_ppd,
    nullif(trim("PA_COVER_PTD"::varchar), '') as pa_cover_ptd,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
    nullif(trim("SCRUTINY_URL"::varchar), '') as scrutiny_url
    from {{ source('health_raw', 'BJAZ_HCP_TRANSCRIPT_URL') }}

)

select * from source
