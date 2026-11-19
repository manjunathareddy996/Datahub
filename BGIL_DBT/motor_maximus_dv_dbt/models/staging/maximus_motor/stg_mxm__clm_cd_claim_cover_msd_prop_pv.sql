-- Staging for source view MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("1ST_REMINDER_DATE")), '') as c_1st_reminder_date,
        nullif(trim(to_varchar("2ND_REMINDER_DATE")), '') as c_2nd_reminder_date,
        nullif(trim(to_varchar("3RD_REMINDER_DATE")), '') as c_3rd_reminder_date,
        nullif(trim(to_varchar("ACKNOWLEDGMENT_RECEIVED")), '') as acknowledgment_received,
        nullif(trim(to_varchar("CITY")), '') as city,
        nullif(trim(to_varchar("CLAIM_REOPENING_REASON")), '') as claim_reopening_reason,
        nullif(trim(to_varchar("CLAIM_REPUDIATION_REASON")), '') as claim_repudiation_reason,
        nullif(trim(to_varchar("CLAIM_SUBSTATUS")), '') as claim_substatus,
        nullif(trim(to_varchar("CLOSURE_DATE")), '') as closure_date,
        nullif(trim(to_varchar("COURIERPOST_NAME")), '') as courierpost_name,
        nullif(trim(to_varchar("COURIER_NAME")), '') as courier_name,
        nullif(trim(to_varchar("COVER_NAME")), '') as cover_name,
        nullif(trim(to_varchar("COVER_TAKEN")), '') as cover_taken,
        nullif(trim(to_varchar("DOCUMENT_DETAILS")), '') as document_details,
        nullif(trim(to_varchar("DOCUMENT_RECEIVED_DATE")), '') as document_received_date,
        nullif(trim(to_varchar("DOCUMENT_TYPE_INWARD")), '') as document_type_inward,
        nullif(trim(to_varchar("DOCUMENT_TYPE_OUTWARD")), '') as document_type_outward,
        nullif(trim(to_varchar("INTIMATION_DATE")), '') as intimation_date,
        nullif(trim(to_varchar("INWARD_DATE")), '') as inward_date,
        nullif(trim(to_varchar("INWARD_NUMBER")), '') as inward_number,
        nullif(trim(to_varchar("IS_THIS_FINAL_DOCUMENT")), '') as is_this_final_document,
        nullif(trim(to_varchar("LAST_UPDATED_BY")), '') as last_updated_by,
        nullif(trim(to_varchar("MODE_OF_DISPATCH")), '') as mode_of_dispatch,
        nullif(trim(to_varchar("MODE_OF_INWARD")), '') as mode_of_inward,
        nullif(trim(to_varchar("OUTWARD_DATE")), '') as outward_date,
        nullif(trim(to_varchar("OUTWARD_NUMBER")), '') as outward_number,
        nullif(trim(to_varchar("PIN_CODE")), '') as pin_code,
        nullif(trim(to_varchar("POD_NUMBER")), '') as pod_number,
        nullif(trim(to_varchar("REMARKS")), '') as remarks,
        nullif(trim(to_varchar("REPUDIATION_REMARKS")), '') as repudiation_remarks,
        nullif(trim(to_varchar("REQUIRED_FROM")), '') as required_from,
        nullif(trim(to_varchar("REQUIREMENT_STATUS")), '') as requirement_status,
        nullif(trim(to_varchar("REQUIREMENT_TYPE_NAME")), '') as requirement_type_name,
        nullif(trim(to_varchar("RESPONSE")), '') as response,
        nullif(trim(to_varchar("SENDER_NAME")), '') as sender_name,
        nullif(trim(to_varchar("SENT_TO")), '') as sent_to,
        nullif(trim(to_varchar("SPECIAL_ENCLOSURES_DETAILS")), '') as special_enclosures_details,
        nullif(trim(to_varchar("SPECIAL_ENCLOSURES_FLAG")), '') as special_enclosures_flag,
        nullif(trim(to_varchar("STATE")), '') as state
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW') }}

)

select * from source
