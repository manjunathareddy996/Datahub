-- Staging for source table BJAZ_WAP_MOT_ADDONPKG. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("TRANS_ID")), '') as trans_id,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("INSERT_DATE")), '') as insert_date,
        nullif(trim(to_varchar("PACKAGE_ID")), '') as package_id,
        nullif(trim(to_varchar("PACKAGE_NAME")), '') as package_name,
        nullif(trim(to_varchar("PACKAGE_SELECT_YN")), '') as package_select_yn,
        nullif(trim(to_varchar("COVER_CODE")), '') as cover_code,
        nullif(trim(to_varchar("COVER_DESC")), '') as cover_desc,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("USER_NAME")), '') as user_name,
        nullif(trim(to_varchar("DISCOUNT_RATE")), '') as discount_rate,
        nullif(trim(to_varchar("LOADING_RATE")), '') as loading_rate,
        nullif(trim(to_varchar("ENABLE_DISC_YN")), '') as enable_disc_yn,
        nullif(trim(to_varchar("MOTORWS_TRANS_ID")), '') as motorws_trans_id,
        nullif(trim(to_varchar("ENTRY_FLAG")), '') as entry_flag,
        nullif(trim(to_varchar("PACKAGE_TYPE")), '') as package_type,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_WAP_MOT_ADDONPKG') }}

)

select * from source
