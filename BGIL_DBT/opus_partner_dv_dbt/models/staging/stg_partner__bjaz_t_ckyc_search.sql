{{ config(materialized='view') }}

-- Staging model for source table BJAZ_T_CKYC_SEARCH (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.
--
-- CLOB COLUMNS (3): CKYC_IMAGE, CKYC_REQUEST, CKYC_RESPONSE.
-- BD-05 / DEC-10: these carry document bytes / request / response payloads. They are
-- available HERE ONLY. They are excluded from every satellite payload and from every
-- hashdiff column list -- hashing them would make change detection thrash on every
-- reload. Each is accompanied by a <col>_present flag and a <col>_digest computed
-- with the sha2 function and deliberately NOT with the md5 one, so that DEC-03's
-- assertion of zero md5 calls in generated SQL stays able to tell a translated key
-- from a CLOB digest (BDEC-04).

with source as (

    select
    "SEARCH_ID"::number as search_id,
    "INCOMING_ID"::number as incoming_id,
    nullif(trim("BUSINESS_UNIT"::varchar), '') as business_unit,
    nullif(trim("FIELD_TYPE"::varchar), '') as field_type,
    nullif(trim("FIELD_VALUE"::varchar), '') as field_value,
    nullif(trim("CATEGORY"::varchar), '') as category,
    nullif(trim("INPUT"::varchar), '') as input,
    nullif(trim("FULL_NAME"::varchar), '') as full_name,
    nullif(trim("DOB"::varchar), '') as dob,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("CKYC_STATUS"::varchar), '') as ckyc_status,
    nullif(trim("CKYC_NUMBER"::varchar), '') as ckyc_number,
    nullif(trim("CKYC_FULL_NAME"::varchar), '') as ckyc_full_name,
    nullif(trim("CKYC_FATHER_NAME"::varchar), '') as ckyc_father_name,
    nullif(trim("CKYC_AGE"::varchar), '') as ckyc_age,
    nullif(trim("CKYC_IMAGE_TYPE"::varchar), '') as ckyc_image_type,
    nullif(trim("CKYC_KYC_DATE"::varchar), '') as ckyc_kyc_date,
    nullif(trim("CKYC_UPDATE_DATE"::varchar), '') as ckyc_update_date,
    "CKYC_IMAGE"::varchar as ckyc_image,
    case when "CKYC_IMAGE" is not null and length("CKYC_IMAGE") > 0 then 'Y' else 'N' end as ckyc_image_present,
    sha2("CKYC_IMAGE"::varchar) as ckyc_image_digest,
    nullif(trim("CKYC_DOB"::varchar), '') as ckyc_dob,
    nullif(trim("CKYC_GENDER"::varchar), '') as ckyc_gender,
    nullif(trim("CKYC_RESPONSE_CODE"::varchar), '') as ckyc_response_code,
    nullif(trim("CKYC_RESPONSE_MESSAGE"::varchar), '') as ckyc_response_message,
    "CKYC_REQUEST"::varchar as ckyc_request,
    case when "CKYC_REQUEST" is not null and length("CKYC_REQUEST") > 0 then 'Y' else 'N' end as ckyc_request_present,
    sha2("CKYC_REQUEST"::varchar) as ckyc_request_digest,
    "CKYC_RESPONSE"::varchar as ckyc_response,
    case when "CKYC_RESPONSE" is not null and length("CKYC_RESPONSE") > 0 then 'Y' else 'N' end as ckyc_response_present,
    sha2("CKYC_RESPONSE"::varchar) as ckyc_response_digest,
    try_to_timestamp_ntz(regexp_replace("CREATED_DATE"::varchar, '^Z[ ]*', '')) as created_date,
    try_to_timestamp_ntz(regexp_replace("MODIFY_DATE"::varchar, '^Z[ ]*', '')) as modify_date,
    nullif(trim("CONSTITUTION_TYPE"::varchar), '') as constitution_type,
    nullif(trim("POLICY_NAME_CONSENT"::varchar), '') as policy_name_consent,
    nullif(trim("CKYC_GATEWAY"::varchar), '') as ckyc_gateway,
    nullif(trim("AWS_SERVICE"::varchar), '') as aws_service,
    nullif(trim("CKYC_REF_ID"::varchar), '') as ckyc_ref_id,
    nullif(trim("CUSTOMER_KYC_CONSENT"::varchar), '') as customer_kyc_consent,
    "NAME_MATCH_ID"::number as name_match_id,
    to_timestamp_ntz(regexp_replace("INC_JOB_UPDATED_AT"::varchar, '^Z[ ]*', '')) as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_T_CKYC_SEARCH') }}

)

select * from source
