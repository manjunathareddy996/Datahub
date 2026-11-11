-- Staging for source table BJAZ_HM_USER_TAT (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ACTUAL_START_ON")), '') as actual_start_on,
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("END_ON")), '') as end_on,
        nullif(trim(to_varchar("LOG_ID")), '') as log_id,
        nullif(trim(to_varchar("LOG_TYPE")), '') as log_type,
        nullif(trim(to_varchar("NEXT_CASE")), '') as next_case,
        nullif(trim(to_varchar("PROCESS_TYPE")), '') as process_type,
        nullif(trim(to_varchar("START_ON")), '') as start_on,
        nullif(trim(to_varchar("STATUS_TYPE")), '') as status_type,
        nullif(trim(to_varchar("UPDATED_BY")), '') as updated_by,
        nullif(trim(to_varchar("UPDATED_ON")), '') as updated_on
    from {{ source('health_raw', 'BJAZ_HM_USER_TAT') }}

)

select * from source
