-- Staging for source table BJAZ_PAYMOTORTHEFT_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CASE_ID")), '') as case_id,
        nullif(trim(to_varchar("CLM_REF")), '') as clm_ref,
        nullif(trim(to_varchar("ENGINE_NO")), '') as engine_no,
        nullif(trim(to_varchar("CHASSIS_NO")), '') as chassis_no,
        nullif(trim(to_varchar("REGISTRATION_NO")), '') as registration_no,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("INSURED_NAME")), '') as insured_name,
        nullif(trim(to_varchar("VEHICLE_MAKE")), '') as vehicle_make,
        nullif(trim(to_varchar("VEHICLE_MODEL")), '') as vehicle_model,
        nullif(trim(to_varchar("MANUFACTURE_YEAR")), '') as manufacture_year,
        nullif(trim(to_varchar("DATE_OF_LOSS")), '') as date_of_loss,
        nullif(trim(to_varchar("CLOSURE_DATE")), '') as closure_date,
        nullif(trim(to_varchar("IDV")), '') as idv,
        nullif(trim(to_varchar("PAID_AMOUNT")), '') as paid_amount,
        nullif(trim(to_varchar("VEHICLE_TYPE")), '') as vehicle_type,
        nullif(trim(to_varchar("RESPONSIBLE")), '') as responsible,
        nullif(trim(to_varchar("STATE_OWNER")), '') as state_owner,
        nullif(trim(to_varchar("MODIFY_BY")), '') as modify_by,
        nullif(trim(to_varchar("MODIFY_DATE")), '') as modify_date,
        nullif(trim(to_varchar("CASE_REPORT_DATE")), '') as case_report_date,
        nullif(trim(to_varchar("HO_ID")), '') as ho_id,
        nullif(trim(to_varchar("CASE_CLOSURE_DATE")), '') as case_closure_date,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("SUB_STATUS")), '') as sub_status,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("STAGE")), '') as stage,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_PAYMOTORTHEFT_DTLS') }}

)

select * from source
