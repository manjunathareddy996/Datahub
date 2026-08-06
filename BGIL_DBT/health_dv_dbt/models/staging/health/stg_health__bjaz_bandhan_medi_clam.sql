-- Staging model for source table BJAZ_BANDHAN_MEDI_CLAM (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("AADHAAR_NUMBER"::varchar), '') as aadhaar_number,
    nullif(trim("ACCOUNT_NUMBER"::varchar), '') as account_number,
    "AGE"::number as age,
    nullif(trim("BUSINESS_TYPE"::varchar), '') as business_type,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim(to_varchar("CUSTOMER_ID")), '') as customer_id,
    nullif(trim("CUSTOMER_NAME"::varchar), '') as customer_name,
    "DOB"::timestamp_ntz as dob,
    nullif(trim("FIRST_NAME"::varchar), '') as first_name,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("GROSS_PREMINUM"::varchar), '') as gross_preminum,
    nullif(trim("GST_REG_NO"::varchar), '') as gst_reg_no,
    nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
    nullif(trim("ISSUANCE_SOURCE"::varchar), '') as issuance_source,
    nullif(trim("LAST_NAME"::varchar), '') as last_name,
    nullif(trim(to_varchar("LG_CODE")), '') as lg_code,
    nullif(trim("LG_NAME"::varchar), '') as lg_name,
    nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
    nullif(trim("MIDDLE_NAME"::varchar), '') as middle_name,
    nullif(trim("MOBILE"::varchar), '') as mobile,
    nullif(trim("M_ADDRESS_LINE_1"::varchar), '') as m_address_line_1,
    nullif(trim("M_ADDRESS_LINE_2"::varchar), '') as m_address_line_2,
    nullif(trim("M_CITY"::varchar), '') as m_city,
    nullif(trim("M_EMAIL"::varchar), '') as m_email,
    nullif(trim("M_MOBILE"::varchar), '') as m_mobile,
    nullif(trim("M_PINCODE"::varchar), '') as m_pincode,
    nullif(trim("M_STATE"::varchar), '') as m_state,
    nullif(trim("NOMINEE_RELATION"::varchar), '') as nominee_relation,
    "NO_OF_YEARS"::number as no_of_years,
    "NUMBER_OF_DAYS"::number as number_of_days,
    nullif(trim("PAN_NO"::varchar), '') as pan_no,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PARTNER_TYPE"::varchar), '') as partner_type,
    nullif(trim(to_varchar("PLAN_ID")), '') as plan_id,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim("PREEXISTING_DISEASE"::varchar), '') as preexisting_disease,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    nullif(trim("P_ADDRESS_LINE_1"::varchar), '') as p_address_line_1,
    nullif(trim("P_ADDRESS_LINE_2"::varchar), '') as p_address_line_2,
    nullif(trim("P_CITY"::varchar), '') as p_city,
    nullif(trim("P_EMAIL"::varchar), '') as p_email,
    nullif(trim("P_PINCODE"::varchar), '') as p_pincode,
    nullif(trim("P_STATE"::varchar), '') as p_state,
    nullif(trim("RECEIPT_NO"::varchar), '') as receipt_no,
    nullif(trim(to_varchar("REFERENCE_ID")), '') as reference_id,
    nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
    nullif(trim(to_varchar("SUBIMD_CODE")), '') as subimd_code,
    "TERM_END_DATE"::timestamp_ntz as term_end_date,
    "TERM_START_DATE"::timestamp_ntz as term_start_date,
    nullif(trim("UW_REMARK"::varchar), '') as uw_remark
    from {{ source('health_raw', 'BJAZ_BANDHAN_MEDI_CLAM') }}

)

select * from source
