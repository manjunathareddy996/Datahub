-- Staging for source table BJAZ_HAT_OCR_FINA_DTLS_LST (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CASE_ID")), '') as case_id,
        nullif(trim(to_varchar("INWARD_NO")), '') as inward_no,
        nullif(trim(to_varchar("NAME")), '') as name,
        nullif(trim(to_varchar("TOTAL")), '') as total
    from {{ source('health_raw', 'BJAZ_HAT_OCR_FINA_DTLS_LST') }}

)

select * from source
