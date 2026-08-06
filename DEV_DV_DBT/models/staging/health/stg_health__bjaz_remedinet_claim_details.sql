-- Staging model for source table BJAZ_REMEDINET_CLAIM_DETAILS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "ACTION_STATUS"::number as action_status,
    "ACTUAL_PACKAGE_AMOUNT"::number as actual_package_amount,
    nullif(trim("APPROVAL_FILE_NAME"::varchar), '') as approval_file_name,
    nullif(trim("APPROVED_DATE"::varchar), '') as approved_date,
    "CLAIMED_PACKAGE_AMOUNT"::number as claimed_package_amount,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("CLAIM_NO")), '') as claim_no,
    nullif(trim("CLAIM_STATUS"::varchar), '') as claim_status,
    "CLAIM_TYPE"::number as claim_type,
    nullif(trim("COMPRESSED_FILE"::varchar), '') as compressed_file,
    "COPAY_AMOUNT"::number as copay_amount,
    nullif(trim("CORPORATE_NAME"::varchar), '') as corporate_name,
    "DEDUCTION_AMOUNT"::number as deduction_amount,
    nullif(trim("EMPLOYEE_ID"::varchar), '') as employee_id,
    nullif(trim("INSURANCE_COMPANY"::varchar), '') as insurance_company,
    nullif(trim("IRDA_ID"::varchar), '') as irda_id,
    "IS_DOCUMENT_RECEIVED"::number as is_document_received,
    nullif(trim("MEMBER_PHOTO_FILE_NAME"::varchar), '') as member_photo_file_name,
    nullif(trim(to_varchar("OMNI_INWARD_NO")), '') as omni_inward_no,
    nullif(trim(to_varchar("PAYER_CODE")), '') as payer_code,
    nullif(trim("PAYER_NAME"::varchar), '') as payer_name,
    nullif(trim("PAYER_REFERENCE_NO"::varchar), '') as payer_reference_no,
    nullif(trim("PAYER_REMARKS"::varchar), '') as payer_remarks,
    nullif(trim(to_varchar("POLICY_NO")), '') as policy_no,
    "PREAUTH_AMOUNT"::number as preauth_amount,
    nullif(trim("PREAUTH_NO"::varchar), '') as preauth_no,
    nullif(trim("PROVIDER_NAME"::varchar), '') as provider_name,
    nullif(trim("PROVIDER_REMARKS"::varchar), '') as provider_remarks,
    nullif(trim(to_varchar("REMEDINET_PROVIDER_CODE")), '') as remedinet_provider_code,
    nullif(trim("TARIFF_NAME"::varchar), '') as tariff_name,
    "TDS"::number as tds,
    "TOTAL_ALLOWED_AMOUNT"::number as total_allowed_amount,
    "TOTAL_APPROVED_AMOUNT"::number as total_approved_amount,
    "TOTAL_BILL_AMOUNT"::number as total_bill_amount,
    "TOTAL_PAYABLE_AMOUNT"::number as total_payable_amount,
    nullif(trim("ZONE_NAME"::varchar), '') as zone_name
    from {{ source('health_raw', 'BJAZ_REMEDINET_CLAIM_DETAILS') }}

)

select * from source
