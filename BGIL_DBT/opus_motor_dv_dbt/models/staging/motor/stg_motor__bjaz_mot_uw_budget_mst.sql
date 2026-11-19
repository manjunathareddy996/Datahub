-- Staging for source table BJAZ_MOT_UW_BUDGET_MST. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("BUDGET_ID")), '') as budget_id,
        nullif(trim(to_varchar("GROUP_CODE")), '') as group_code,
        nullif(trim(to_varchar("RNW_TYPE")), '') as rnw_type,
        nullif(trim(to_varchar("BUDGET_PERCENTAGE")), '') as budget_percentage,
        nullif(trim(to_varchar("BRANCH_LIMIT")), '') as branch_limit,
        nullif(trim(to_varchar("ZH_LIMIT")), '') as zh_limit,
        nullif(trim(to_varchar("TOTAL_OD_PREM")), '') as total_od_prem,
        nullif(trim(to_varchar("TOTAL_AMNT")), '') as total_amnt,
        nullif(trim(to_varchar("TOTAL_AMNT_BO")), '') as total_amnt_bo,
        nullif(trim(to_varchar("TOTAL_AMNT_ZH")), '') as total_amnt_zh,
        nullif(trim(to_varchar("FOR_MONTH")), '') as for_month,
        nullif(trim(to_varchar("FOR_YEAR")), '') as for_year,
        nullif(trim(to_varchar("ENTRY_DATE")), '') as entry_date,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("UTILIZED_AMNT_BO")), '') as utilized_amnt_bo,
        nullif(trim(to_varchar("UTILIZED_AMNT_ZH")), '') as utilized_amnt_zh,
        nullif(trim(to_varchar("CF_BRANCH")), '') as cf_branch,
        nullif(trim(to_varchar("CF_ZH")), '') as cf_zh,
        nullif(trim(to_varchar("BORROW_BRANCH")), '') as borrow_branch,
        nullif(trim(to_varchar("BORROW_ZH")), '') as borrow_zh,
        nullif(trim(to_varchar("INTERMEDIARY_ID")), '') as intermediary_id,
        nullif(trim(to_varchar("BUDGET_TYPE")), '') as budget_type,
        nullif(trim(to_varchar("USER_NAME")), '') as user_name,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOT_UW_BUDGET_MST') }}

)

select * from source
