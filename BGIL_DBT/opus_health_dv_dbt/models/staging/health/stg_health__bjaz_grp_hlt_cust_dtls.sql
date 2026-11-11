-- Staging for source table BJAZ_GRP_HLT_CUST_DTLS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ADDRESS_LINE_1")), '') as address_line_1,
        nullif(trim(to_varchar("ADDRESS_LINE_2")), '') as address_line_2,
        nullif(trim(to_varchar("BENEFICIARY")), '') as beneficiary,
        nullif(trim(to_varchar("CITY")), '') as city,
        nullif(trim(to_varchar("CONTACT_PERSON")), '') as contact_person,
        nullif(trim(to_varchar("E_MAIL_ID")), '') as e_mail_id,
        nullif(trim(to_varchar("FIRST_NAME")), '') as first_name,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("INSTITITION")), '') as institition,
        nullif(trim(to_varchar("LAST_NAME")), '') as last_name,
        nullif(trim(to_varchar("MIDDLE_NAME")), '') as middle_name,
        nullif(trim(to_varchar("MOBILE")), '') as mobile,
        nullif(trim(to_varchar("NAME_OF_CORPORATE")), '') as name_of_corporate,
        nullif(trim(to_varchar("PARTNER_TYPE")), '') as partner_type,
        nullif(trim(to_varchar("PHONE_NUMBER")), '') as phone_number,
        nullif(trim(to_varchar("PIN_CODE")), '') as pin_code,
        nullif(trim(to_varchar("PRODUCT")), '') as product,
        nullif(trim(to_varchar("QUOTE_NO")), '') as quote_no,
        nullif(trim(to_varchar("QUOTE_SUB_NO")), '') as quote_sub_no,
        nullif(trim(to_varchar("REG_NO")), '') as reg_no,
        nullif(trim(to_varchar("STATE")), '') as state,
        nullif(trim(to_varchar("TOTAL")), '') as total
    from {{ source('health_raw', 'BJAZ_GRP_HLT_CUST_DTLS') }}

)

select * from source
