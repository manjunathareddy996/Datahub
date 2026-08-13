-- Staging model for source table BJAZ_HM_HOSPITAL_MASTER (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("ADDRESS1"::varchar), '') as address1,
    nullif(trim("ADDRESS2"::varchar), '') as address2,
    nullif(trim("CITY_NAME"::varchar), '') as city_name,
    "DIAGNO_YN"::number as diagno_yn,
    "EFFECTIVE_DATE"::timestamp_ntz as effective_date,
    nullif(trim("EMAIL"::varchar), '') as email,
    "EMPANEL_DATE"::timestamp_ntz as empanel_date,
    "EXPIRY_DATE"::timestamp_ntz as expiry_date,
    nullif(trim("FAX_NO"::varchar), '') as fax_no,
    nullif(trim(to_varchar("HOSID")), '') as hosid,
    nullif(trim("HOSPITAL_NAME"::varchar), '') as hospital_name,
    nullif(trim("HOSP_SPECIALITY"::varchar), '') as hosp_speciality,
    nullif(trim("HOSP_SPEC_TYPE"::varchar), '') as hosp_spec_type,
    nullif(trim("HOSP_TYPE"::varchar), '') as hosp_type,
    "HOS_STATUS"::number as hos_status,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PHONE_NO"::varchar), '') as phone_no,
    nullif(trim(to_varchar("PIN_CODE")), '') as pin_code,
    "PREFERRED_FLAG"::number as preferred_flag,
    nullif(trim("STATE_NAME"::varchar), '') as state_name,
    nullif(trim("STAX_REG_NO"::varchar), '') as stax_reg_no,
    nullif(trim("STD_CODE"::varchar), '') as std_code
    from {{ source('health_raw', 'BJAZ_HM_HOSPITAL_MASTER') }}

)

select * from source
