-- Staging for source table BJAZ_BFHL_DTLS (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ANOMALY_DESCRIPTION")), '') as anomaly_description,
        nullif(trim(to_varchar("ANOMALY_SUB_TYPE")), '') as anomaly_sub_type,
        nullif(trim(to_varchar("ANOMALY_SUPPORTING_DOC")), '') as anomaly_supporting_doc,
        nullif(trim(to_varchar("ANOMALY_TIMESTAMP")), '') as anomaly_timestamp,
        nullif(trim(to_varchar("ANOMALY_TYPE")), '') as anomaly_type,
        nullif(trim(to_varchar("BY_PASS_REMARKS")), '') as by_pass_remarks,
        nullif(trim(to_varchar("BY_PASS_REMARKS_BY")), '') as by_pass_remarks_by,
        nullif(trim(to_varchar("BY_PASS_REMARKS_UPDATED_ON")), '') as by_pass_remarks_updated_on,
        nullif(trim(to_varchar("CLAIM_NO")), '') as claim_no,
        nullif(trim(to_varchar("DOC_CLASS")), '') as doc_class,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("IS_ANOMALY_FOUND")), '') as is_anomaly_found
    from {{ source('health_raw', 'BJAZ_BFHL_DTLS') }}

)

select * from source
