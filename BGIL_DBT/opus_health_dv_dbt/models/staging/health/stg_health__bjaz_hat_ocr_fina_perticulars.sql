-- Staging for source table BJAZ_HAT_OCR_FINA_PERTICULARS (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AMOUNT")), '') as amount,
        nullif(trim(to_varchar("BILLHEAD")), '') as billhead,
        nullif(trim(to_varchar("BILL_DATE")), '') as bill_date,
        nullif(trim(to_varchar("BILL_NUMBER")), '') as bill_number,
        nullif(trim(to_varchar("CASE_ID")), '') as case_id,
        nullif(trim(to_varchar("INWARD_NO")), '') as inward_no,
        nullif(trim(to_varchar("LEVEL_3")), '') as level_3,
        nullif(trim(to_varchar("PARTICULAR")), '') as particular,
        nullif(trim(to_varchar("SR_NO")), '') as sr_no
    from {{ source('health_raw', 'BJAZ_HAT_OCR_FINA_PERTICULARS') }}

)

select * from source
