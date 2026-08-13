-- Staging model for source table BJAZ_ECARD_MEMBR_DEL_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("EMP_CODE")), '') as emp_code,
    nullif(trim("EMP_NEME"::varchar), '') as emp_neme,
    nullif(trim("NATRL_REASON"::varchar), '') as natrl_reason,
    nullif(trim(to_varchar("QUOTE_REF")), '') as quote_ref,
    nullif(trim("RELATION"::varchar), '') as relation
    from {{ source('health_raw', 'BJAZ_ECARD_MEMBR_DEL_DTLS') }}

)

select * from source
