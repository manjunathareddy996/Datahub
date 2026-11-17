-- Staging for source table BJAZ_WAP_MOT_GS_ACT_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("SR_NO")), '') as sr_no,
        nullif(trim(to_varchar("GS_ACT_ID")), '') as gs_act_id,
        nullif(trim(to_varchar("DESIGNATION")), '') as designation,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("SUBIMD_CODE")), '') as subimd_code,
        nullif(trim(to_varchar("NEXT_MEETING")), '') as next_meeting,
        nullif(trim(to_varchar("UPDATE_DT")), '') as update_dt,
        nullif(trim(to_varchar("CHANNEL_FLAG")), '') as channel_flag,
        nullif(trim(to_varchar("HEALTH_PREM")), '') as health_prem,
        nullif(trim(to_varchar("NON_HEALTH_PREM")), '') as non_health_prem,
        nullif(trim(to_varchar("LAP_NO")), '') as lap_no,
        nullif(trim(to_varchar("REASON")), '') as reason,
        nullif(trim(to_varchar("BRANCH_NAME")), '') as branch_name,
        nullif(trim(to_varchar("BRANCH_CODE")), '') as branch_code,
        nullif(trim(to_varchar("PRODUCT_DISCUS")), '') as product_discus,
        nullif(trim(to_varchar("CUST_NAME")), '') as cust_name,
        nullif(trim(to_varchar("CUST_CONTACT")), '') as cust_contact,
        nullif(trim(to_varchar("BANK_RM_DTL")), '') as bank_rm_dtl,
        nullif(trim(to_varchar("EXPECT_PREM")), '') as expect_prem,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("FOLLOW_UP_DATE")), '') as follow_up_date,
        nullif(trim(to_varchar("LATITUDE")), '') as latitude,
        nullif(trim(to_varchar("LONGITUDE")), '') as longitude,
        nullif(trim(to_varchar("GOOGLE_ADD")), '') as google_add,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_WAP_MOT_GS_ACT_DTLS') }}

)

select * from source
