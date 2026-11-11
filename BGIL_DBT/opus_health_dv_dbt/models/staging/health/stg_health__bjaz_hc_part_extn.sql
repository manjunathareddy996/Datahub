-- Staging for source table BJAZ_HC_PART_EXTN (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("AMOUNT_CLAIMED")), '') as amount_claimed,
        nullif(trim(to_varchar("ASSIGNEE_NAME")), '') as assignee_name,
        nullif(trim(to_varchar("BENEFIT_OPTED")), '') as benefit_opted,
        nullif(trim(to_varchar("CLAIM_HISTORY")), '') as claim_history,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("DATE_OF_BIRTH")), '') as date_of_birth,
        nullif(trim(to_varchar("DATE_OF_BIRTH_M")), '') as date_of_birth_m,
        nullif(trim(to_varchar("DISEASE_DTLS")), '') as disease_dtls,
        nullif(trim(to_varchar("FIRST_POLICY_REF")), '') as first_policy_ref,
        nullif(trim(to_varchar("HOSPITAL")), '') as hospital,
        nullif(trim(to_varchar("HOSPITAL_DETAIL")), '') as hospital_detail,
        nullif(trim(to_varchar("INCEPTION_DATE")), '') as inception_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("LOAD_AMT")), '') as load_amt,
        nullif(trim(to_varchar("LOAD_RATE")), '') as load_rate,
        nullif(trim(to_varchar("MEMBER_NAME")), '') as member_name,
        nullif(trim(to_varchar("NOMINEE_RLTN")), '') as nominee_rltn,
        nullif(trim(to_varchar("NO_OF_DAYS")), '') as no_of_days,
        nullif(trim(to_varchar("OCCUPATION")), '') as occupation,
        nullif(trim(to_varchar("PART_ID")), '') as part_id,
        nullif(trim(to_varchar("PREMIUM")), '') as premium,
        nullif(trim(to_varchar("PRESCRIPTION")), '') as prescription,
        nullif(trim(to_varchar("PRESCRIPTION_DETAIL")), '') as prescription_detail,
        nullif(trim(to_varchar("RATE_STATUS")), '') as rate_status,
        nullif(trim(to_varchar("RELATION")), '') as relation,
        nullif(trim(to_varchar("SEX")), '') as sex,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured,
        nullif(trim(to_varchar("WAITING_PERIOD")), '') as waiting_period
    from {{ source('health_raw', 'BJAZ_HC_PART_EXTN') }}

)

select * from source
