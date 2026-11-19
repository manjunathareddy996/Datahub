-- Staging for source table BJAZ_MOT_RNW_VALIDATE_VEH_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("SERIAL_NO")), '') as serial_no,
        nullif(trim(to_varchar("VAHAN_REFNO")), '') as vahan_refno,
        nullif(trim(to_varchar("VEH_TYPE")), '') as veh_type,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("SOURCE_NAME")), '') as source_name,
        nullif(trim(to_varchar("USER_ID")), '') as user_id,
        nullif(trim(to_varchar("REGISTRATION_NO")), '') as registration_no,
        nullif(trim(to_varchar("ENGINE_NUMBER")), '') as engine_number,
        nullif(trim(to_varchar("CHASIS_NUMBER")), '') as chasis_number,
        nullif(trim(to_varchar("VEH_CLASS_DESC")), '') as veh_class_desc,
        nullif(trim(to_varchar("VALIDATE_MSG")), '') as validate_msg,
        nullif(trim(to_varchar("DATA_SERVED_BY")), '') as data_served_by,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("ERROR_MESSAGE")), '') as error_message,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("MODULE_ID")), '') as module_id,
        nullif(trim(to_varchar("API_CALL")), '') as api_call,
        nullif(trim(to_varchar("PROCESS_DATE")), '') as process_date,
        nullif(trim(to_varchar("PREV_STATUS")), '') as prev_status,
        nullif(trim(to_varchar("JOBS_NAME")), '') as jobs_name,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("CHANGE_STATUS_BY_USER")), '') as change_status_by_user,
        nullif(trim(to_varchar("STATUS_CHANGE_USER_ID")), '') as status_change_user_id,
        nullif(trim(to_varchar("USER_STATUS_CHANGES_DATE")), '') as user_status_changes_date,
        nullif(trim(to_varchar("CHANGE_APPROVAL_RECEIVE")), '') as change_approval_receive,
        nullif(trim(to_varchar("USER_REMARKS")), '') as user_remarks,
        nullif(trim(to_varchar("USER_MACHINE_IP")), '') as user_machine_ip,
        nullif(trim(to_varchar("USER_PROXY_IP")), '') as user_proxy_ip,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOT_RNW_VALIDATE_VEH_DTLS') }}

)

select * from source
