-- Staging for source table RTA_CLUSTER_PREFERRED_DECLINE. Every column trimmed varchar: the tables index carries
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
        nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
        nullif(trim(to_varchar("VEHICLE_TYPE")), '') as vehicle_type,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("POLICY_PLAN")), '') as policy_plan,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("SUB_IMD_CODE")), '') as sub_imd_code,
        nullif(trim(to_varchar("AGENT_CHANNEL")), '') as agent_channel,
        nullif(trim(to_varchar("SUB_CHANNEL")), '') as sub_channel,
        nullif(trim(to_varchar("CONFIG")), '') as config,
        nullif(trim(to_varchar("RTA_CLUSTER")), '') as rta_cluster,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("PROCESS_DATE")), '') as process_date,
        nullif(trim(to_varchar("MAXIMUS_PROCESS_DATE")), '') as maximus_process_date,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'RTA_CLUSTER_PREFERRED_DECLINE') }}

)

select * from source
