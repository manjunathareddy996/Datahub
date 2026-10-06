{{ config(materialized='view') }}

-- Staging model for source table BJAZ_T_EKYC (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.
--
-- CLOB COLUMNS (3): IMAGE, REQUEST, RESPONSE.
-- BD-05 / DEC-10: these carry document bytes / request / response payloads. They are
-- available HERE ONLY. They are excluded from every satellite payload and from every
-- hashdiff column list -- hashing them would make change detection thrash on every
-- reload. Each is accompanied by a <col>_present flag and a <col>_digest computed
-- with the sha2 function and deliberately NOT with the md5 one, so that DEC-03's
-- assertion of zero md5 calls in generated SQL stays able to tell a translated key
-- from a CLOB digest (BDEC-04).

with source as (

    select
    "EKYC_ID"::number as ekyc_id,
    "INCOMING_ID"::number as incoming_id,
    nullif(trim("BUSINESS_UNIT"::varchar), '') as business_unit,
    nullif(trim("FIELD_TYPE"::varchar), '') as field_type,
    nullif(trim("FIELD_VALUE"::varchar), '') as field_value,
    nullif(trim("CATEGORY"::varchar), '') as category,
    nullif(trim("INPUT"::varchar), '') as input,
    nullif(trim("FULL_NAME"::varchar), '') as full_name,
    nullif(trim("DOB"::varchar), '') as dob,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("REQUEST_ID"::varchar), '') as request_id,
    try_to_timestamp_ntz(regexp_replace("CREATED_DATE"::varchar, '^Z[ ]*', '')) as created_date,
    nullif(trim("EKYC_STATUS"::varchar), '') as ekyc_status,
    nullif(trim("RESPONSE_ID"::varchar), '') as response_id,
    nullif(trim("MASKED_AADHAAR_NUMBER"::varchar), '') as masked_aadhaar_number,
    nullif(trim("EKYC_NAME"::varchar), '') as ekyc_name,
    nullif(trim("EKYC_DOB"::varchar), '') as ekyc_dob,
    nullif(trim("EKYC_GENDER"::varchar), '') as ekyc_gender,
    nullif(trim("EKYC_RELATIVE_NAME"::varchar), '') as ekyc_relative_name,
    nullif(trim("HOUSE_NUMBER"::varchar), '') as house_number,
    nullif(trim("STREET"::varchar), '') as street,
    nullif(trim("LANDMARK"::varchar), '') as landmark,
    nullif(trim("SUB_DISTRICT"::varchar), '') as sub_district,
    nullif(trim("DISTRICT"::varchar), '') as district,
    nullif(trim("VTC_NAME"::varchar), '') as vtc_name,
    nullif(trim("LOCATION"::varchar), '') as location,
    nullif(trim("POST_OFFICE"::varchar), '') as post_office,
    nullif(trim("STATE"::varchar), '') as state,
    nullif(trim("COUNTRY"::varchar), '') as country,
    nullif(trim("PIN_CODE"::varchar), '') as pin_code,
    nullif(trim("COMBINE_ADDRESS"::varchar), '') as combine_address,
    "IMAGE"::varchar as image,
    case when "IMAGE" is not null and length("IMAGE") > 0 then 'Y' else 'N' end as image_present,
    sha2("IMAGE"::varchar) as image_digest,
    nullif(trim("RESPONSE_CODE"::varchar), '') as response_code,
    nullif(trim("RESPONSE_MESSAGE"::varchar), '') as response_message,
    "REQUEST"::varchar as request,
    case when "REQUEST" is not null and length("REQUEST") > 0 then 'Y' else 'N' end as request_present,
    sha2("REQUEST"::varchar) as request_digest,
    "RESPONSE"::varchar as response,
    case when "RESPONSE" is not null and length("RESPONSE") > 0 then 'Y' else 'N' end as response_present,
    sha2("RESPONSE"::varchar) as response_digest,
    nullif(trim("REMARK"::varchar), '') as remark,
    try_to_timestamp_ntz(regexp_replace("MODIFY_DATE"::varchar, '^Z[ ]*', '')) as modify_date,
    nullif(trim("UUID"::varchar), '') as uuid,
    "NAME_MATCH_ID"::number as name_match_id,
    "OTP_ID"::number as otp_id,
    nullif(trim("POLICY_NAME_CONSENT"::varchar), '') as policy_name_consent,
    nullif(trim("MOBILE_NUMBER"::varchar), '') as mobile_number,
    nullif(trim("CUSTOMER_KYC_CONSENT"::varchar), '') as customer_kyc_consent,
    to_timestamp_ntz(regexp_replace("INC_JOB_UPDATED_AT"::varchar, '^Z[ ]*', '')) as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_T_EKYC') }}

)

select * from source
