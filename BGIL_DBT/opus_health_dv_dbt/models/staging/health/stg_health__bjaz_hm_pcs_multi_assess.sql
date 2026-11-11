-- Staging for source table BJAZ_HM_PCS_MULTI_ASSESS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
        nullif(trim(to_varchar("DOCASESS_ID")), '') as docasess_id,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("MEDICAL_MGMT_DATE")), '') as medical_mgmt_date,
        nullif(trim(to_varchar("MEDICAL_MGMT_TYPE")), '') as medical_mgmt_type,
        nullif(trim(to_varchar("PCS_ID")), '') as pcs_id,
        nullif(trim(to_varchar("PCS_SNO")), '') as pcs_sno
    from {{ source('health_raw', 'BJAZ_HM_PCS_MULTI_ASSESS') }}

)

select * from source
