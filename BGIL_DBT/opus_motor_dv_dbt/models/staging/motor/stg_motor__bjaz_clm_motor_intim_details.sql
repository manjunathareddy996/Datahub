-- Staging for source table BJAZ_CLM_MOTOR_INTIM_DETAILS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("INTIMATION_ID")), '') as intimation_id,
        nullif(trim(to_varchar("CP_NAME")), '') as cp_name,
        nullif(trim(to_varchar("CP_ADDRESS")), '') as cp_address,
        nullif(trim(to_varchar("CP_LANDMARK")), '') as cp_landmark,
        nullif(trim(to_varchar("CP_STREET")), '') as cp_street,
        nullif(trim(to_varchar("CP_AREA")), '') as cp_area,
        nullif(trim(to_varchar("CP_CITY")), '') as cp_city,
        nullif(trim(to_varchar("CP_STATE")), '') as cp_state,
        nullif(trim(to_varchar("CP_PINCODE")), '') as cp_pincode,
        nullif(trim(to_varchar("CP_TEL")), '') as cp_tel,
        nullif(trim(to_varchar("CP_MOBILE")), '') as cp_mobile,
        nullif(trim(to_varchar("TIME_OF_LOSS")), '') as time_of_loss,
        nullif(trim(to_varchar("LOSS_DESC")), '') as loss_desc,
        nullif(trim(to_varchar("CAUSE_OF_LOSS")), '') as cause_of_loss,
        nullif(trim(to_varchar("CLM_LANDMARK")), '') as clm_landmark,
        nullif(trim(to_varchar("CLM_STREET")), '') as clm_street,
        nullif(trim(to_varchar("CLM_AREA")), '') as clm_area,
        nullif(trim(to_varchar("CLM_CITY")), '') as clm_city,
        nullif(trim(to_varchar("CLM_STATE")), '') as clm_state,
        nullif(trim(to_varchar("CLM_PINCODE")), '') as clm_pincode,
        nullif(trim(to_varchar("WHERE_LYING")), '') as where_lying,
        nullif(trim(to_varchar("WHERE_INSPECT")), '') as where_inspect,
        nullif(trim(to_varchar("CLAIM_LOCATION")), '') as claim_location,
        nullif(trim(to_varchar("CLAIM_TYPE")), '') as claim_type,
        nullif(trim(to_varchar("GARAGE_ID")), '') as garage_id,
        nullif(trim(to_varchar("EST_LOSS_AMOUNT")), '') as est_loss_amount,
        nullif(trim(to_varchar("FIELD1")), '') as field1,
        nullif(trim(to_varchar("FIELD2")), '') as field2,
        nullif(trim(to_varchar("FIELD3")), '') as field3,
        nullif(trim(to_varchar("DRIVER_NAME")), '') as driver_name,
        nullif(trim(to_varchar("DRIVER_RELATION")), '') as driver_relation,
        nullif(trim(to_varchar("CALLER_NAME")), '') as caller_name,
        nullif(trim(to_varchar("CALLER_TELEPHONE")), '') as caller_telephone,
        nullif(trim(to_varchar("WORKSHOP_STATUS")), '') as workshop_status,
        nullif(trim(to_varchar("ODO_READING")), '') as odo_reading,
        nullif(trim(to_varchar("LOSS_TYPE")), '') as loss_type,
        nullif(trim(to_varchar("SUPP_ID")), '') as supp_id,
        nullif(trim(to_varchar("DRIVER_LICENSE_NO")), '') as driver_license_no,
        nullif(trim(to_varchar("DRV_LIC_EXP")), '') as drv_lic_exp,
        nullif(trim(to_varchar("INSURED_DOB")), '') as insured_dob,
        nullif(trim(to_varchar("INSURED_PANNO")), '') as insured_panno,
        nullif(trim(to_varchar("VEHICLE_LEFT_YN")), '') as vehicle_left_yn,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_CLM_MOTOR_INTIM_DETAILS') }}

)

select * from source
