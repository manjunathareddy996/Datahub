-- Staging model for source table BJAZ_HLT_ENSURE_MEM_DTLS (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim("PREVIOUS_SINCE_NOOF_YEARS"::varchar), '') as previous_since_noof_years,
    nullif(trim("ACTION_CODE"::varchar), '') as action_code,
    "VERSION_NO"::number as version_no,
    "OBJECT_ID"::number as object_id,
    nullif(trim("TOP_INDICATOR"::varchar), '') as top_indicator,
    "PREVIOUS_VERSION"::number as previous_version,
    "REVERSING_VERSION"::number as reversing_version,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "MEMBER_NO"::number as member_no,
    nullif(trim("NAME"::varchar), '') as name,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    "AGE"::number as age,
    "SUM_INSURED"::number as sum_insured,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("ASSIGNEE"::varchar), '') as assignee,
    nullif(trim("PRE_DISEASE"::varchar), '') as pre_disease,
    nullif(trim("SPECIAL_CONDITION"::varchar), '') as special_condition,
    nullif(trim("AGE_PROOF_YN"::varchar), '') as age_proof_yn,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("DELETE_MEM"::varchar), '') as delete_mem,
    nullif(trim("PREV_POLICY_NO"::varchar), '') as prev_policy_no,
    nullif(trim("PREVIOUS_COMPANY_NAME"::varchar), '') as previous_company_name,
    nullif(trim("PREVIOUS_POLICY_NO"::varchar), '') as previous_policy_no,
    nullif(trim("PREVIOUS_SUM_INSURED"::varchar), '') as previous_sum_insured,
    nullif(trim("PREVIOUS_FROM_DATE"::varchar), '') as previous_from_date,
    nullif(trim("PREVIOUS_TO_DATE"::varchar), '') as previous_to_date,
    nullif(trim("PREVIOUS_CUM_BONUS"::varchar), '') as previous_cum_bonus,
    nullif(trim("PREVIOUS_CUM_AMOUNT"::varchar), '') as previous_cum_amount,
    nullif(trim("FIRST_POLICY_NUMBER"::varchar), '') as first_policy_number,
    nullif(trim("FIRST_POL_INCEPTION_DATE"::varchar), '') as first_pol_inception_date,
    nullif(trim("NOMINEE_RLTN"::varchar), '') as nominee_rltn
    from {{ source('partner_raw', 'BJAZ_HLT_ENSURE_MEM_DTLS') }}

)

select * from source
