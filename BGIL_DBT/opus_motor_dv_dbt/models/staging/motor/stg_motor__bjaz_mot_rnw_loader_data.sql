-- Staging for source table BJAZ_MOT_RNW_LOADER_DATA. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("SERIALNO")), '') as serialno,
        nullif(trim(to_varchar("PREV_POLICYNO")), '') as prev_policyno,
        nullif(trim(to_varchar("NCB")), '') as ncb,
        nullif(trim(to_varchar("REG_NO")), '') as reg_no,
        nullif(trim(to_varchar("PACKAGE_ID")), '') as package_id,
        nullif(trim(to_varchar("RID")), '') as rid,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("SUB_IMD")), '') as sub_imd,
        nullif(trim(to_varchar("TOTAL_PREMIUM")), '') as total_premium,
        nullif(trim(to_varchar("ERROR_MESSAGE")), '') as error_message,
        nullif(trim(to_varchar("USERID")), '') as userid,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("RECORDDATE")), '') as recorddate,
        nullif(trim(to_varchar("CD_PER")), '') as cd_per,
        nullif(trim(to_varchar("CD_AMOUNT")), '') as cd_amount,
        nullif(trim(to_varchar("PREM_DTLS")), '') as prem_dtls,
        nullif(trim(to_varchar("VEH_IDV")), '') as veh_idv,
        nullif(trim(to_varchar("OD_PREM")), '') as od_prem,
        nullif(trim(to_varchar("TP_PREM")), '') as tp_prem,
        nullif(trim(to_varchar("SMS_URL")), '') as sms_url,
        nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
        nullif(trim(to_varchar("IIB_END_DATE")), '') as iib_end_date,
        nullif(trim(to_varchar("ADDON_PREM")), '') as addon_prem,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        nullif(trim(to_varchar("GST_AMT")), '') as gst_amt,
        nullif(trim(to_varchar("NET_PREM")), '') as net_prem,
        nullif(trim(to_varchar("NCB_CLAIM")), '') as ncb_claim,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_RNW_LOADER_DATA') }}

)

select * from source
