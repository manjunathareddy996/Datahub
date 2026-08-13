-- Staging model for source table BJAZ_SCR_HLTH_PORTABLE_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "AGE"::number as age,
    "INSURED_DOB"::timestamp_ntz as insured_dob,
    nullif(trim("INSURED_GENDER"::varchar), '') as insured_gender,
    nullif(trim("INSURED_NAME"::varchar), '') as insured_name,
    nullif(trim(to_varchar("MEMBER_IDENTIFIER")), '') as member_identifier,
    nullif(trim(to_varchar("MEMBER_IDENTIFIER_KEY")), '') as member_identifier_key,
    nullif(trim(to_varchar("MEMBER_REFERENCE_KEY")), '') as member_reference_key,
    nullif(trim("PORTABILITY"::varchar), '') as portability,
    nullif(trim("PREV_INSURER_NAME"::varchar), '') as prev_insurer_name,
    nullif(trim("PREV_POLICY_NO"::varchar), '') as prev_policy_no,
    nullif(trim(to_varchar("REQUEST_NO")), '') as request_no,
    nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
    nullif(trim("STATUS"::varchar), '') as status,
    "SUM_INSURED"::number as sum_insured
    from {{ source('health_raw', 'BJAZ_SCR_HLTH_PORTABLE_DTLS') }}

)

select * from source
