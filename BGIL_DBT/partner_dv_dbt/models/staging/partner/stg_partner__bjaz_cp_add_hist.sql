-- Staging model for source table BJAZ_CP_ADD_HIST (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    "UPD_DT"::timestamp_ntz as upd_dt,
    nullif(trim("USER_NAME"::varchar), '') as user_name,
    nullif(trim("MACHINE"::varchar), '') as machine,
    nullif(trim("PROGRAM"::varchar), '') as program,
    nullif(trim("WEB_USER_ID"::varchar), '') as web_user_id,
    nullif(trim("ACTION"::varchar), '') as action,
    nullif(trim("MODULE"::varchar), '') as module,
    nullif(trim("COUNTRY_CODE"::varchar), '') as country_code,
    nullif(trim("ADDRESS_LINE2"::varchar), '') as address_line2,
    nullif(trim("ADDRESS_LINE3"::varchar), '') as address_line3,
    nullif(trim("ADDRESS_LINE4"::varchar), '') as address_line4,
    nullif(trim("ADDRESS_LINE1"::varchar), '') as address_line1,
    "FROM_DATE"::timestamp_ntz as from_date,
    nullif(trim("POSTCODE"::varchar), '') as postcode,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    nullif(trim("ADDRESS_LINE5"::varchar), '') as address_line5,
    nullif(trim("TELEPHONE"::varchar), '') as telephone,
    nullif(trim("EXT_USER"::varchar), '') as ext_user,
    nullif(trim(to_varchar("ADD_ID")), '') as add_id,
    "VERSION"::number as version,
    "EVENT_DATE"::timestamp_ntz as event_date,
    nullif(trim("USERID"::varchar), '') as userid
    from {{ source('partner_raw', 'BJAZ_CP_ADD_HIST') }}

)

select * from source
