-- Staging for source view MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("INC_JOB_ID")), '') as inc_job_id,
        nullif(trim(to_varchar("FILE_NAME")), '') as file_name,
        nullif(trim(to_varchar("FILE_TIMESTAMP")), '') as file_timestamp,
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("ROOT_HASH")), '') as root_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("ADDITIONAL_PARTY_CODE")), '') as additional_party_code,
        nullif(trim(to_varchar("BASE_CURRENCY")), '') as base_currency,
        nullif(trim(to_varchar("MULTI_SET_PROPERTY_INPUT")), '') as multi_set_property_input,
        nullif(trim(to_varchar("PARTY_DETAILS")), '') as party_details,
        nullif(trim(to_varchar("PREM_CURRENCY")), '') as prem_currency,
        nullif(trim(to_varchar("RISK_COVER")), '') as risk_cover,
        nullif(trim(to_varchar("RISK_PROPERTY")), '') as risk_property,
        nullif(trim(to_varchar("ADDR1")), '') as addr1,
        nullif(trim(to_varchar("ADDR2")), '') as addr2,
        nullif(trim(to_varchar("ADDR3")), '') as addr3,
        nullif(trim(to_varchar("BILLING_STAKE")), '') as billing_stake,
        nullif(trim(to_varchar("CITY_CODE")), '') as city_code,
        nullif(trim(to_varchar("COUNTRY_CODE")), '') as country_code,
        nullif(trim(to_varchar("DISCOUNT")), '') as discount,
        nullif(trim(to_varchar("DOCUMENT_ID")), '') as document_id,
        nullif(trim(to_varchar("LOADING")), '') as loading,
        nullif(trim(to_varchar("PARTY_CODE")), '') as party_code,
        nullif(trim(to_varchar("POLICY_COUNTRY")), '') as policy_country,
        nullif(trim(to_varchar("POLICY_ID")), '') as policy_id,
        nullif(trim(to_varchar("POL_RISK_ID")), '') as pol_risk_id,
        nullif(trim(to_varchar("POSTAL_CODE")), '') as postal_code,
        nullif(trim(to_varchar("RISK_CODE")), '') as risk_code,
        nullif(trim(to_varchar("RISK_DESC")), '') as risk_desc,
        nullif(trim(to_varchar("RISK_EXPIRY_DATE")), '') as risk_expiry_date,
        nullif(trim(to_varchar("RISK_INCEPTION_DATE")), '') as risk_inception_date,
        nullif(trim(to_varchar("RISK_SERIAL_NUMBER")), '') as risk_serial_number,
        nullif(trim(to_varchar("RISK_SUM_INSURED")), '') as risk_sum_insured,
        nullif(trim(to_varchar("STATE_CODE")), '') as state_code,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("RISK_LIST")), '') as risk_list,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST') }}

)

select * from source
