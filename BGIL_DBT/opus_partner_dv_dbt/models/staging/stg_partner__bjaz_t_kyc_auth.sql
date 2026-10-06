{{ config(materialized='view') }}

-- Staging model for source table BJAZ_T_KYC_AUTH (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.
--
-- CLOB COLUMNS (2): AUTH_REQUEST, AUTH_RESPONSE.
-- BD-05 / DEC-10: these carry document bytes / request / response payloads. They are
-- available HERE ONLY. They are excluded from every satellite payload and from every
-- hashdiff column list -- hashing them would make change detection thrash on every
-- reload. Each is accompanied by a <col>_present flag and a <col>_digest computed
-- with the sha2 function and deliberately NOT with the md5 one, so that DEC-03's
-- assertion of zero md5 calls in generated SQL stays able to tell a translated key
-- from a CLOB digest (BDEC-04).

with source as (

    select
    "AUTH_ID"::number as auth_id,
    "INCOMING_ID"::number as incoming_id,
    nullif(trim("BUSINESS_UNIT"::varchar), '') as business_unit,
    nullif(trim("FIELD_TYPE"::varchar), '') as field_type,
    nullif(trim("FIELD_VALUE"::varchar), '') as field_value,
    nullif(trim("CATEGORY"::varchar), '') as category,
    nullif(trim("INPUT"::varchar), '') as input,
    nullif(trim("FULL_NAME"::varchar), '') as full_name,
    nullif(trim("DOB"::varchar), '') as dob,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("FILE_NUMBER"::varchar), '') as file_number,
    nullif(trim("AUTH_NUMBER"::varchar), '') as auth_number,
    nullif(trim("AUTH_STATUS"::varchar), '') as auth_status,
    nullif(trim("AUTH_FULL_NAME"::varchar), '') as auth_full_name,
    nullif(trim("AUTH_FATHER_NAME"::varchar), '') as auth_father_name,
    nullif(trim("AUTH_DOB"::varchar), '') as auth_dob,
    nullif(trim("AUTH_GENDER"::varchar), '') as auth_gender,
    nullif(trim("AUTH_RESPONSE_CODE"::varchar), '') as auth_response_code,
    nullif(trim("AUTH_RESPONSE_MESSAGE"::varchar), '') as auth_response_message,
    "AUTH_REQUEST"::varchar as auth_request,
    case when "AUTH_REQUEST" is not null and length("AUTH_REQUEST") > 0 then 'Y' else 'N' end as auth_request_present,
    sha2("AUTH_REQUEST"::varchar) as auth_request_digest,
    "AUTH_RESPONSE"::varchar as auth_response,
    case when "AUTH_RESPONSE" is not null and length("AUTH_RESPONSE") > 0 then 'Y' else 'N' end as auth_response_present,
    sha2("AUTH_RESPONSE"::varchar) as auth_response_digest,
    "CREATED_DATE"::timestamp_ntz as created_date,
    "MODIFY_DATE"::timestamp_ntz as modify_date,
    "NAME_MATCH_ID"::number as name_match_id,
    nullif(trim("NAME_MATCH_STATUS"::varchar), '') as name_match_status,
    nullif(trim("KYC_GATEWAY"::varchar), '') as kyc_gateway,
    cast(null as varchar) as aws_service,  -- AWS_SERVICE not present in source table
    cast(null as varchar) as policy_name_consent,  -- POLICY_NAME_CONSENT not present in source table
    cast(null as varchar) as customer_kyc_consent,  -- CUSTOMER_KYC_CONSENT not present in source table
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_T_KYC_AUTH') }}

)

select * from source
