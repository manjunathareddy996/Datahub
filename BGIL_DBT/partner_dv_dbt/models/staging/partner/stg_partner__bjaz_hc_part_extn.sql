-- Staging model for source table BJAZ_HC_PART_EXTN (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim("ACTION_CODE"::varchar), '') as action_code,
    "VERSION_NO"::number as version_no,
    "OBJECT_ID"::number as object_id,
    nullif(trim("TOP_INDICATOR"::varchar), '') as top_indicator,
    "PREVIOUS_VERSION"::number as previous_version,
    "REVERSING_VERSION"::number as reversing_version,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "PARTITION_NO"::number as partition_no,
    "AGE"::number as age,
    nullif(trim("SEX"::varchar), '') as sex,
    nullif(trim("RELATION"::varchar), '') as relation,
    "NO_OF_DAYS"::number as no_of_days,
    "BENEFIT_OPTED"::number as benefit_opted,
    nullif(trim("HOSPITAL"::varchar), '') as hospital,
    nullif(trim("PRESCRIPTION"::varchar), '') as prescription,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim("ASSIGNEE_NAME"::varchar), '') as assignee_name,
    "SUM_INSURED"::number as sum_insured,
    nullif(trim("DISEASE_DTLS"::varchar), '') as disease_dtls,
    nullif(trim("RATE_STATUS"::varchar), '') as rate_status,
    "WAITING_PERIOD"::number as waiting_period,
    "AMOUNT_CLAIMED"::number as amount_claimed,
    nullif(trim("CLAIM_HISTORY"::varchar), '') as claim_history,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    nullif(trim("OCCUPATION"::varchar), '') as occupation,
    nullif(trim(to_varchar("PART_ID")), '') as part_id,
    "LOAD_RATE"::number as load_rate,
    "LOAD_AMT"::number as load_amt,
    "PREMIUM"::number as premium,
    nullif(trim("STATUS"::varchar), '') as status,
    "DATE_OF_BIRTH_M"::timestamp_ntz as date_of_birth_m,
    nullif(trim("HOSPITAL_DETAIL"::varchar), '') as hospital_detail,
    nullif(trim("PRESCRIPTION_DETAIL"::varchar), '') as prescription_detail,
    nullif(trim("FIRST_POLICY_REF"::varchar), '') as first_policy_ref,
    "INCEPTION_DATE"::timestamp_ntz as inception_date,
    nullif(trim("NOMINEE_RLTN"::varchar), '') as nominee_rltn,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_raw', 'BJAZ_HC_PART_EXTN') }}

)

select * from source
