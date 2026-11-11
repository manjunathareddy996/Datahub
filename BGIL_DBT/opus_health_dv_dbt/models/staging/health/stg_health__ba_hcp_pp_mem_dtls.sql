-- Staging for source table BA_HCP_PP_MEM_DTLS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("ALLOTED_TO")), '') as alloted_to,
        nullif(trim(to_varchar("APPOINTMENT_CODE")), '') as appointment_code,
        nullif(trim(to_varchar("APP_DATE")), '') as app_date,
        nullif(trim(to_varchar("APP_TIME")), '') as app_time,
        nullif(trim(to_varchar("CHECKUP_AMT")), '') as checkup_amt,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("DATE_OF_BIRTH")), '') as date_of_birth,
        nullif(trim(to_varchar("DC_ADDRESS")), '') as dc_address,
        nullif(trim(to_varchar("DC_CITY")), '') as dc_city,
        nullif(trim(to_varchar("DC_LOCATION")), '') as dc_location,
        nullif(trim(to_varchar("DC_NAME")), '') as dc_name,
        nullif(trim(to_varchar("DC_PINCODE")), '') as dc_pincode,
        nullif(trim(to_varchar("DC_STATE")), '') as dc_state,
        nullif(trim(to_varchar("DC_TELENO")), '') as dc_teleno,
        nullif(trim(to_varchar("HI_CONTROL_NUMBER")), '') as hi_control_number,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("MEMBER_NAME")), '') as member_name,
        nullif(trim(to_varchar("MEM_SEQNO")), '') as mem_seqno,
        nullif(trim(to_varchar("PAY_TYPE")), '') as pay_type,
        nullif(trim(to_varchar("PRIORITY_FLAG")), '') as priority_flag,
        nullif(trim(to_varchar("REMARKS")), '') as remarks,
        nullif(trim(to_varchar("RESCHEDULE_DATE")), '') as reschedule_date,
        nullif(trim(to_varchar("RESCHEDULE_TIME")), '') as reschedule_time,
        nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
        nullif(trim(to_varchar("STATUS_CODE")), '') as status_code,
        nullif(trim(to_varchar("STATUS_DESC")), '') as status_desc,
        nullif(trim(to_varchar("SUB_STATUS_CODE")), '') as sub_status_code,
        nullif(trim(to_varchar("SUB_STATUS_DESC")), '') as sub_status_desc,
        nullif(trim(to_varchar("TEST_CODE")), '') as test_code,
        nullif(trim(to_varchar("TYPE_OF_CHECKUP")), '') as type_of_checkup
    from {{ source('health_raw', 'BA_HCP_PP_MEM_DTLS') }}

)

select * from source
