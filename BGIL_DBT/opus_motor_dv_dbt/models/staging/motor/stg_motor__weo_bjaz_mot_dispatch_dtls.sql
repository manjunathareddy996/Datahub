-- Staging for source table WEO_BJAZ_MOT_DISPATCH_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("POLICY_NO")), '') as policy_no,
        nullif(trim(to_varchar("AIR_WAY_BILL_NO")), '') as air_way_bill_no,
        nullif(trim(to_varchar("COURIER_NAME")), '') as courier_name,
        nullif(trim(to_varchar("DISPATCH_DATE")), '') as dispatch_date,
        nullif(trim(to_varchar("DISPATCH_TIME")), '') as dispatch_time,
        nullif(trim(to_varchar("TRANS_DATE")), '') as trans_date,
        nullif(trim(to_varchar("DISP_STATUS")), '') as disp_status,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'WEO_BJAZ_MOT_DISPATCH_DTLS') }}

)

select * from source
