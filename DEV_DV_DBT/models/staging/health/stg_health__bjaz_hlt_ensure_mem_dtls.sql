-- Staging model for source table BJAZ_HLT_ENSURE_MEM_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "AGE"::number as age,
    nullif(trim("AGE_PROOF_YN"::varchar), '') as age_proof_yn,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim(to_varchar("MEMBER_NO")), '') as member_no,
    nullif(trim("NAME"::varchar), '') as name,
    nullif(trim("NOMINEE_RLTN"::varchar), '') as nominee_rltn,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PREVIOUS_COMPANY_NAME"::varchar), '') as previous_company_name,
    nullif(trim("PREVIOUS_CUM_BONUS"::varchar), '') as previous_cum_bonus,
    nullif(trim("PREVIOUS_POLICY_NO"::varchar), '') as previous_policy_no,
    nullif(trim("PREVIOUS_SINCE_NOOF_YEARS"::varchar), '') as previous_since_noof_years,
    nullif(trim("PREVIOUS_SUM_INSURED"::varchar), '') as previous_sum_insured,
    nullif(trim("PREV_POLICY_NO"::varchar), '') as prev_policy_no,
    nullif(trim("PRE_DISEASE"::varchar), '') as pre_disease,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("SPECIAL_CONDITION"::varchar), '') as special_condition,
    "SUM_INSURED"::number as sum_insured
    from {{ source('health_raw', 'BJAZ_HLT_ENSURE_MEM_DTLS') }}

)

select * from source
