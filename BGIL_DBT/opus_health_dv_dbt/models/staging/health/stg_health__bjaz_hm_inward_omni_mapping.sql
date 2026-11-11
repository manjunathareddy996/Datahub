-- Staging for source table BJAZ_HM_INWARD_OMNI_MAPPING (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CASHLESS_IN_ID")), '') as cashless_in_id,
        nullif(trim(to_varchar("OMNI_INWARD_NO")), '') as omni_inward_no,
        nullif(trim(to_varchar("REDIRECT_FLAG")), '') as redirect_flag
    from {{ source('health_raw', 'BJAZ_HM_INWARD_OMNI_MAPPING') }}

)

select * from source
