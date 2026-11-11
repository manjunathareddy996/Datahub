-- Staging for source view MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("2D_ECO")), '') as c_2d_eco,
        nullif(trim(to_varchar("ANY_OTHER_ADDITIONAL_TEST")), '') as any_other_additional_test,
        nullif(trim(to_varchar("AUDITOR_DECISION")), '') as auditor_decision,
        nullif(trim(to_varchar("BMI_DECISION")), '') as bmi_decision,
        nullif(trim(to_varchar("CTMT_DECISION")), '') as ctmt_decision,
        nullif(trim(to_varchar("DECLARE_HEALTH_HISTORY")), '') as declare_health_history,
        nullif(trim(to_varchar("ECG_DECISION")), '') as ecg_decision,
        nullif(trim(to_varchar("FULL_MEDICAL_REPORT")), '') as full_medical_report,
        nullif(trim(to_varchar("GENERAL_REMARKS")), '') as general_remarks,
        nullif(trim(to_varchar("LABORATORY_REPORT")), '') as laboratory_report,
        nullif(trim(to_varchar("LOADING_REASON")), '') as loading_reason,
        nullif(trim(to_varchar("POSITIVEHEALTHDECLARATION")), '') as positivehealthdeclaration,
        nullif(trim(to_varchar("SI_ENHANCEMENT_REJECTED")), '') as si_enhancement_rejected,
        nullif(trim(to_varchar("SYSTEM_DECISION")), '') as system_decision,
        nullif(trim(to_varchar("TERMSOFACCEPTANCEANDREJECTION")), '') as termsofacceptanceandrejection,
        nullif(trim(to_varchar("TYPE_OF_UNDERWRITING_LOADING")), '') as type_of_underwriting_loading,
        nullif(trim(to_varchar("UNDERWRITING_LOADING_PERCENTAGE")), '') as underwriting_loading_percentage,
        nullif(trim(to_varchar("USG")), '') as usg,
        nullif(trim(to_varchar("XRAY")), '') as xray
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW') }}

)

select * from source
