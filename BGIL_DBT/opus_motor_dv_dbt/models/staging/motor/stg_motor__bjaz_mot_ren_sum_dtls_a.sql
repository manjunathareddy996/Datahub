-- Staging for source table BJAZ_MOT_REN_SUM_DTLS_A. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("OD_DESC")), '') as od_desc,
        nullif(trim(to_varchar("OD_SUMINSURED")), '') as od_suminsured,
        nullif(trim(to_varchar("OD_PREMIUM")), '') as od_premium,
        nullif(trim(to_varchar("ACT_DESC")), '') as act_desc,
        nullif(trim(to_varchar("ACT_SUMINSURED")), '') as act_suminsured,
        nullif(trim(to_varchar("ACT_PREMIUM")), '') as act_premium,
        nullif(trim(to_varchar("PARAM_NO")), '') as param_no,
        nullif(trim(to_varchar("OD_TAG")), '') as od_tag,
        nullif(trim(to_varchar("TP_TAG")), '') as tp_tag,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOT_REN_SUM_DTLS_A') }}

)

select * from source
