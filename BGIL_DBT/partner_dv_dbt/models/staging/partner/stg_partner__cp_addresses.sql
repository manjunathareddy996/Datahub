-- Staging model for source table CP_ADDRESSES (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim(to_varchar("ADD_ID")), '') as add_id,
    "VERSION"::number as version,
    "EVENT_DATE"::timestamp_ntz as event_date,
    nullif(trim("USERID"::varchar), '') as userid,
    nullif(trim("ADDRESS_LINE1"::varchar), '') as address_line1,
    "FROM_DATE"::timestamp_ntz as from_date,
    nullif(trim("POSTCODE"::varchar), '') as postcode,
    nullif(trim("COUNTRY_CODE"::varchar), '') as country_code,
    nullif(trim("ADDRESS_LINE2"::varchar), '') as address_line2,
    nullif(trim("ADDRESS_LINE3"::varchar), '') as address_line3,
    nullif(trim("ADDRESS_LINE4"::varchar), '') as address_line4,
    nullif(trim("ADDRESS_LINE5"::varchar), '') as address_line5,
    nullif(trim("TELEPHONE"::varchar), '') as telephone,
    nullif(trim("EXT_USER"::varchar), '') as ext_user,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_raw', 'CP_ADDRESSES') }}

)

select * from source
