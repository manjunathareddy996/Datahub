-- Staging for source table BJAZ_HM_CLAIM_CONVERSION (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CONVERT_DATE")), '') as convert_date,
        nullif(trim(to_varchar("CONV_ID")), '') as conv_id,
        nullif(trim(to_varchar("CONV_TYPE")), '') as conv_type,
        nullif(trim(to_varchar("PREV_CLAIM_ID")), '') as prev_claim_id,
        nullif(trim(to_varchar("UPDATED_BY")), '') as updated_by,
        nullif(trim(to_varchar("UPDATED_ON")), '') as updated_on
    from {{ source('health_raw', 'BJAZ_HM_CLAIM_CONVERSION') }}

)

select * from source
