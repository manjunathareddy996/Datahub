-- Staging for source table BJAZ_WS_MOTCLM_DETAILS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CLM_REF_ID")), '') as clm_ref_id,
        nullif(trim(to_varchar("MI_TRANS_ID")), '') as mi_trans_id,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("VEH_REG_NO")), '') as veh_reg_no,
        nullif(trim(to_varchar("CLAIM_TYPE")), '') as claim_type,
        nullif(trim(to_varchar("WORK_SHOP_ID")), '') as work_shop_id,
        nullif(trim(to_varchar("ACC_CITY_CODE")), '') as acc_city_code,
        nullif(trim(to_varchar("INTIMATION_DATE")), '') as intimation_date,
        nullif(trim(to_varchar("DATE_OF_LOSS")), '') as date_of_loss,
        nullif(trim(to_varchar("ACC_CAUSE")), '') as acc_cause,
        nullif(trim(to_varchar("ADVISOR_NAME")), '') as advisor_name,
        nullif(trim(to_varchar("ADVISOR_CONTACT")), '') as advisor_contact,
        nullif(trim(to_varchar("ESTIMATE_VERSION")), '') as estimate_version,
        nullif(trim(to_varchar("ESTIMATE_DATE")), '') as estimate_date,
        nullif(trim(to_varchar("EST_AMOUNT")), '') as est_amount,
        nullif(trim(to_varchar("PLASTIC_PARTS_EST_AMT")), '') as plastic_parts_est_amt,
        nullif(trim(to_varchar("METAL_PARTS_EST_AMT")), '') as metal_parts_est_amt,
        nullif(trim(to_varchar("GLASS_PARTS_EST_AMT")), '') as glass_parts_est_amt,
        nullif(trim(to_varchar("LABOUR_EST_AMT")), '') as labour_est_amt,
        nullif(trim(to_varchar("MISC_EST_AMT")), '') as misc_est_amt,
        nullif(trim(to_varchar("RECORD_STATUS")), '') as record_status,
        nullif(trim(to_varchar("DEALER_MAILID")), '') as dealer_mailid,
        nullif(trim(to_varchar("PROVISION_AMT")), '') as provision_amt,
        nullif(trim(to_varchar("OCM_INTIMATION")), '') as ocm_intimation,
        nullif(trim(to_varchar("REMARKS")), '') as remarks,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("CLM_REF")), '') as clm_ref,
        nullif(trim(to_varchar("LAST_MODIFIED_ON")), '') as last_modified_on,
        nullif(trim(to_varchar("PERIL")), '') as peril,
        nullif(trim(to_varchar("SUB_PERIL")), '') as sub_peril,
        nullif(trim(to_varchar("PIN_CODE")), '') as pin_code,
        nullif(trim(to_varchar("ODO_READING")), '') as odo_reading,
        nullif(trim(to_varchar("ERROR_DESC")), '') as error_desc,
        nullif(trim(to_varchar("VALIDATION_MSG")), '') as validation_msg,
        nullif(trim(to_varchar("VERSION")), '') as version,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("ESTIMATION_NO")), '') as estimation_no,
        nullif(trim(to_varchar("IN_STRING")), '') as in_string,
        nullif(trim(to_varchar("PAINT_EST_AMT")), '') as paint_est_amt,
        nullif(trim(to_varchar("MI_OUTPUT")), '') as mi_output,
        nullif(trim(to_varchar("ACC_TIME")), '') as acc_time,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        nullif(trim(to_varchar("TOTAL_DEN_EST_MAT")), '') as total_den_est_mat,
        nullif(trim(to_varchar("TOTAL_PART_EST_MAT")), '') as total_part_est_mat,
        nullif(trim(to_varchar("LOSS_TYPE")), '') as loss_type,
        nullif(trim(to_varchar("CAUSE_TYPE")), '') as cause_type,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_WS_MOTCLM_DETAILS') }}

)

select * from source
