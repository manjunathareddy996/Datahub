-- Staging model for source table BJAZ_HM_BILL_DETAIL_OCR (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("AVAILED_ROOM_CATEGORY"::varchar), '') as availed_room_category,
    "BILL_DATE"::timestamp_ntz as bill_date,
    "BILL_ID"::number as bill_id,
    nullif(trim("BILL_NO"::varchar), '') as bill_no,
    nullif(trim("BILL_STATUS"::varchar), '') as bill_status,
    "BILL_STATUS_TYPE"::number as bill_status_type,
    nullif(trim("BILL_TYPE"::varchar), '') as bill_type,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
    nullif(trim("COVER_TYPE"::varchar), '') as cover_type,
    "CRITI_UNIT_ROOM_RENT_PER_DAY"::number as criti_unit_room_rent_per_day,
    "DISCOUNT"::number as discount,
    nullif(trim("DIS_APP_REASON"::varchar), '') as dis_app_reason,
    nullif(trim("ELIGIBLE_ROOM_CATEGORY"::varchar), '') as eligible_room_category,
    "ELIGIBLE_ROOM_RENT"::number as eligible_room_rent,
    nullif(trim("HOS_BILL_NO"::varchar), '') as hos_bill_no,
    nullif(trim("IP_NO"::varchar), '') as ip_no,
    nullif(trim("OCR_BILL_NO"::varchar), '') as ocr_bill_no,
    "ROOM_RENT"::number as room_rent,
    "TOT_APPROVED_AMT"::number as tot_approved_amt,
    "TOT_APP_AMTMOU"::number as tot_app_amtmou,
    "TOT_BILL_AMT"::number as tot_bill_amt,
    "TOT_DISALLOW_AMT"::number as tot_disallow_amt
    from {{ source('health_raw', 'BJAZ_HM_BILL_DETAIL_OCR') }}

)

select * from source
