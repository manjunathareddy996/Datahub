-- Staging for source table BJAZ_ECARD_MEMBR_DEL_DTLS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("EMP_CODE")), '') as emp_code,
        nullif(trim(to_varchar("EMP_NEME")), '') as emp_neme,
        nullif(trim(to_varchar("NATRL_REASON")), '') as natrl_reason,
        nullif(trim(to_varchar("QUOTE_REF")), '') as quote_ref,
        nullif(trim(to_varchar("RELATION")), '') as relation
    from {{ source('health_raw', 'BJAZ_ECARD_MEMBR_DEL_DTLS') }}

)

select * from source
