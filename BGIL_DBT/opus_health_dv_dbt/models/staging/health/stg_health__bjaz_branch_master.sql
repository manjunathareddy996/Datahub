-- Staging for source table BJAZ_BRANCH_MASTER (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ACCOUNT_CATEGORY_CODE")), '') as account_category_code,
        nullif(trim(to_varchar("ACT_INACT_STATUS")), '') as act_inact_status,
        nullif(trim(to_varchar("ADD_LINE1")), '') as add_line1,
        nullif(trim(to_varchar("ADD_LINE2")), '') as add_line2,
        nullif(trim(to_varchar("ADD_LINE3")), '') as add_line3,
        nullif(trim(to_varchar("ADD_LINE4")), '') as add_line4,
        nullif(trim(to_varchar("ADD_REMARKS")), '') as add_remarks,
        nullif(trim(to_varchar("BAGIC_GSTN")), '') as bagic_gstn,
        nullif(trim(to_varchar("BM_USERNAME")), '') as bm_username,
        nullif(trim(to_varchar("BRANCH_CODE")), '') as branch_code,
        nullif(trim(to_varchar("BRANCH_NAME")), '') as branch_name,
        nullif(trim(to_varchar("BRANCH_TYPE")), '') as branch_type,
        nullif(trim(to_varchar("CITY")), '') as city,
        nullif(trim(to_varchar("EMAIL")), '') as email,
        nullif(trim(to_varchar("FAX")), '') as fax,
        nullif(trim(to_varchar("ITC_EMAIL_ID")), '') as itc_email_id,
        nullif(trim(to_varchar("NEAREST_DM_BRANCH")), '') as nearest_dm_branch,
        nullif(trim(to_varchar("PARENT_BRANCH_CODE")), '') as parent_branch_code,
        nullif(trim(to_varchar("PINCODE")), '') as pincode,
        nullif(trim(to_varchar("PRINT_ZONE")), '') as print_zone,
        nullif(trim(to_varchar("REASON_FOR_ACT_DEACT")), '') as reason_for_act_deact,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("REGISTER_FLAG")), '') as register_flag,
        nullif(trim(to_varchar("REN_TELEPHONE1")), '') as ren_telephone1,
        nullif(trim(to_varchar("STATE")), '') as state,
        nullif(trim(to_varchar("STATE_CODE")), '') as state_code,
        nullif(trim(to_varchar("TELEPHONE1")), '') as telephone1,
        nullif(trim(to_varchar("TELEPHONE2")), '') as telephone2,
        nullif(trim(to_varchar("UT_FLAG")), '') as ut_flag
    from {{ source('health_raw', 'BJAZ_BRANCH_MASTER') }}

)

select * from source
