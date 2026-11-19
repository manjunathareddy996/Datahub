-- Staging for source table RTO_MASTER. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("OPUS_UNIQUE_ID")), '') as opus_unique_id,
        nullif(trim(to_varchar("MAXIMUS_UNIQUE_ID")), '') as maximus_unique_id,
        nullif(trim(to_varchar("UPDATE_FLAG")), '') as update_flag,
        nullif(trim(to_varchar("START_DATE")), '') as start_date,
        nullif(trim(to_varchar("END_DATE")), '') as end_date,
        nullif(trim(to_varchar("RTA_CODE")), '') as rta_code,
        nullif(trim(to_varchar("RTA_CITY")), '') as rta_city,
        nullif(trim(to_varchar("REGISTRATION_ZONE")), '') as registration_zone,
        nullif(trim(to_varchar("RTA_STATE")), '') as rta_state,
        nullif(trim(to_varchar("RTA_DISTRICT")), '') as rta_district,
        nullif(trim(to_varchar("ADDRESS_LINE_1")), '') as address_line_1,
        nullif(trim(to_varchar("ADDRESS_LINE_2")), '') as address_line_2,
        nullif(trim(to_varchar("ADDRESS_LINE_3")), '') as address_line_3,
        nullif(trim(to_varchar("AREA")), '') as area,
        nullif(trim(to_varchar("RTA_PINCODE")), '') as rta_pincode,
        nullif(trim(to_varchar("TEMPERATURE_ZONE")), '') as temperature_zone,
        nullif(trim(to_varchar("AREA_INFRASTRUCTURE")), '') as area_infrastructure,
        nullif(trim(to_varchar("COMM_REGISTRATION_ZONE")), '') as comm_registration_zone,
        nullif(trim(to_varchar("PROCESS_DATE")), '') as process_date,
        nullif(trim(to_varchar("MAXIMUS_PROCESS_DATE")), '') as maximus_process_date,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'RTO_MASTER') }}

)

select * from source
