-- Staging model for source table BJAZ_SH_MEM_DTLS_EXTN (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("ADDRESS"::varchar), '') as address,
    "AGE"::number as age,
    "AMOUNT_CLAIMED"::number as amount_claimed,
    nullif(trim("ASTHMA_YN"::varchar), '') as asthma_yn,
    nullif(trim("CLAIM_HISTORY"::varchar), '') as claim_history,
    nullif(trim("COMPANY_NAME"::varchar), '') as company_name,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "CUMM_BONUS"::number as cumm_bonus,
    "CUMM_BONUS_PER"::number as cumm_bonus_per,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    nullif(trim("DIABETES_YN"::varchar), '') as diabetes_yn,
    nullif(trim("DISEASE_DTLS"::varchar), '') as disease_dtls,
    "EFFETIVE_DATE"::timestamp_ntz as effetive_date,
    nullif(trim("EMAIL_ID"::varchar), '') as email_id,
    "EXPIRY_DATE"::timestamp_ntz as expiry_date,
    nullif(trim("GENDER"::varchar), '') as gender,
    "GROSS_INCOME"::number as gross_income,
    nullif(trim("HYPERTENSION_YN"::varchar), '') as hypertension_yn,
    "INCEPTION_DATE"::timestamp_ntz as inception_date,
    "LOAD_AMT"::number as load_amt,
    "LOAD_RATE"::number as load_rate,
    nullif(trim("MEDICAL_CHECKUP"::varchar), '') as medical_checkup,
    nullif(trim(to_varchar("MEDICAL_REPORT")), '') as medical_report,
    nullif(trim(to_varchar("MEMBER_NO")), '') as member_no,
    nullif(trim("NAME"::varchar), '') as name,
    nullif(trim("NOMINEE_RLTN"::varchar), '') as nominee_rltn,
    nullif(trim("OCCUPATION"::varchar), '') as occupation,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PERIOD_OF_INSURANCE"::varchar), '') as period_of_insurance,
    nullif(trim("PERIOD_TREATMENT"::varchar), '') as period_treatment,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    "PREMIUM"::number as premium,
    nullif(trim("PREV_POLICY_DTLS"::varchar), '') as prev_policy_dtls,
    "PREV_SUM_INSURED"::number as prev_sum_insured,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("SMOKER_YN"::varchar), '') as smoker_yn,
    "SUM_INSURED"::number as sum_insured,
    "WAITING_PERIOD"::number as waiting_period
    from {{ source('health_raw', 'BJAZ_SH_MEM_DTLS_EXTN') }}

)

select * from source
