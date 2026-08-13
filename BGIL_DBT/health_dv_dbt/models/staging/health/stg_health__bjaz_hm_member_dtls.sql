-- Staging model for source table BJAZ_HM_MEMBER_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("ADDRESS"::varchar), '') as address,
    nullif(trim("ADD_ENDORSEMENT_NO"::varchar), '') as add_endorsement_no,
    "AGE"::number as age,
    nullif(trim(to_varchar("BANK_AC_NO")), '') as bank_ac_no,
    nullif(trim("BANK_NAME"::varchar), '') as bank_name,
    "BONUS_SI"::number as bonus_si,
    nullif(trim("CITY"::varchar), '') as city,
    "CLAIM_COUNT"::number as claim_count,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim("CO_EMPNUMBER"::varchar), '') as co_empnumber,
    "CTNY_MASTER_CONTRACT_ID"::number as ctny_master_contract_id,
    "CUMM_BONUS"::number as cumm_bonus,
    "CUMM_BONUS_PER"::number as cumm_bonus_per,
    nullif(trim("DEL_ENDORSEMENT_NO"::varchar), '') as del_endorsement_no,
    nullif(trim("DESIGNATION"::varchar), '') as designation,
    "DOB"::timestamp_ntz as dob,
    nullif(trim("EMAIL_ID"::varchar), '') as email_id,
    nullif(trim("EMPLOYEE_LOCATION"::varchar), '') as employee_location,
    "ENDORSEMENT_DATE"::timestamp_ntz as endorsement_date,
    nullif(trim("ENDORSEMENT_NO"::varchar), '') as endorsement_no,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("GRADE"::varchar), '') as grade,
    "GROSS_INCOME"::number as gross_income,
    nullif(trim("HAT_EMPCODE"::varchar), '') as hat_empcode,
    nullif(trim("ID_CARD_NO"::varchar), '') as id_card_no,
    "LOAD_RATE"::number as load_rate,
    "MEMBER_FLAG"::number as member_flag,
    nullif(trim(to_varchar("MEMBER_ID")), '') as member_id,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim("MEMBER_STATUS"::varchar), '') as member_status,
    nullif(trim("MICR_CODE"::varchar), '') as micr_code,
    nullif(trim("OCCUPATION"::varchar), '') as occupation,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PHONE_NO"::varchar), '') as phone_no,
    nullif(trim("PIN"::varchar), '') as pin,
    nullif(trim("PLAN_NAME"::varchar), '') as plan_name,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    "PREMIUM"::number as premium,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    nullif(trim("REFUND_PREMIUM"::varchar), '') as refund_premium,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("RISK_CLASS"::varchar), '') as risk_class,
    nullif(trim("STATE"::varchar), '') as state,
    "SUMINSURED"::number as suminsured,
    "TERM_END_DATE"::timestamp_ntz as term_end_date,
    "TERM_START_DATE"::timestamp_ntz as term_start_date,
    nullif(trim("VIP_FLG"::varchar), '') as vip_flg
    from {{ source('health_raw', 'BJAZ_HM_MEMBER_DTLS') }}

)

select * from source
