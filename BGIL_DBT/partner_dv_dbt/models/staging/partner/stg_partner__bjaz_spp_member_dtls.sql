-- Staging model for source table BJAZ_SPP_MEMBER_DTLS (Partner LOB).
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
    nullif(trim("CONTRACT_ID"::varchar), '') as contract_id,
    "MEMBER_NO"::number as member_no,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("INSURED_NAME"::varchar), '') as insured_name,
    nullif(trim("PARTNER_ID"::varchar), '') as partner_id,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    "AGE"::number as age,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("ASSIGNEE"::varchar), '') as assignee,
    nullif(trim("ASSIGNEE_RELATION"::varchar), '') as assignee_relation,
    nullif(trim("MEMBER_OCCUPATION"::varchar), '') as member_occupation,
    nullif(trim("PREEXIST_DICEASE"::varchar), '') as preexist_dicease,
    nullif(trim("MED_REPORT_RECEIVED"::varchar), '') as med_report_received,
    nullif(trim("REPORTS_NORMAL"::varchar), '') as reports_normal,
    nullif(trim("SPECIAL_CONDITIONS"::varchar), '') as special_conditions,
    nullif(trim("SI_PLAN"::varchar), '') as si_plan,
    "SUM_INSURED"::number as sum_insured,
    nullif(trim("HOSP_CASH"::varchar), '') as hosp_cash,
    nullif(trim("CRITICAL_ILLNESS"::varchar), '') as critical_illness,
    nullif(trim("PERSONAL_ACC"::varchar), '') as personal_acc,
    "LOAD_PER"::number as load_per,
    nullif(trim("LOADING_REASON"::varchar), '') as loading_reason,
    "PREMIUM"::number as premium,
    nullif(trim("COMPANY_NAME"::varchar), '') as company_name,
    nullif(trim("POLICY_NUMBER"::varchar), '') as policy_number,
    "PREVIOUS_SI"::number as previous_si,
    "FROM_DATE"::timestamp_ntz as from_date,
    "TO_DATE"::timestamp_ntz as to_date,
    "CUMULATIVE_BNOUZ_PER"::number as cumulative_bnouz_per,
    "CUMULATIVE_AMT"::number as cumulative_amt,
    "PREV_POLICY_SINCE"::timestamp_ntz as prev_policy_since,
    nullif(trim("CONCURRENT_POLICY_DETAILS"::varchar), '') as concurrent_policy_details,
    nullif(trim("DECEASE_TREATMENT_DTLS"::varchar), '') as decease_treatment_dtls,
    nullif(trim("CLAIM_DTLS"::varchar), '') as claim_dtls,
    nullif(trim("DIABETES"::varchar), '') as diabetes,
    nullif(trim("HYPERTENSION"::varchar), '') as hypertension,
    nullif(trim("CHOLESTEROL_DISORDER"::varchar), '') as cholesterol_disorder,
    nullif(trim("OBESITY"::varchar), '') as obesity,
    nullif(trim("CARDIOVASCULAR_DISEASES"::varchar), '') as cardiovascular_diseases,
    "TOT_MEMBER_LOADING"::number as tot_member_loading,
    nullif(trim("OTHER_OCC"::varchar), '') as other_occ,
    nullif(trim("HEIGHT_FEET"::varchar), '') as height_feet,
    nullif(trim("HEIGHT_INCHES"::varchar), '') as height_inches,
    nullif(trim("WEIGHT"::varchar), '') as weight,
    nullif(trim("BMI"::varchar), '') as bmi,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_raw', 'BJAZ_SPP_MEMBER_DTLS') }}

)

select * from source
