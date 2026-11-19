-- Staging for source table BJAZ_MOT_WAR_MAST_CHILD. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("MASTER_CONTRACT_ID")), '') as master_contract_id,
        nullif(trim(to_varchar("CHILD_CONTRACT_ID")), '') as child_contract_id,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOT_WAR_MAST_CHILD') }}

)

select * from source
