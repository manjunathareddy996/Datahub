-- Staging for source table BJAZ_HM_CLAIM_TRACKER (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CLAIM_STATUS")), '') as claim_status,
        nullif(trim(to_varchar("PREV_CLAIM_STATUS")), '') as prev_claim_status,
        nullif(trim(to_varchar("PROCESS_NAME")), '') as process_name,
        nullif(trim(to_varchar("UPDATED_BY")), '') as updated_by,
        nullif(trim(to_varchar("UPDATED_ON")), '') as updated_on,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no
    from {{ source('health_raw', 'BJAZ_HM_CLAIM_TRACKER') }}

)

select * from source
