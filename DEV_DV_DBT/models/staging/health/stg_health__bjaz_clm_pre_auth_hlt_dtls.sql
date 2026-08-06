-- Staging model for source table BJAZ_CLM_PRE_AUTH_HLT_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CARD_NO")), '') as card_no,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim("DOCTOR_NAME"::varchar), '') as doctor_name,
    nullif(trim("ENHANCEMENT_REQ_YN"::varchar), '') as enhancement_req_yn,
    "EXPECTED_DOA"::timestamp_ntz as expected_doa,
    "EXPECTED_DOD"::timestamp_ntz as expected_dod,
    nullif(trim(to_varchar("HOSPITAL_ID")), '') as hospital_id,
    "PRE_AUTH_DATE"::timestamp_ntz as pre_auth_date,
    "PRE_AUTH_NO"::number as pre_auth_no,
    nullif(trim("PRE_AUTH_REF"::varchar), '') as pre_auth_ref,
    nullif(trim("PRE_AUTH_STATUS"::varchar), '') as pre_auth_status,
    nullif(trim(to_varchar("PRODUCT_4DIGIT_CODE")), '') as product_4digit_code,
    nullif(trim("PROV_DIAGNOSIS"::varchar), '') as prov_diagnosis
    from {{ source('health_raw', 'BJAZ_CLM_PRE_AUTH_HLT_DTLS') }}

)

select * from source
