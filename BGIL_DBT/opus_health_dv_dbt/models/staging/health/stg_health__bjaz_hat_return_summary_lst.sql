-- Staging for source table BJAZ_HAT_RETURN_SUMMARY_LST (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("RET_AMOUNT_PER_UNIT")), '') as ret_amount_per_unit,
        nullif(trim(to_varchar("RET_CASE_ID")), '') as ret_case_id,
        nullif(trim(to_varchar("RET_CLAIMED_AMOUNT")), '') as ret_claimed_amount,
        nullif(trim(to_varchar("RET_IS_PAYABLE")), '') as ret_is_payable,
        nullif(trim(to_varchar("RET_LEVEL_1")), '') as ret_level_1,
        nullif(trim(to_varchar("RET_LEVEL_2")), '') as ret_level_2,
        nullif(trim(to_varchar("RET_LEVEL_3")), '') as ret_level_3,
        nullif(trim(to_varchar("RET_PARTICULAR")), '') as ret_particular,
        nullif(trim(to_varchar("RET_UNIT")), '') as ret_unit
    from {{ source('health_raw', 'BJAZ_HAT_RETURN_SUMMARY_LST') }}

)

select * from source
