-- Staging model for source table BA_HDFC_LEAD (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("BA_LEAD_NO")), '') as ba_lead_no,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim(to_varchar("PROSPECT_ID")), '') as prospect_id,
    nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
    nullif(trim(to_varchar("SM_CODE")), '') as sm_code
    from {{ source('health_raw', 'BA_HDFC_LEAD') }}

)

select * from source
