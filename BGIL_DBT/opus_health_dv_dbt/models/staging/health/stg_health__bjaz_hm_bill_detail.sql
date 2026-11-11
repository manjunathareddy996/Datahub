-- Staging for source table BJAZ_HM_BILL_DETAIL (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AMT_FRM_PATIENT")), '') as amt_frm_patient,
        nullif(trim(to_varchar("AVAILED_ROOM_CATEGORY")), '') as availed_room_category,
        nullif(trim(to_varchar("AVAILED_ROOM_RENT_PER_DAY")), '') as availed_room_rent_per_day,
        nullif(trim(to_varchar("BILL_DATE")), '') as bill_date,
        nullif(trim(to_varchar("BILL_ID")), '') as bill_id,
        nullif(trim(to_varchar("BILL_NO")), '') as bill_no,
        nullif(trim(to_varchar("BILL_STATUS")), '') as bill_status,
        nullif(trim(to_varchar("BILL_STATUS_TYPE")), '') as bill_status_type,
        nullif(trim(to_varchar("BILL_TYPE")), '') as bill_type,
        nullif(trim(to_varchar("CLAIMED_AMT")), '') as claimed_amt,
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
        nullif(trim(to_varchar("COVER_TYPE")), '') as cover_type,
        nullif(trim(to_varchar("CRITI_UNIT_ROOM_RENT_PER_DAY")), '') as criti_unit_room_rent_per_day,
        nullif(trim(to_varchar("DISCOUNT")), '') as discount,
        nullif(trim(to_varchar("DIS_APP_REASON")), '') as dis_app_reason,
        nullif(trim(to_varchar("ELIGIBLE_ROOM_CATEGORY")), '') as eligible_room_category,
        nullif(trim(to_varchar("ELIGIBLE_ROOM_RENT")), '') as eligible_room_rent,
        nullif(trim(to_varchar("GENRAL_REMARKS")), '') as genral_remarks,
        nullif(trim(to_varchar("GRADE")), '') as grade,
        nullif(trim(to_varchar("HOS_BILL_NO")), '') as hos_bill_no,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("IP_NO")), '') as ip_no,
        nullif(trim(to_varchar("OCR_BILL_NO")), '') as ocr_bill_no,
        nullif(trim(to_varchar("REF_BILL_ID")), '') as ref_bill_id,
        nullif(trim(to_varchar("ROOM_RENT")), '') as room_rent,
        nullif(trim(to_varchar("ROOM_RENT_PERC")), '') as room_rent_perc,
        nullif(trim(to_varchar("TOT_APPROVED_AMT")), '') as tot_approved_amt,
        nullif(trim(to_varchar("TOT_APP_AMTMOU")), '') as tot_app_amtmou,
        nullif(trim(to_varchar("TOT_BILL_AMT")), '') as tot_bill_amt,
        nullif(trim(to_varchar("TOT_COPAY_AMT")), '') as tot_copay_amt,
        nullif(trim(to_varchar("TOT_DISALLOW_AMT")), '') as tot_disallow_amt
    from {{ source('health_raw', 'BJAZ_HM_BILL_DETAIL') }}

)

select * from source
