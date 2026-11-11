-- Staging for source table NG_FAX_INWARD_DETAILS (run opus_health_delta3). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ALLOCATE_FLAG")), '') as allocate_flag,
        nullif(trim(to_varchar("ALLOCATE_ON")), '') as allocate_on,
        nullif(trim(to_varchar("ALLOCATE_TO")), '') as allocate_to,
        nullif(trim(to_varchar("CREATEDDATE")), '') as createddate,
        nullif(trim(to_varchar("DOCINDEX")), '') as docindex,
        nullif(trim(to_varchar("FAXCREATEDDATE")), '') as faxcreateddate,
        nullif(trim(to_varchar("FAX_NO")), '') as fax_no,
        nullif(trim(to_varchar("IMAGENAME")), '') as imagename,
        nullif(trim(to_varchar("INWARDNO")), '') as inwardno
    from {{ source('health_raw', 'NG_FAX_INWARD_DETAILS') }}

)

select * from source
