-- Staging for source table BJAZ_PMSBY_DATA_WEB_SERVICE (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AADHARNO")), '') as aadharno,
        nullif(trim(to_varchar("ACCOUNTHOLDERNAME")), '') as accountholdername,
        nullif(trim(to_varchar("ADDRESS_1")), '') as address_1,
        nullif(trim(to_varchar("ADDRESS_2")), '') as address_2,
        nullif(trim(to_varchar("APPOINTEENAME")), '') as appointeename,
        nullif(trim(to_varchar("BANKACCOUNTNO")), '') as bankaccountno,
        nullif(trim(to_varchar("BANKIFSC")), '') as bankifsc,
        nullif(trim(to_varchar("BANK_NAME")), '') as bank_name,
        nullif(trim(to_varchar("CARD_NUMBER")), '') as card_number,
        nullif(trim(to_varchar("CARD_STATUS")), '') as card_status,
        nullif(trim(to_varchar("CUST_ID")), '') as cust_id,
        nullif(trim(to_varchar("DATEOFSUBMISSION")), '') as dateofsubmission,
        nullif(trim(to_varchar("DATE_PAY_RECEIVED")), '') as date_pay_received,
        nullif(trim(to_varchar("DOA")), '') as doa,
        nullif(trim(to_varchar("DOB")), '') as dob,
        nullif(trim(to_varchar("DOJ")), '') as doj,
        nullif(trim(to_varchar("EMAILID")), '') as emailid,
        nullif(trim(to_varchar("ENTRY_DATE")), '') as entry_date,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("ISSUED_DATE")), '') as issued_date,
        nullif(trim(to_varchar("MOBILENO")), '') as mobileno,
        nullif(trim(to_varchar("NOMINEEAGE")), '') as nomineeage,
        nullif(trim(to_varchar("NOMINEEDOB")), '') as nomineedob,
        nullif(trim(to_varchar("NOMINEENAME")), '') as nomineename,
        nullif(trim(to_varchar("NOMINEERELATION")), '') as nomineerelation,
        nullif(trim(to_varchar("PANCARDNO")), '') as pancardno,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("PAY_STATUS")), '') as pay_status,
        nullif(trim(to_varchar("PINCODE")), '') as pincode,
        nullif(trim(to_varchar("POLICY_ISSUED_YN")), '') as policy_issued_yn,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("RNW_FLAG")), '') as rnw_flag,
        nullif(trim(to_varchar("USER_ID")), '') as user_id,
        nullif(trim(to_varchar("USER_TRANS_KEY_NO")), '') as user_trans_key_no
    from {{ source('health_raw', 'BJAZ_PMSBY_DATA_WEB_SERVICE') }}

)

select * from source
