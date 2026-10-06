{{ config(materialized='view') }}

-- Staging model for source table BJAZ_T_KYC_OCR (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.

with source as (

    select
    "OCR_ID"::number as ocr_id,
    "INCOMING_ID"::number as incoming_id,
    nullif(trim("BUSINESS_UNIT"::varchar), '') as business_unit,
    nullif(trim("FIELD_TYPE"::varchar), '') as field_type,
    nullif(trim("FIELD_VALUE"::varchar), '') as field_value,
    nullif(trim("IMAGE_TYPE"::varchar), '') as image_type,
    nullif(trim("CATEGORY"::varchar), '') as category,
    nullif(trim("OCR_STATUS"::varchar), '') as ocr_status,
    nullif(trim("RESPONSE_CODE"::varchar), '') as response_code,
    nullif(trim("RESPONSE_MESSAGE"::varchar), '') as response_message,
    nullif(trim("REMARK"::varchar), '') as remark,
    nullif(trim("MASKED_AADHAAR_NUMBER"::varchar), '') as masked_aadhaar_number,
    nullif(trim("POI_REQUEST_ID"::varchar), '') as poi_request_id,
    nullif(trim("POA_REQUEST_ID"::varchar), '') as poa_request_id,
    nullif(trim("CUSTOMER_NAME"::varchar), '') as customer_name,
    nullif(trim("DOB"::varchar), '') as dob,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("HOUSE_NUMBER"::varchar), '') as house_number,
    nullif(trim("STREET"::varchar), '') as street,
    nullif(trim("LOCATION"::varchar), '') as location,
    nullif(trim("PIN_CODE"::varchar), '') as pin_code,
    nullif(trim("DISTRICT"::varchar), '') as district,
    nullif(trim("POST_OFFICE"::varchar), '') as post_office,
    nullif(trim("STATE"::varchar), '') as state,
    try_to_timestamp_ntz(regexp_replace("CREATED_DATE"::varchar, '^Z[ ]*', '')) as created_date,
    try_to_timestamp_ntz(regexp_replace("MODIFY_DATE"::varchar, '^Z[ ]*', '')) as modify_date,
    nullif(trim("POI_OCR_STATUS_CODE"::varchar), '') as poi_ocr_status_code,
    nullif(trim("POA_OCR_STATUS_CODE"::varchar), '') as poa_ocr_status_code,
    nullif(trim("SURNAME"::varchar), '') as surname,
    nullif(trim("FILE_NUMBER"::varchar), '') as file_number,
    nullif(trim("BUILDING"::varchar), '') as building,
    nullif(trim("COUNTRY_CODE"::varchar), '') as country_code,
    nullif(trim("DOE"::varchar), '') as doe,
    nullif(trim("DOI"::varchar), '') as doi,
    nullif(trim("PLACE_OF_BIRTH"::varchar), '') as place_of_birth,
    nullif(trim("PLACE_OF_ISSUE"::varchar), '') as place_of_issue,
    nullif(trim("NATIONALITY"::varchar), '') as nationality,
    nullif(trim("MOTHER"::varchar), '') as mother,
    nullif(trim("FATHER"::varchar), '') as father,
    nullif(trim("NAME_SCORE"::varchar), '') as name_score,
    nullif(trim("DOCUMENT_NUMBER_SCORE"::varchar), '') as document_number_score,
    nullif(trim("ADDRESS_SCORE"::varchar), '') as address_score,
    "PREMIUM_AMOUNT"::number as premium_amount,
    nullif(trim("AWS_SERVICE"::varchar), '') as aws_service,
    nullif(trim("FULL_NAME"::varchar), '') as full_name,
    "AUTH_ID"::number as auth_id,
    nullif(trim("AUTH_STATUS"::varchar), '') as auth_status,
    nullif(trim("POI_POLICY_NAME_CONSENT"::varchar), '') as poi_policy_name_consent,
    nullif(trim("POA_POLICY_NAME_CONSENT"::varchar), '') as poa_policy_name_consent,
    "NAME_MATCH_ID"::number as name_match_id,
    nullif(trim("CUSTOMER_KYC_CONSENT"::varchar), '') as customer_kyc_consent,
    to_timestamp_ntz(regexp_replace("INC_JOB_UPDATED_AT"::varchar, '^Z[ ]*', '')) as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_T_KYC_OCR') }}

)

select * from source
