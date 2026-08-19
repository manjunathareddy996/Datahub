-- Staging model for source table BJAZ_SH_MEM_DTLS_EXTN (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim("ACTION_CODE"::varchar), '') as action_code,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "LOAD_RATE"::number as load_rate,
    "LOAD_AMT"::number as load_amt,
    "EFFETIVE_DATE"::timestamp_ntz as effetive_date,
    "EXPIRY_DATE"::timestamp_ntz as expiry_date,
    "CUMM_BONUS_PER"::number as cumm_bonus_per,
    "CUMM_BONUS"::number as cumm_bonus,
    "PREV_SUM_INSURED"::number as prev_sum_insured,
    nullif(trim("CLAIM_HISTORY"::varchar), '') as claim_history,
    nullif(trim("COMPANY_NAME"::varchar), '') as company_name,
    "AMOUNT_CLAIMED"::number as amount_claimed,
    nullif(trim("POLICY_COLLECTED"::varchar), '') as policy_collected,
    "WAITING_PERIOD"::number as waiting_period,
    nullif(trim("SMOKER_YN"::varchar), '') as smoker_yn,
    nullif(trim("POLICY_REF"::varchar), '') as policy_ref,
    "MEMBER_NO"::number as member_no,
    nullif(trim("NAME"::varchar), '') as name,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    "AGE"::number as age,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("RELATION"::varchar), '') as relation,
    "GROSS_INCOME"::number as gross_income,
    nullif(trim("OCCUPATION"::varchar), '') as occupation,
    "SUM_INSURED"::number as sum_insured,
    "PREMIUM"::number as premium,
    nullif(trim("DISEASE_DTLS"::varchar), '') as disease_dtls,
    nullif(trim("PREV_POLICY_DTLS"::varchar), '') as prev_policy_dtls,
    nullif(trim("ASSIGNEE"::varchar), '') as assignee,
    nullif(trim("STATUS"::varchar), '') as status,
    nullif(trim("DIABETES_YN"::varchar), '') as diabetes_yn,
    nullif(trim("HYPERTENSION_YN"::varchar), '') as hypertension_yn,
    nullif(trim("ASTHMA_YN"::varchar), '') as asthma_yn,
    nullif(trim("MEDICAL_CHECKUP"::varchar), '') as medical_checkup,
    nullif(trim("MEDICAL_REPORT"::varchar), '') as medical_report,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    "OBJECT_ID"::number as object_id,
    "PREVIOUS_VERSION"::number as previous_version,
    "REVERSING_VERSION"::number as reversing_version,
    nullif(trim("TOP_INDICATOR"::varchar), '') as top_indicator,
    "VERSION_NO"::number as version_no,
    nullif(trim("ADDRESS"::varchar), '') as address,
    nullif(trim("EMAIL_ID"::varchar), '') as email_id,
    nullif(trim("PERIOD_OF_INSURANCE"::varchar), '') as period_of_insurance,
    nullif(trim("PERIOD_TREATMENT"::varchar), '') as period_treatment,
    nullif(trim("DOCTOR_NAME"::varchar), '') as doctor_name,
    nullif(trim("COMMENTS"::varchar), '') as comments,
    nullif(trim("FIRST_POLICY_REF"::varchar), '') as first_policy_ref,
    "INCEPTION_DATE"::timestamp_ntz as inception_date,
    nullif(trim("NOMINEE_RLTN"::varchar), '') as nominee_rltn,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_raw', 'BJAZ_SH_MEM_DTLS_EXTN') }}

)

select * from source
