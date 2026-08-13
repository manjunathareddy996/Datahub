-- Staging model for source table BJAZ_GRP_HLT_CUST_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("ADDRESS_LINE_1"::varchar), '') as address_line_1,
    nullif(trim("ADDRESS_LINE_2"::varchar), '') as address_line_2,
    nullif(trim("CITY"::varchar), '') as city,
    nullif(trim("E_MAIL_ID"::varchar), '') as e_mail_id,
    "MOBILE"::number as mobile,
    nullif(trim("NAME_OF_CORPORATE"::varchar), '') as name_of_corporate,
    nullif(trim("PARTNER_TYPE"::varchar), '') as partner_type,
    nullif(trim("PHONE_NUMBER"::varchar), '') as phone_number,
    nullif(trim("PIN_CODE"::varchar), '') as pin_code,
    nullif(trim(to_varchar("PRODUCT")), '') as product,
    nullif(trim(to_varchar("QUOTE_NO")), '') as quote_no,
    nullif(trim(to_varchar("QUOTE_SUB_NO")), '') as quote_sub_no,
    nullif(trim(to_varchar("REG_NO")), '') as reg_no,
    nullif(trim("STATE"::varchar), '') as state
    from {{ source('health_raw', 'BJAZ_GRP_HLT_CUST_DTLS') }}

)

select * from source
