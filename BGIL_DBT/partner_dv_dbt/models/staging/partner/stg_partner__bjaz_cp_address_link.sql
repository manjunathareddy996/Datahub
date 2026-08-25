-- Staging model for source table BJAZ_CP_ADDRESS_LINK (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim("PART_ID"::varchar), '') as part_id,
    "ADD_TYPE"::number as add_type,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    nullif(trim("REMARKS"::varchar), '') as remarks,
    nullif(trim("PRIMARY_YN"::varchar), '') as primary_yn,
    nullif(trim("ADD_ID"::varchar), '') as add_id,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_raw', 'BJAZ_CP_ADDRESS_LINK') }}

)

select * from source
