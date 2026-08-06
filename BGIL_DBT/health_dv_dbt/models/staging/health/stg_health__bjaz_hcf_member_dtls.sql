-- Staging model for source table BJAZ_HCF_MEMBER_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "ADON_PREMIUM"::number as adon_premium,
    "AGE"::number as age,
    nullif(trim("ANCILIARY"::varchar), '') as anciliary,
    nullif(trim("ASSIGNEE_RELATION"::varchar), '') as assignee_relation,
    nullif(trim("ASTHMA_FLAG"::varchar), '') as asthma_flag,
    nullif(trim("BMI_FLAG"::varchar), '') as bmi_flag,
    "BMI_LOAD"::number as bmi_load,
    nullif(trim("CLAIM_DTLS"::varchar), '') as claim_dtls,
    nullif(trim("COMPANY_NAME"::varchar), '') as company_name,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim("CRITICAL_ILLNESS"::varchar), '') as critical_illness,
    "CUMULATIVE_AMT"::number as cumulative_amt,
    "CUMULATIVE_BNOUZ_PER"::number as cumulative_bnouz_per,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    nullif(trim("DIABETES_FLAG"::varchar), '') as diabetes_flag,
    "DIABETES_LOAD"::number as diabetes_load,
    nullif(trim("DIABETES_TYPE"::varchar), '') as diabetes_type,
    "FLOAT_ADDON"::number as float_addon,
    "FLOAT_PREMIUM"::number as float_premium,
    "FROM_DATE"::timestamp_ntz as from_date,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("HEART_FLAG"::varchar), '') as heart_flag,
    nullif(trim("HEIGHT_FLAG"::varchar), '') as height_flag,
    nullif(trim("HIPERTENSION_FLAG"::varchar), '') as hipertension_flag,
    nullif(trim("HOLESTEROL_FLAG"::varchar), '') as holesterol_flag,
    nullif(trim("HOSP_CASH"::varchar), '') as hosp_cash,
    "HYPERLIPIDEMIA_LOAD"::number as hyperlipidemia_load,
    nullif(trim("HYPERLIPIDE_FLAG"::varchar), '') as hyperlipide_flag,
    "HYPERTENS_LOAD"::number as hypertens_load,
    nullif(trim("INSURED_NAME"::varchar), '') as insured_name,
    nullif(trim("LOADING_REASON"::varchar), '') as loading_reason,
    "LOAD_PER"::number as load_per,
    nullif(trim(to_varchar("MEMBER_NO")), '') as member_no,
    nullif(trim("MEMBER_OCCUPATION"::varchar), '') as member_occupation,
    "MONTHLY_INCOME"::number as monthly_income,
    nullif(trim("OBESITY_FLAG"::varchar), '') as obesity_flag,
    "OBESITY_LOAD"::number as obesity_load,
    nullif(trim("OTHER_RISK_FLAG"::varchar), '') as other_risk_flag,
    "OTHER_RISK_LOAD"::number as other_risk_load,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PERSONAL_ACC"::varchar), '') as personal_acc,
    nullif(trim(to_varchar("POLICY_NUMBER")), '') as policy_number,
    nullif(trim("PREEXIST_DICEASE"::varchar), '') as preexist_dicease,
    "PREMIUM"::number as premium,
    "PREVIOUS_SI"::number as previous_si,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("REPORTS_NORMAL"::varchar), '') as reports_normal,
    nullif(trim("SI_PLAN"::varchar), '') as si_plan,
    nullif(trim("SMOKER_FLAG"::varchar), '') as smoker_flag,
    nullif(trim("SPECIAL_CONDITIONS"::varchar), '') as special_conditions,
    "SUM_INSURED"::number as sum_insured,
    "TO_DATE"::timestamp_ntz as to_date,
    nullif(trim("WEIGHT_FLAG"::varchar), '') as weight_flag
    from {{ source('health_raw', 'BJAZ_HCF_MEMBER_DTLS') }}

)

select * from source
