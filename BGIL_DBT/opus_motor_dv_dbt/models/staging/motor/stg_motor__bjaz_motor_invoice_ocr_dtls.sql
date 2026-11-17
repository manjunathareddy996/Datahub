-- Staging for source table BJAZ_MOTOR_INVOICE_OCR_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("REQUEST_ID")), '') as request_id,
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("INVOICE_YN")), '') as invoice_yn,
        nullif(trim(to_varchar("CLAIM_STAGE")), '') as claim_stage,
        nullif(trim(to_varchar("FLAG")), '') as flag,
        nullif(trim(to_varchar("SEND_OCR_DATE")), '') as send_ocr_date,
        nullif(trim(to_varchar("APPROVED_OCR_DATE")), '') as approved_ocr_date,
        nullif(trim(to_varchar("RECEIVED_DOC_DATE")), '') as received_doc_date,
        nullif(trim(to_varchar("ACCEPT_OCR_DATE")), '') as accept_ocr_date,
        nullif(trim(to_varchar("SOURCE_FLAG")), '') as source_flag,
        nullif(trim(to_varchar("DOCUMENT_TYPE")), '') as document_type,
        nullif(trim(to_varchar("INDEX_ID")), '') as index_id,
        nullif(trim(to_varchar("RESONSE_TIME")), '') as resonse_time,
        nullif(trim(to_varchar("VAR1")), '') as var1,
        nullif(trim(to_varchar("VAR2")), '') as var2,
        nullif(trim(to_varchar("VAR3")), '') as var3,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOTOR_INVOICE_OCR_DTLS') }}

)

select * from source
