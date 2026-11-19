-- Staging for source table BJAZ_MOT_PKG_MST. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("PACKAGE_ID")), '') as package_id,
        nullif(trim(to_varchar("PACKAGE_NAME")), '') as package_name,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("EFFECTIVE_DATE")), '') as effective_date,
        nullif(trim(to_varchar("EXPIRY_DATE")), '') as expiry_date,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("MAX_VEH_AGE")), '') as max_veh_age,
        nullif(trim(to_varchar("ENTRY_DATE")), '') as entry_date,
        nullif(trim(to_varchar("USER_NAME")), '') as user_name,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("MULTI_YR_YN")), '') as multi_yr_yn,
        nullif(trim(to_varchar("PACKAGE_TYPE")), '') as package_type,
        nullif(trim(to_varchar("P_NB_YN")), '') as p_nb_yn,
        nullif(trim(to_varchar("P_OTRNW_YN")), '') as p_otrnw_yn,
        nullif(trim(to_varchar("P_RNW_YN")), '') as p_rnw_yn,
        nullif(trim(to_varchar("NCB_DISC_YN")), '') as ncb_disc_yn,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOT_PKG_MST') }}

)

select * from source
