-- Staging for source table BJAZ_SCR_HLTH_PORTABLE_DTLS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("INSURED_DOB")), '') as insured_dob,
        nullif(trim(to_varchar("INSURED_GENDER")), '') as insured_gender,
        nullif(trim(to_varchar("INSURED_NAME")), '') as insured_name,
        nullif(trim(to_varchar("MEMBER_IDENTIFIER")), '') as member_identifier,
        nullif(trim(to_varchar("MEMBER_IDENTIFIER_KEY")), '') as member_identifier_key,
        nullif(trim(to_varchar("MEMBER_REFERENCE_KEY")), '') as member_reference_key,
        nullif(trim(to_varchar("PORTABILITY")), '') as portability,
        nullif(trim(to_varchar("PREV_INSURER_NAME")), '') as prev_insurer_name,
        nullif(trim(to_varchar("PREV_POLICY_NO")), '') as prev_policy_no,
        nullif(trim(to_varchar("REQUEST_NO")), '') as request_no,
        nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured
    from {{ source('health_raw', 'BJAZ_SCR_HLTH_PORTABLE_DTLS') }}

)

select * from source
