-- Staging for source table BJAZ_HLT_ENSURE_MEM_DTLS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("AGE_PROOF_YN")), '') as age_proof_yn,
        nullif(trim(to_varchar("ASSIGNEE")), '') as assignee,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("DATE_OF_BIRTH")), '') as date_of_birth,
        nullif(trim(to_varchar("FIRST_POLICY_NUMBER")), '') as first_policy_number,
        nullif(trim(to_varchar("FIRST_POL_INCEPTION_DATE")), '') as first_pol_inception_date,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("MEMBER_NO")), '') as member_no,
        nullif(trim(to_varchar("NAME")), '') as name,
        nullif(trim(to_varchar("NOMINEE_RLTN")), '') as nominee_rltn,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("PREVIOUS_COMPANY_NAME")), '') as previous_company_name,
        nullif(trim(to_varchar("PREVIOUS_CUM_AMOUNT")), '') as previous_cum_amount,
        nullif(trim(to_varchar("PREVIOUS_CUM_BONUS")), '') as previous_cum_bonus,
        nullif(trim(to_varchar("PREVIOUS_FROM_DATE")), '') as previous_from_date,
        nullif(trim(to_varchar("PREVIOUS_POLICY_NO")), '') as previous_policy_no,
        nullif(trim(to_varchar("PREVIOUS_SINCE_NOOF_YEARS")), '') as previous_since_noof_years,
        nullif(trim(to_varchar("PREVIOUS_SUM_INSURED")), '') as previous_sum_insured,
        nullif(trim(to_varchar("PREVIOUS_TO_DATE")), '') as previous_to_date,
        nullif(trim(to_varchar("PREV_POLICY_NO")), '') as prev_policy_no,
        nullif(trim(to_varchar("PRE_DISEASE")), '') as pre_disease,
        nullif(trim(to_varchar("RELATION")), '') as relation,
        nullif(trim(to_varchar("SPECIAL_CONDITION")), '') as special_condition,
        nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured
    from {{ source('health_raw', 'BJAZ_HLT_ENSURE_MEM_DTLS') }}

)

select * from source
