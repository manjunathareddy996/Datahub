-- Staging for source table BJAZ_CLM_SUBFILE_MOT_EXT. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("SF_NO")), '') as sf_no,
        nullif(trim(to_varchar("SF_COMMENTS")), '') as sf_comments,
        nullif(trim(to_varchar("FIR_NO")), '') as fir_no,
        nullif(trim(to_varchar("POLICE_STATION_NAME")), '') as police_station_name,
        nullif(trim(to_varchar("POLICE_STATION_ADDRESS")), '') as police_station_address,
        nullif(trim(to_varchar("INVESTIGATOR_NAME")), '') as investigator_name,
        nullif(trim(to_varchar("PANCHANAMA_DETAILS")), '') as panchanama_details,
        nullif(trim(to_varchar("CASE_FILED")), '') as case_filed,
        nullif(trim(to_varchar("CASE_DETAILS")), '') as case_details,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_CLM_SUBFILE_MOT_EXT') }}

)

select * from source
