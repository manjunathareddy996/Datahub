-- Staging model for source table BA_HCP_PP_MEM_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("AGE"::varchar), '') as age,
    nullif(trim(to_varchar("ALLOTED_TO")), '') as alloted_to,
    nullif(trim("APPOINTMENT_CODE"::varchar), '') as appointment_code,
    nullif(trim("APP_DATE"::varchar), '') as app_date,
    "CHECKUP_AMT"::number as checkup_amt,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim("DATE_OF_BIRTH"::varchar), '') as date_of_birth,
    nullif(trim("DC_ADDRESS"::varchar), '') as dc_address,
    nullif(trim("DC_CITY"::varchar), '') as dc_city,
    nullif(trim("DC_LOCATION"::varchar), '') as dc_location,
    "DC_PINCODE"::number as dc_pincode,
    nullif(trim("DC_STATE"::varchar), '') as dc_state,
    nullif(trim("DC_TELENO"::varchar), '') as dc_teleno,
    nullif(trim(to_varchar("HI_CONTROL_NUMBER")), '') as hi_control_number,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim(to_varchar("MEM_SEQNO")), '') as mem_seqno,
    nullif(trim("PRIORITY_FLAG"::varchar), '') as priority_flag,
    nullif(trim("REMARKS"::varchar), '') as remarks,
    nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
    "STATUS_CODE"::number as status_code,
    nullif(trim("STATUS_DESC"::varchar), '') as status_desc,
    nullif(trim("TEST_CODE"::varchar), '') as test_code,
    nullif(trim("TYPE_OF_CHECKUP"::varchar), '') as type_of_checkup
    from {{ source('health_raw', 'BA_HCP_PP_MEM_DTLS') }}

)

select * from source
