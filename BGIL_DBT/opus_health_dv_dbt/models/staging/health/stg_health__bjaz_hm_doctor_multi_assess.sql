-- Staging for source table BJAZ_HM_DOCTOR_MULTI_ASSESS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
        nullif(trim(to_varchar("COVER_SECTION")), '') as cover_section,
        nullif(trim(to_varchar("DIAGNOSIS_DETAIL")), '') as diagnosis_detail,
        nullif(trim(to_varchar("DIAGNOSIS_ID")), '') as diagnosis_id,
        nullif(trim(to_varchar("DOCASESS_ID")), '') as docasess_id,
        nullif(trim(to_varchar("HLTH_TIPS")), '') as hlth_tips,
        nullif(trim(to_varchar("ICD_ID")), '') as icd_id,
        nullif(trim(to_varchar("ICD_SNO")), '') as icd_sno,
        nullif(trim(to_varchar("MEDICAL_MGMT_DATE")), '') as medical_mgmt_date,
        nullif(trim(to_varchar("MEDICAL_MGMT_TYPE")), '') as medical_mgmt_type,
        nullif(trim(to_varchar("PACKAGE_CHARGE")), '') as package_charge,
        nullif(trim(to_varchar("PACKAGE_FLAG")), '') as package_flag,
        nullif(trim(to_varchar("PCS_YN")), '') as pcs_yn
    from {{ source('health_raw', 'BJAZ_HM_DOCTOR_MULTI_ASSESS') }}

)

select * from source
