-- Staging for source table BJAZ_MOTOR_WS_PREMIUM_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("TRANSACTIONID")), '') as transactionid,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("ENTRY_DATE")), '') as entry_date,
        nullif(trim(to_varchar("MODULE_FROM")), '') as module_from,
        nullif(trim(to_varchar("NCB_AMT")), '') as ncb_amt,
        nullif(trim(to_varchar("ADD_LOAD_PREM")), '') as add_load_prem,
        nullif(trim(to_varchar("TOTAL_OD_PREMIUM")), '') as total_od_premium,
        nullif(trim(to_varchar("TOTAL_ACT_PREMIUM")), '') as total_act_premium,
        nullif(trim(to_varchar("TOTAL_NET_PREMIUM")), '') as total_net_premium,
        nullif(trim(to_varchar("TOTAL_PREMIUM")), '') as total_premium,
        nullif(trim(to_varchar("NET_PREMIUM")), '') as net_premium,
        nullif(trim(to_varchar("FINAL_PREMIUM")), '') as final_premium,
        nullif(trim(to_varchar("SP_DISC")), '') as sp_disc,
        nullif(trim(to_varchar("SERVICE_TAX")), '') as service_tax,
        nullif(trim(to_varchar("STAMP_DUTY")), '') as stamp_duty,
        nullif(trim(to_varchar("COLL_PREMIUM")), '') as coll_premium,
        nullif(trim(to_varchar("IMT_OUT")), '') as imt_out,
        nullif(trim(to_varchar("TOTAL_IEV")), '') as total_iev,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOTOR_WS_PREMIUM_DTLS') }}

)

select * from source
