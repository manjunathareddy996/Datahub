-- Staging for source view MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS_ROWS_COLUMNS_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("CREATEDBY")), '') as createdby,
        nullif(trim(to_varchar("CREATEDON")), '') as createdon,
        nullif(trim(to_varchar("DOCUMENTBELONGSTO")), '') as documentbelongsto,
        nullif(trim(to_varchar("DOCUMENTNAME")), '') as documentname,
        nullif(trim(to_varchar("DOCUMENTTYPE")), '') as documenttype,
        nullif(trim(to_varchar("REQUIREDFROM")), '') as requiredfrom,
        nullif(trim(to_varchar("REQUIREDFROM1")), '') as requiredfrom1
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS_ROWS_COLUMNS_PIVOT_VW') }}

)

select * from source
