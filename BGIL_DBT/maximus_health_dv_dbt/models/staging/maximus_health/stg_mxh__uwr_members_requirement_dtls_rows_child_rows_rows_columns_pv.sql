-- Staging for source view MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS_ROWS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("CHASERDATE")), '') as chaserdate,
        nullif(trim(to_varchar("CHASERDOCUMENT")), '') as chaserdocument,
        nullif(trim(to_varchar("CHASERSTATUS")), '') as chaserstatus,
        nullif(trim(to_varchar("CREATEDUPLOADEDBY")), '') as createduploadedby,
        nullif(trim(to_varchar("MANDATORYOPTIONAL")), '') as mandatoryoptional,
        nullif(trim(to_varchar("REQUIREDFROM")), '') as requiredfrom,
        nullif(trim(to_varchar("REQUIREMENTNAME")), '') as requirementname,
        nullif(trim(to_varchar("REQUIREMENTSTATUS")), '') as requirementstatus,
        nullif(trim(to_varchar("SEQUENCENO")), '') as sequenceno,
        nullif(trim(to_varchar("UPLOADEDREQUIREMENT")), '') as uploadedrequirement
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS_ROWS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW') }}

)

select * from source
