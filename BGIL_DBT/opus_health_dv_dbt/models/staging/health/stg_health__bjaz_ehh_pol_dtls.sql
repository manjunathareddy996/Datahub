-- Staging for source table BJAZ_EHH_POL_DTLS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ADDRESS_LINE1")), '') as address_line1,
        nullif(trim(to_varchar("ADDRESS_LINE2")), '') as address_line2,
        nullif(trim(to_varchar("AREA")), '') as area,
        nullif(trim(to_varchar("CITY")), '') as city,
        nullif(trim(to_varchar("COMPANY_ORG_UNIT")), '') as company_org_unit,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("DOB")), '') as dob,
        nullif(trim(to_varchar("EMAIL")), '') as email,
        nullif(trim(to_varchar("FIRST_NAME")), '') as first_name,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        nullif(trim(to_varchar("GROSS_PREMIUM")), '') as gross_premium,
        nullif(trim(to_varchar("GROSS_PREMIUM1")), '') as gross_premium1,
        nullif(trim(to_varchar("GROSS_PREMIUM2")), '') as gross_premium2,
        nullif(trim(to_varchar("GROSS_PREMIUM3")), '') as gross_premium3,
        nullif(trim(to_varchar("GSTIN_NO")), '') as gstin_no,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("LAST_NAME")), '') as last_name,
        nullif(trim(to_varchar("MAIN_AGENT_CODE")), '') as main_agent_code,
        nullif(trim(to_varchar("MIDDLE_NAME")), '') as middle_name,
        nullif(trim(to_varchar("MOBILE1")), '') as mobile1,
        nullif(trim(to_varchar("MOBILE2")), '') as mobile2,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("PARTNER_TYPE")), '') as partner_type,
        nullif(trim(to_varchar("PAYMENT_MODE")), '') as payment_mode,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("POL_PERIOD")), '') as pol_period,
        nullif(trim(to_varchar("POSTCODE")), '') as postcode,
        nullif(trim(to_varchar("PRODUCT_4DIGIT_CODE")), '') as product_4digit_code,
        nullif(trim(to_varchar("RECEIPT_NO")), '') as receipt_no,
        nullif(trim(to_varchar("REFERENC_ID")), '') as referenc_id,
        nullif(trim(to_varchar("RISK_LOCATION")), '') as risk_location,
        nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
        nullif(trim(to_varchar("STATE")), '') as state,
        nullif(trim(to_varchar("TERM_END_DATE")), '') as term_end_date,
        nullif(trim(to_varchar("TERM_START_DATE")), '') as term_start_date
    from {{ source('health_raw', 'BJAZ_EHH_POL_DTLS') }}

)

select * from source
