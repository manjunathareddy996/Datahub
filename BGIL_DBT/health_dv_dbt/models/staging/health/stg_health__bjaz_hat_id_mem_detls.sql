-- Staging model for source table BJAZ_HAT_ID_MEM_DETLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("ADDLINE1"::varchar), '') as addline1,
    nullif(trim("ADDLINE2"::varchar), '') as addline2,
    "AGE"::number as age,
    nullif(trim("CITY"::varchar), '') as city,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    nullif(trim("DESIGNATION"::varchar), '') as designation,
    nullif(trim("DIABETES"::varchar), '') as diabetes,
    nullif(trim("DISEASE_TO_BE_EXCLUDED"::varchar), '') as disease_to_be_excluded,
    nullif(trim("EMAIL_ID"::varchar), '') as email_id,
    nullif(trim("EMP_NAME"::varchar), '') as emp_name,
    nullif(trim("EMP_NO"::varchar), '') as emp_no,
    nullif(trim("FAMILY_HIST"::varchar), '') as family_hist,
    nullif(trim("FIRST_NAME"::varchar), '') as first_name,
    nullif(trim("HYPERTENTION"::varchar), '') as hypertention,
    nullif(trim("ID_CARD_NO"::varchar), '') as id_card_no,
    nullif(trim("IHD"::varchar), '') as ihd,
    "JOIN_DATE"::timestamp_ntz as join_date,
    nullif(trim("LAST_NAME"::varchar), '') as last_name,
    "MARRIAGE_DATE"::timestamp_ntz as marriage_date,
    nullif(trim(to_varchar("MEMBER_NO")), '') as member_no,
    nullif(trim("MIDDLE_NAME"::varchar), '') as middle_name,
    nullif(trim("OTHER_DISEASES"::varchar), '') as other_diseases,
    nullif(trim(to_varchar("PART_ID")), '') as part_id,
    "PIN"::number as pin,
    "PREMIUM"::number as premium,
    nullif(trim("PREV_POLICY_DETAILS"::varchar), '') as prev_policy_details,
    "PREV_POL_CLM_AMT"::number as prev_pol_clm_amt,
    nullif(trim("PROFESSION"::varchar), '') as profession,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("RENAL_PROBLEM"::varchar), '') as renal_problem,
    nullif(trim("SEX"::varchar), '') as sex,
    nullif(trim("STATE"::varchar), '') as state,
    nullif(trim("STATUS"::varchar), '') as status,
    "SUM_INSURED"::number as sum_insured,
    nullif(trim("TEL"::varchar), '') as tel
    from {{ source('health_raw', 'BJAZ_HAT_ID_MEM_DETLS') }}

)

select * from source
