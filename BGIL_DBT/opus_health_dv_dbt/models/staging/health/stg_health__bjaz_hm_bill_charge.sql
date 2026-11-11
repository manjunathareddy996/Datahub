-- Staging for source table BJAZ_HM_BILL_CHARGE (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("APPROVED_AMT")), '') as approved_amt,
        nullif(trim(to_varchar("BILL_AMT")), '') as bill_amt,
        nullif(trim(to_varchar("BILL_AMT_BREAKUP1")), '') as bill_amt_breakup1,
        nullif(trim(to_varchar("BILL_AMT_BREAKUP2")), '') as bill_amt_breakup2,
        nullif(trim(to_varchar("BILL_AMT_COPAY")), '') as bill_amt_copay,
        nullif(trim(to_varchar("BILL_CHARGE_ID")), '') as bill_charge_id,
        nullif(trim(to_varchar("BILL_DIS_AMT_COPAY")), '') as bill_dis_amt_copay,
        nullif(trim(to_varchar("BILL_ID")), '') as bill_id,
        nullif(trim(to_varchar("CHARGE_ID")), '') as charge_id,
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
        nullif(trim(to_varchar("DISALLOW_AMT")), '') as disallow_amt,
        nullif(trim(to_varchar("DISALLOW_REASON")), '') as disallow_reason,
        nullif(trim(to_varchar("ROOM_RENT_COPAY")), '') as room_rent_copay,
        nullif(trim(to_varchar("TARIFF_DED_TOTAL")), '') as tariff_ded_total,
        nullif(trim(to_varchar("TARIFF_EXCESS_DED")), '') as tariff_excess_ded
    from {{ source('health_raw', 'BJAZ_HM_BILL_CHARGE') }}

)

select * from source
