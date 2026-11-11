-- Staging for source table BJAZ_CTNGY_SCHEME_PLANS (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ANY_ONE_CVR_MAND")), '') as any_one_cvr_mand,
        nullif(trim(to_varchar("APORT_BLOCKED")), '') as aport_blocked,
        nullif(trim(to_varchar("AUTO_EMAIL_YN")), '') as auto_email_yn,
        nullif(trim(to_varchar("AUTO_SMS_YN")), '') as auto_sms_yn,
        nullif(trim(to_varchar("BACKDATE_IMD_CODE")), '') as backdate_imd_code,
        nullif(trim(to_varchar("BLOCK_EMAIL_IMD")), '') as block_email_imd,
        nullif(trim(to_varchar("BLOCK_MULTIPLE_CVR_MAND")), '') as block_multiple_cvr_mand,
        nullif(trim(to_varchar("BLOCK_SMS_IMD")), '') as block_sms_imd,
        nullif(trim(to_varchar("DAYS_IN_ADVANCE")), '') as days_in_advance,
        nullif(trim(to_varchar("GENERIC_SMS_IMDS")), '') as generic_sms_imds,
        nullif(trim(to_varchar("IMD_BACKDATE_VALYN")), '') as imd_backdate_valyn,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("IMD_VALIDATE")), '') as imd_validate,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("ISACTIVE")), '') as isactive,
        nullif(trim(to_varchar("ISRENEW")), '') as isrenew,
        nullif(trim(to_varchar("LOADER_YN")), '') as loader_yn,
        nullif(trim(to_varchar("MEMBER_DOB_YN")), '') as member_dob_yn,
        nullif(trim(to_varchar("MEM_BACKDATE_LIMIT")), '') as mem_backdate_limit,
        nullif(trim(to_varchar("MEM_DATA_BULK_UPLOAD")), '') as mem_data_bulk_upload,
        nullif(trim(to_varchar("NB_BLOCKED_YN")), '') as nb_blocked_yn,
        nullif(trim(to_varchar("NEW_PLANNAME_YN")), '') as new_planname_yn,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("PDF_PLAN_DESC")), '') as pdf_plan_desc,
        nullif(trim(to_varchar("PIN_CODE_VAL_YN")), '') as pin_code_val_yn,
        nullif(trim(to_varchar("PLAN_DESC")), '') as plan_desc,
        nullif(trim(to_varchar("PLAN_ID")), '') as plan_id,
        nullif(trim(to_varchar("POLICY_SCHD_NAME")), '') as policy_schd_name,
        nullif(trim(to_varchar("POLICY_SCHD_YN")), '') as policy_schd_yn,
        nullif(trim(to_varchar("PREMIUM_LIMIT")), '') as premium_limit,
        nullif(trim(to_varchar("RNW_DAYS_IN_ADVANCE")), '') as rnw_days_in_advance,
        nullif(trim(to_varchar("SCHEME_CODE")), '') as scheme_code,
        nullif(trim(to_varchar("SCHEME_VERSION")), '') as scheme_version,
        nullif(trim(to_varchar("SELF_EXCLUDE")), '') as self_exclude,
        nullif(trim(to_varchar("SPECIFIC_SMS_IMDS")), '') as specific_sms_imds,
        nullif(trim(to_varchar("SUB_IMD_CODE")), '') as sub_imd_code,
        nullif(trim(to_varchar("SUB_IMD_VALIDATE")), '') as sub_imd_validate
    from {{ source('health_raw', 'BJAZ_CTNGY_SCHEME_PLANS') }}

)

select * from source
