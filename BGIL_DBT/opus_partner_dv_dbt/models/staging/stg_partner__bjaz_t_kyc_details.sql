{{ config(materialized='view') }}

-- Staging model for source table BJAZ_T_KYC_DETAILS (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.

with source as (

    select
    "BAGIC_KYC_ID"::number as bagic_kyc_id,
    "INCOMING_ID"::number as incoming_id,
    nullif(trim("CATEGORY"::varchar), '') as category,
    nullif(trim("INPUT"::varchar), '') as input,
    nullif(trim("BUSINESS_UNIT"::varchar), '') as business_unit,
    nullif(trim("FIELD_TYPE"::varchar), '') as field_type,
    nullif(trim("FIELD_VALUE"::varchar), '') as field_value,
    nullif(trim("PARTNER_ID"::varchar), '') as partner_id,
    nullif(trim("KYC_DATE"::varchar), '') as kyc_date,
    "SEARCH_ID"::number as search_id,
    "AUTH_ID"::number as auth_id,
    "POI_DOC_ID"::number as poi_doc_id,
    "POA_DOC_ID"::number as poa_doc_id,
    nullif(trim("KYC_STATUS"::varchar), '') as kyc_status,
    "PAN_ID"::number as pan_id,
    "PASSPORT_ID"::number as passport_id,
    "VOTER_ID"::number as voter_id,
    "LICENCE_ID"::number as licence_id,
    "GSTIN_ID"::number as gstin_id,
    try_to_timestamp_ntz(regexp_replace("CREATED_DATE"::varchar, '^Z[ ]*', '')) as created_date,
    try_to_timestamp_ntz(regexp_replace("MODIFY_DATE"::varchar, '^Z[ ]*', '')) as modify_date,
    nullif(trim("POI_CATEGORY"::varchar), '') as poi_category,
    nullif(trim("POI_INPUT"::varchar), '') as poi_input,
    nullif(trim("POI_RESPONSE_FULL_NAME"::varchar), '') as poi_response_full_name,
    nullif(trim("REQUEST_FULL_NAME"::varchar), '') as request_full_name,
    nullif(trim("REQUEST_DOB"::varchar), '') as request_dob,
    nullif(trim("RESPONSE_FULL_NAME"::varchar), '') as response_full_name,
    nullif(trim("RESPONSE_DOB"::varchar), '') as response_dob,
    nullif(trim("KYC_DEACTIVATE_REASON"::varchar), '') as kyc_deactivate_reason,
    try_to_timestamp_ntz(regexp_replace("KYC_DEACTIVATE_DATE"::varchar, '^Z[ ]*', '')) as kyc_deactivate_date,
    nullif(trim("REMARK"::varchar), '') as remark,
    "EKYC_ID"::number as ekyc_id,
    "CKYC_NAME_MATCH_ID"::number as ckyc_name_match_id,
    "POI_NAME_MATCH_ID"::number as poi_name_match_id,
    "POA_NAME_MATCH_ID"::number as poa_name_match_id,
    "DIRECT_KYC_ID"::number as direct_kyc_id,
    nullif(trim("BUSINESS_TYPE"::varchar), '') as business_type,
    nullif(trim("AWS_SERVICE"::varchar), '') as aws_service,
    "EKYC_NAME_MATCH_ID"::number as ekyc_name_match_id,
    "CKYC_DOWNLOAD_ID"::number as ckyc_download_id,
    nullif(trim("POLICY_NAME_CONSENT"::varchar), '') as policy_name_consent,
    nullif(trim("POLICY_NAME"::varchar), '') as policy_name,
    nullif(trim("MOBILE_NUMBER"::varchar), '') as mobile_number,
    nullif(trim("KYC_VERSION"::varchar), '') as kyc_version,
    nullif(trim("CUSTOMER_KYC_CONSENT"::varchar), '') as customer_kyc_consent,
    nullif(trim("BGIL_TP_VERIFYING_CONSENT"::varchar), '') as bgil_tp_verifying_consent,
    nullif(trim("BGIL_CHANGE_DATA_CONSENT"::varchar), '') as bgil_change_data_consent,
    nullif(trim("BGIL_UPDATE_GOV_CONSENT"::varchar), '') as bgil_update_gov_consent,
    to_timestamp_ntz(regexp_replace("INC_JOB_UPDATED_AT"::varchar, '^Z[ ]*', '')) as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_T_KYC_DETAILS') }}

)

select * from source
