-- Staging model for source table BJAZ_HC_PART_EXTN (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "AGE"::number as age,
    "AMOUNT_CLAIMED"::number as amount_claimed,
    "BENEFIT_OPTED"::number as benefit_opted,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    "DATE_OF_BIRTH_M"::timestamp_ntz as date_of_birth_m,
    nullif(trim("DISEASE_DTLS"::varchar), '') as disease_dtls,
    nullif(trim("FIRST_POLICY_REF"::varchar), '') as first_policy_ref,
    nullif(trim("HOSPITAL_DETAIL"::varchar), '') as hospital_detail,
    "INCEPTION_DATE"::timestamp_ntz as inception_date,
    "LOAD_RATE"::number as load_rate,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim("NOMINEE_RLTN"::varchar), '') as nominee_rltn,
    nullif(trim("OCCUPATION"::varchar), '') as occupation,
    nullif(trim(to_varchar("PART_ID")), '') as part_id,
    "PREMIUM"::number as premium,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("SEX"::varchar), '') as sex,
    nullif(trim("STATUS"::varchar), '') as status,
    "SUM_INSURED"::number as sum_insured,
    "WAITING_PERIOD"::number as waiting_period
    from {{ source('health_raw', 'BJAZ_HC_PART_EXTN') }}

)

select * from source
