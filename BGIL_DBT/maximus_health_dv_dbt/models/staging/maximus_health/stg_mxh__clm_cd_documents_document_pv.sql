-- Staging for source view MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_DOCUMENTS_DOCUMENT_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("ADHOC_DOC_TYPE")), '') as adhoc_doc_type,
        nullif(trim(to_varchar("CREATED_ON")), '') as created_on,
        nullif(trim(to_varchar("DOCUMENT_BELONGS_TO")), '') as document_belongs_to,
        nullif(trim(to_varchar("DOCUMENT_ID")), '') as document_id,
        nullif(trim(to_varchar("DOCUMENT_NAME")), '') as document_name,
        nullif(trim(to_varchar("DOCUMENT_SIZE")), '') as document_size,
        nullif(trim(to_varchar("DOCUMENT_TYPE")), '') as document_type,
        nullif(trim(to_varchar("UPLOAD_STATUS")), '') as upload_status
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_DOCUMENTS_DOCUMENT_PIVOT_VW') }}

)

select * from source
