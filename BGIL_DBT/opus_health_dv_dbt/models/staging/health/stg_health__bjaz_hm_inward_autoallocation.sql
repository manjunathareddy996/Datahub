-- Staging for source table BJAZ_HM_INWARD_AUTOALLOCATION (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ALLOCATE_FLAG")), '') as allocate_flag,
        nullif(trim(to_varchar("ALLOCATE_ID")), '') as allocate_id,
        nullif(trim(to_varchar("ALLOCATE_ON")), '') as allocate_on,
        nullif(trim(to_varchar("ALLOCATE_TO")), '') as allocate_to,
        nullif(trim(to_varchar("BUCKET_STATUS")), '') as bucket_status,
        nullif(trim(to_varchar("CASHLESS_IN_NO")), '') as cashless_in_no,
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("OMNI_INWARD_NO")), '') as omni_inward_no
    from {{ source('health_raw', 'BJAZ_HM_INWARD_AUTOALLOCATION') }}

)

select * from source
