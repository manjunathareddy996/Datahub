-- Staging for source view MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("CHASER_DATE")), '') as chaser_date,
        nullif(trim(to_varchar("CHASER_DOCUMENT")), '') as chaser_document,
        nullif(trim(to_varchar("CHASER_STATUS")), '') as chaser_status,
        nullif(trim(to_varchar("DOCUMENT_TITLE")), '') as document_title,
        nullif(trim(to_varchar("MEDICALTECHNICAL")), '') as medicaltechnical,
        nullif(trim(to_varchar("MODIFIED_BY")), '') as modified_by,
        nullif(trim(to_varchar("MODIFIED_DATE")), '') as modified_date,
        nullif(trim(to_varchar("RAISED_BY")), '') as raised_by,
        nullif(trim(to_varchar("RAISED_DATE")), '') as raised_date,
        nullif(trim(to_varchar("REMARKS")), '') as remarks,
        nullif(trim(to_varchar("REQUIREMENT_DETAILS")), '') as requirement_details,
        nullif(trim(to_varchar("REQUIREMENT_STATUS")), '') as requirement_status,
        nullif(trim(to_varchar("SEQUENCE_NO")), '') as sequence_no,
        nullif(trim(to_varchar("UPLOADED_DOCUMENTS")), '') as uploaded_documents
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW') }}

)

select * from source
