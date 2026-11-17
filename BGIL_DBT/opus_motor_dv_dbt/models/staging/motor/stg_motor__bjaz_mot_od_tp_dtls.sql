-- Staging for source table BJAZ_MOT_OD_TP_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("POLICY_ISSUE_DATE")), '') as policy_issue_date,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("MOVE_CODE")), '') as move_code,
        nullif(trim(to_varchar("NET_PREMIUM")), '') as net_premium,
        nullif(trim(to_varchar("GROSS_PREMIUM")), '') as gross_premium,
        nullif(trim(to_varchar("TOTAL_OD_PREM")), '') as total_od_prem,
        nullif(trim(to_varchar("TOTAL_TP_PREM")), '') as total_tp_prem,
        nullif(trim(to_varchar("VEHICLE_TYPE_CODE")), '') as vehicle_type_code,
        nullif(trim(to_varchar("TP_ACC_PASS_YN")), '') as tp_acc_pass_yn,
        nullif(trim(to_varchar("TP_ACC_BATCH_ID")), '') as tp_acc_batch_id,
        nullif(trim(to_varchar("TP_ACC_DATE")), '') as tp_acc_date,
        nullif(trim(to_varchar("MOT_POOL_YN")), '') as mot_pool_yn,
        nullif(trim(to_varchar("MOT_POOL_TP_PREM")), '') as mot_pool_tp_prem,
        nullif(trim(to_varchar("MOT_POOL_UPL_REF")), '') as mot_pool_upl_ref,
        nullif(trim(to_varchar("COMM_OD_PREM")), '') as comm_od_prem,
        nullif(trim(to_varchar("BRANCH_CODE")), '') as branch_code,
        nullif(trim(to_varchar("UW_YEAR")), '') as uw_year,
        nullif(trim(to_varchar("ORG_CHANNEL_CODE")), '') as org_channel_code,
        nullif(trim(to_varchar("FIN_CHANNEL_CODE")), '') as fin_channel_code,
        nullif(trim(to_varchar("ADJ_OD_PREM")), '') as adj_od_prem,
        nullif(trim(to_varchar("ADJ_TP_PREM")), '') as adj_tp_prem,
        nullif(trim(to_varchar("ADJ_OD_RMKS")), '') as adj_od_rmks,
        nullif(trim(to_varchar("ADJ_TP_RMKS")), '') as adj_tp_rmks,
        nullif(trim(to_varchar("TERR_SURCHARGE")), '') as terr_surcharge,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_OD_TP_DTLS') }}

)

select * from source
