-- Staging for source view MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("ACCOUNT_NUMBER")), '') as account_number,
        nullif(trim(to_varchar("ACCOUNT_TYPE")), '') as account_type,
        nullif(trim(to_varchar("ADDRESS_LINE_1")), '') as address_line_1,
        nullif(trim(to_varchar("ADDRESS_LINE_2")), '') as address_line_2,
        nullif(trim(to_varchar("ADDRESS_LINE_3")), '') as address_line_3,
        nullif(trim(to_varchar("ADDRESS_SAME_AS_POLICY_HOLDER")), '') as address_same_as_policy_holder,
        nullif(trim(to_varchar("BANK_DETAILS1")), '') as bank_details1,
        nullif(trim(to_varchar("BANK_NAME")), '') as bank_name,
        nullif(trim(to_varchar("BRANCH_NAME1")), '') as branch_name1,
        nullif(trim(to_varchar("CHEQUE_SERVICING_STATE")), '') as cheque_servicing_state,
        nullif(trim(to_varchar("CLAIM_KYC_COMPLIANCE_DONE")), '') as claim_kyc_compliance_done,
        nullif(trim(to_varchar("DIFFERENTIAL_TDS")), '') as differential_tds,
        nullif(trim(to_varchar("EMAIL_ID")), '') as email_id,
        nullif(trim(to_varchar("EMIRATESSTATEP")), '') as emiratesstatep,
        nullif(trim(to_varchar("END_DATE")), '') as end_date,
        nullif(trim(to_varchar("FIXED_PAYMENT")), '') as fixed_payment,
        nullif(trim(to_varchar("IFSC_CODE")), '') as ifsc_code,
        nullif(trim(to_varchar("IRDA_CATEGORY")), '') as irda_category,
        nullif(trim(to_varchar("LICENSE_EXPIRY_DATE")), '') as license_expiry_date,
        nullif(trim(to_varchar("LICENSE_NUMBER")), '') as license_number,
        nullif(trim(to_varchar("LICENSE_REGISTRATION_DATE")), '') as license_registration_date,
        nullif(trim(to_varchar("LOB")), '') as lob,
        nullif(trim(to_varchar("MOBILE_NO")), '') as mobile_no,
        nullif(trim(to_varchar("NEFT_STATUS")), '') as neft_status,
        nullif(trim(to_varchar("PAN_NUMBER")), '') as pan_number,
        nullif(trim(to_varchar("PAYBLE_AT")), '') as payble_at,
        nullif(trim(to_varchar("PERCENTAGE_FOR_PAYMENT")), '') as percentage_for_payment,
        nullif(trim(to_varchar("PINCODE1")), '') as pincode1,
        nullif(trim(to_varchar("REIMBURSEMENT_PREFERENCES")), '') as reimbursement_preferences,
        nullif(trim(to_varchar("SERVICE_TAX_APPLICABLE")), '') as service_tax_applicable,
        nullif(trim(to_varchar("SERVICE_TAX_REGISTRATION_NUMBER")), '') as service_tax_registration_number,
        nullif(trim(to_varchar("START_DATE")), '') as start_date,
        nullif(trim(to_varchar("TDS_TYPE")), '') as tds_type,
        nullif(trim(to_varchar("TYPE_OF_BENEFICIARY")), '') as type_of_beneficiary,
        nullif(trim(to_varchar("TYPE_OF_PAYMENT")), '') as type_of_payment
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW') }}

)

select * from source
