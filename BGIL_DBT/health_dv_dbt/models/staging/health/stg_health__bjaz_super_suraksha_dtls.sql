-- Staging model for source table BJAZ_SUPER_SURAKSHA_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("ACCIDENTAL_HOSPITAL"::varchar), '') as accidental_hospital,
    nullif(trim("CHOLESTEROL_DISORDER"::varchar), '') as cholesterol_disorder,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim(to_varchar("CUSTOMER_ID")), '') as customer_id,
    nullif(trim("DIABETES"::varchar), '') as diabetes,
    nullif(trim("HEART_DISEASES"::varchar), '') as heart_diseases,
    "HEIGHT_CM"::number as height_cm,
    nullif(trim("HYPERTENSION"::varchar), '') as hypertension,
    nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
    nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
    nullif(trim("OBESITY"::varchar), '') as obesity,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim("PREEXISTING_DISEASE"::varchar), '') as preexisting_disease,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
    nullif(trim(to_varchar("SUBIMD_CODE")), '') as subimd_code,
    nullif(trim(to_varchar("USER_ID")), '') as user_id,
    "WEIGHT_KG"::number as weight_kg
    from {{ source('health_raw', 'BJAZ_SUPER_SURAKSHA_DTLS') }}

)

select * from source
