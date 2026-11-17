-- Staging for source table BGIL_MOTWS_OTHER_DTLS_EQM. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("PTRANSACTION_ID")), '') as ptransaction_id,
        nullif(trim(to_varchar("REG_NO")), '') as reg_no,
        nullif(trim(to_varchar("OWNER_SR_FACTOR")), '') as owner_sr_factor,
        nullif(trim(to_varchar("CHDH_FACTOR")), '') as chdh_factor,
        nullif(trim(to_varchar("AGE_FACTOR")), '') as age_factor,
        nullif(trim(to_varchar("PRODUCT_CODE_FACTOR")), '') as product_code_factor,
        nullif(trim(to_varchar("IDV_FACTOR")), '') as idv_factor,
        nullif(trim(to_varchar("NF_FLAG")), '') as nf_flag,
        nullif(trim(to_varchar("S3_FLG")), '') as s3_flg,
        nullif(trim(to_varchar("IIB_REF_NO")), '') as iib_ref_no,
        nullif(trim(to_varchar("ENTRY_DATE")), '') as entry_date,
        nullif(trim(to_varchar("APPLICABLITY")), '') as applicablity,
        nullif(trim(to_varchar("TOPUP_NCB_DISC")), '') as topup_ncb_disc,
        nullif(trim(to_varchar("RS_FLAG")), '') as rs_flag,
        nullif(trim(to_varchar("RS_DISC")), '') as rs_disc,
        nullif(trim(to_varchar("CHDH_DISC")), '') as chdh_disc,
        nullif(trim(to_varchar("MVND_DISC")), '') as mvnd_disc,
        nullif(trim(to_varchar("CHDH_MVND_DISC")), '') as chdh_mvnd_disc,
        nullif(trim(to_varchar("TOTAL_CHDHMVN_OD_PREM")), '') as total_chdhmvn_od_prem,
        nullif(trim(to_varchar("TOTAL_RSOD_PREM")), '') as total_rsod_prem,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BGIL_MOTWS_OTHER_DTLS_EQM') }}

)

select * from source
