-- Staging for source table BJAZ_REMEDINET_CLAIM_DETAILS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ACTION_STATUS")), '') as action_status,
        nullif(trim(to_varchar("ACTUAL_PACKAGE_AMOUNT")), '') as actual_package_amount,
        nullif(trim(to_varchar("APPROVAL_FILE_NAME")), '') as approval_file_name,
        nullif(trim(to_varchar("APPROVED_DATE")), '') as approved_date,
        nullif(trim(to_varchar("APPROVED_PACKAGE_AMOUNT")), '') as approved_package_amount,
        nullif(trim(to_varchar("CLAIMED_PACKAGE_AMOUNT")), '') as claimed_package_amount,
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CLAIM_NO")), '') as claim_no,
        nullif(trim(to_varchar("CLAIM_STATUS")), '') as claim_status,
        nullif(trim(to_varchar("CLAIM_TYPE")), '') as claim_type,
        nullif(trim(to_varchar("COMPRESSED_FILE")), '') as compressed_file,
        nullif(trim(to_varchar("COPAY_AMOUNT")), '') as copay_amount,
        nullif(trim(to_varchar("COPAY_TYPE")), '') as copay_type,
        nullif(trim(to_varchar("CORPORATE_NAME")), '') as corporate_name,
        nullif(trim(to_varchar("DEDUCTION_AMOUNT")), '') as deduction_amount,
        nullif(trim(to_varchar("EMPLOYEE_ID")), '') as employee_id,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("INSURANCE_COMPANY")), '') as insurance_company,
        nullif(trim(to_varchar("IRDA_ID")), '') as irda_id,
        nullif(trim(to_varchar("IS_DOCUMENT_RECEIVED")), '') as is_document_received,
        nullif(trim(to_varchar("MEMBER_PHOTO_FILE_NAME")), '') as member_photo_file_name,
        nullif(trim(to_varchar("OMNI_INWARD_NO")), '') as omni_inward_no,
        nullif(trim(to_varchar("PATIENT_PAID_AMOUNT")), '') as patient_paid_amount,
        nullif(trim(to_varchar("PAYER_CODE")), '') as payer_code,
        nullif(trim(to_varchar("PAYER_NAME")), '') as payer_name,
        nullif(trim(to_varchar("PAYER_PROVIDER_CODE")), '') as payer_provider_code,
        nullif(trim(to_varchar("PAYER_REFERENCE_NO")), '') as payer_reference_no,
        nullif(trim(to_varchar("PAYER_REMARKS")), '') as payer_remarks,
        nullif(trim(to_varchar("POLICY_NO")), '') as policy_no,
        nullif(trim(to_varchar("PREAUTH_AMOUNT")), '') as preauth_amount,
        nullif(trim(to_varchar("PREAUTH_NO")), '') as preauth_no,
        nullif(trim(to_varchar("PROVIDER_NAME")), '') as provider_name,
        nullif(trim(to_varchar("PROVIDER_REMARKS")), '') as provider_remarks,
        nullif(trim(to_varchar("REMEDINET_PROVIDER_CODE")), '') as remedinet_provider_code,
        nullif(trim(to_varchar("TARIFF_NAME")), '') as tariff_name,
        nullif(trim(to_varchar("TDS")), '') as tds,
        nullif(trim(to_varchar("TOTAL_ALLOWED_AMOUNT")), '') as total_allowed_amount,
        nullif(trim(to_varchar("TOTAL_APPROVED_AMOUNT")), '') as total_approved_amount,
        nullif(trim(to_varchar("TOTAL_BILL_AMOUNT")), '') as total_bill_amount,
        nullif(trim(to_varchar("TOTAL_CLAIMED_AMOUNT")), '') as total_claimed_amount,
        nullif(trim(to_varchar("TOTAL_PAYABLE_AMOUNT")), '') as total_payable_amount,
        nullif(trim(to_varchar("ZONE_NAME")), '') as zone_name
    from {{ source('health_raw', 'BJAZ_REMEDINET_CLAIM_DETAILS') }}

)

select * from source
