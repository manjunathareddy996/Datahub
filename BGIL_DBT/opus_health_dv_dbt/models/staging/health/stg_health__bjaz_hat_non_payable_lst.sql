-- Staging for source table BJAZ_HAT_NON_PAYABLE_LST (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("BILLHEAD")), '') as billhead,
        nullif(trim(to_varchar("NON_PAY_AMT_PERUNIT")), '') as non_pay_amt_perunit,
        nullif(trim(to_varchar("NON_PAY_CASE_ID")), '') as non_pay_case_id,
        nullif(trim(to_varchar("NON_PAY_CLAIMED_AMOUNT")), '') as non_pay_claimed_amount,
        nullif(trim(to_varchar("NON_PAY_IS_PAYABLE")), '') as non_pay_is_payable,
        nullif(trim(to_varchar("NON_PAY_LEVEL_1")), '') as non_pay_level_1,
        nullif(trim(to_varchar("NON_PAY_LEVEL_2")), '') as non_pay_level_2,
        nullif(trim(to_varchar("NON_PAY_LEVEL_3")), '') as non_pay_level_3,
        nullif(trim(to_varchar("NON_PAY_PARTICULAR")), '') as non_pay_particular,
        nullif(trim(to_varchar("NON_PAY_UNIT")), '') as non_pay_unit
    from {{ source('health_raw', 'BJAZ_HAT_NON_PAYABLE_LST') }}

)

select * from source
