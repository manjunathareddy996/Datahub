-- Staging model for source table CP_PARTNERS (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    "FROM_DATE"::timestamp_ntz as from_date,
    nullif(trim("ADDRESSEE"::varchar), '') as addressee,
    nullif(trim("PROOF_OF_DEATH"::varchar), '') as proof_of_death,
    nullif(trim("DNI"::varchar), '') as dni,
    nullif(trim("SEX"::varchar), '') as sex,
    nullif(trim(to_varchar("ADD_ID")), '') as add_id,
    nullif(trim("LANGUAGE"::varchar), '') as language,
    nullif(trim("EVIDENCE"::varchar), '') as evidence,
    nullif(trim("MARITAL_STATUS"::varchar), '') as marital_status,
    "EVENT_DATE"::timestamp_ntz as event_date,
    nullif(trim("USERID"::varchar), '') as userid,
    nullif(trim("PARTNER_TYPE"::varchar), '') as partner_type,
    nullif(trim("SURNAME"::varchar), '') as surname,
    nullif(trim("LUA_VALUE_3"::varchar), '') as lua_value_3,
    nullif(trim("EXT_USER"::varchar), '') as ext_user,
    nullif(trim("TELEPHONE"::varchar), '') as telephone,
    nullif(trim("TELEPHONE2"::varchar), '') as telephone2,
    nullif(trim("EMAIL"::varchar), '') as email,
    nullif(trim("FAX"::varchar), '') as fax,
    nullif(trim("LUA_VALUE_1"::varchar), '') as lua_value_1,
    nullif(trim("LUA_VALUE_2"::varchar), '') as lua_value_2,
    nullif(trim("QUALITY"::varchar), '') as quality,
    nullif(trim("TAX_ID"::varchar), '') as tax_id,
    nullif(trim("MIDDLE_NAME"::varchar), '') as middle_name,
    nullif(trim("NATIONAL_ID"::varchar), '') as national_id,
    "DATE_OF_DEATH"::timestamp_ntz as date_of_death,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    nullif(trim("EMPLOYMENT_STATUS"::varchar), '') as employment_status,
    nullif(trim("NAME"::varchar), '') as name,
    "VERSION"::number as version,
    nullif(trim("AFTER_TITLE"::varchar), '') as after_title,
    nullif(trim("NATIONALITY"::varchar), '') as nationality,
    nullif(trim("NOTES"::varchar), '') as notes,
    nullif(trim("OCCUPATION"::varchar), '') as occupation,
    nullif(trim("EVID_TYPE"::varchar), '') as evid_type,
    nullif(trim("SHORT_NAME"::varchar), '') as short_name,
    nullif(trim("REG_NUMBER"::varchar), '') as reg_number,
    nullif(trim("LITERATURE"::varchar), '') as literature,
    nullif(trim("LEGAL_FORM"::varchar), '') as legal_form,
    nullif(trim("VAT_NUMBER"::varchar), '') as vat_number,
    nullif(trim("FIRST_NAME"::varchar), '') as first_name,
    nullif(trim("BEFORE_TITLE"::varchar), '') as before_title,
    nullif(trim("CONTACT1"::varchar), '') as contact1,
    nullif(trim("CONTACT2"::varchar), '') as contact2,
    "LAST_CHANGE_DATE"::timestamp_ntz as last_change_date,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    nullif(trim(to_varchar("PART_ID")), '') as part_id,
    nullif(trim("INSTITUTION_NAME"::varchar), '') as institution_name,
    nullif(trim("CAUSE_OF_DEATH"::varchar), '') as cause_of_death,
    nullif(trim("PARTNER_REF"::varchar), '') as partner_ref,
    nullif(trim("DATA_STATUS"::varchar), '') as data_status
    from {{ source('partner_raw', 'CP_PARTNERS') }}

)

select * from source
