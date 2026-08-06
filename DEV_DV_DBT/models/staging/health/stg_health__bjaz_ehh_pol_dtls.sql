-- Staging model for source table BJAZ_EHH_POL_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("ADDRESS_LINE1"::varchar), '') as address_line1,
    nullif(trim("ADDRESS_LINE2"::varchar), '') as address_line2,
    nullif(trim("AREA"::varchar), '') as area,
    nullif(trim("CITY"::varchar), '') as city,
    nullif(trim(to_varchar("COMPANY_ORG_UNIT")), '') as company_org_unit,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim("DOB"::varchar), '') as dob,
    nullif(trim("EMAIL"::varchar), '') as email,
    nullif(trim("FIRST_NAME"::varchar), '') as first_name,
    nullif(trim("GENDER"::varchar), '') as gender,
    "GROSS_PREMIUM"::number as gross_premium,
    "GROSS_PREMIUM1"::number as gross_premium1,
    "GROSS_PREMIUM2"::number as gross_premium2,
    "GROSS_PREMIUM3"::number as gross_premium3,
    nullif(trim("GSTIN_NO"::varchar), '') as gstin_no,
    nullif(trim("LAST_NAME"::varchar), '') as last_name,
    nullif(trim(to_varchar("MAIN_AGENT_CODE")), '') as main_agent_code,
    nullif(trim("MIDDLE_NAME"::varchar), '') as middle_name,
    nullif(trim("MOBILE1"::varchar), '') as mobile1,
    nullif(trim("MOBILE2"::varchar), '') as mobile2,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PARTNER_TYPE"::varchar), '') as partner_type,
    nullif(trim("PAYMENT_MODE"::varchar), '') as payment_mode,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    "POL_PERIOD"::number as pol_period,
    nullif(trim("POSTCODE"::varchar), '') as postcode,
    nullif(trim(to_varchar("PRODUCT_4DIGIT_CODE")), '') as product_4digit_code,
    nullif(trim("RECEIPT_NO"::varchar), '') as receipt_no,
    "REFERENC_ID"::number as referenc_id,
    nullif(trim(to_varchar("RISK_LOCATION")), '') as risk_location,
    nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
    nullif(trim("STATE"::varchar), '') as state,
    nullif(trim("TERM_END_DATE"::varchar), '') as term_end_date,
    nullif(trim("TERM_START_DATE"::varchar), '') as term_start_date
    from {{ source('health_raw', 'BJAZ_EHH_POL_DTLS') }}

)

select * from source
