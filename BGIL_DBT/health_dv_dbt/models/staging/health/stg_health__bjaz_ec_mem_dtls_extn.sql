-- Staging model for source table BJAZ_EC_MEM_DTLS_EXTN (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "AGE"::number as age,
    nullif(trim("AGE_PROOF"::varchar), '') as age_proof,
    nullif(trim("ASTHMA_YN"::varchar), '') as asthma_yn,
    nullif(trim("CLAIMED_FOR"::varchar), '') as claimed_for,
    "CLAIM_RECEIVED"::number as claim_received,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim("CON_POLICY_REF"::varchar), '') as con_policy_ref,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    "DEDUCTIBLE_AMT"::number as deductible_amt,
    nullif(trim("DIABETES_YN"::varchar), '') as diabetes_yn,
    nullif(trim("DISEASE_DTLS"::varchar), '') as disease_dtls,
    "EFFETIVE_DATE"::timestamp_ntz as effetive_date,
    "EXPIRY_DATE"::timestamp_ntz as expiry_date,
    nullif(trim("GENDER"::varchar), '') as gender,
    "GROSS_INCOME"::number as gross_income,
    "HEIGHT_CM"::number as height_cm,
    "HLTH_INS_POL_YRS"::number as hlth_ins_pol_yrs,
    nullif(trim("HYPERTENSION_YN"::varchar), '') as hypertension_yn,
    "INCEPTION_DATE"::timestamp_ntz as inception_date,
    nullif(trim("MEDICAL_CHECKUP"::varchar), '') as medical_checkup,
    nullif(trim(to_varchar("MEDICAL_REPORT")), '') as medical_report,
    nullif(trim(to_varchar("MEMBER_NO")), '') as member_no,
    nullif(trim("NAME"::varchar), '') as name,
    nullif(trim("NOMINEE_RLTN"::varchar), '') as nominee_rltn,
    nullif(trim("OCCUPATION"::varchar), '') as occupation,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PAST_4YR_ILLNESS"::varchar), '') as past_4yr_illness,
    "PAST_4YR_TREAT_DATE"::timestamp_ntz as past_4yr_treat_date,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim("PREGNANT_YN"::varchar), '') as pregnant_yn,
    "PREMIUM"::number as premium,
    nullif(trim("PREV_COMPANY_NAME"::varchar), '') as prev_company_name,
    nullif(trim("PREV_POLICY_DTLS"::varchar), '') as prev_policy_dtls,
    "PREV_SUM_INSURED"::number as prev_sum_insured,
    "PRE_POL_NCB_PER"::number as pre_pol_ncb_per,
    nullif(trim("PRIOR_4YR_ILLNESS"::varchar), '') as prior_4yr_illness,
    "PRIOR_4YR_TREAT_DATE"::timestamp_ntz as prior_4yr_treat_date,
    nullif(trim("PROPOSAL_REJECT_DTLS"::varchar), '') as proposal_reject_dtls,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("SMOKER_YN"::varchar), '') as smoker_yn,
    nullif(trim("SMOKE_CONSUMP"::varchar), '') as smoke_consump,
    nullif(trim("STATUS"::varchar), '') as status,
    "SUM_INSURED"::number as sum_insured,
    "WEIGHT_KG"::number as weight_kg
    from {{ source('health_raw', 'BJAZ_EC_MEM_DTLS_EXTN') }}

)

select * from source
