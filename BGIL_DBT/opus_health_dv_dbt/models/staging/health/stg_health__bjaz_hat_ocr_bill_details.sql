-- Staging for source table BJAZ_HAT_OCR_BILL_DETAILS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("BILLHEAD")), '') as billhead,
        nullif(trim(to_varchar("CASE_ID")), '') as case_id,
        nullif(trim(to_varchar("CLAIMED_AMOUNT")), '') as claimed_amount,
        nullif(trim(to_varchar("I3_PARTICULAR_ID")), '') as i3_particular_id,
        nullif(trim(to_varchar("INWARD_NO")), '') as inward_no,
        nullif(trim(to_varchar("IS_PAYBLE")), '') as is_payble,
        nullif(trim(to_varchar("LEVEL1")), '') as level1,
        nullif(trim(to_varchar("LEVEL2")), '') as level2,
        nullif(trim(to_varchar("LEVEL3")), '') as level3,
        nullif(trim(to_varchar("LEVEL5")), '') as level5,
        nullif(trim(to_varchar("PARTICULAR")), '') as particular,
        nullif(trim(to_varchar("PRICE")), '') as price,
        nullif(trim(to_varchar("UNIT")), '') as unit
    from {{ source('health_raw', 'BJAZ_HAT_OCR_BILL_DETAILS') }}

)

select * from source
