-- Staging for source table BJAZ_IHG_MEM_DTLS_EXTN (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("AGE_PROOF")), '') as age_proof,
        nullif(trim(to_varchar("AMOUNT_CLAIMED")), '') as amount_claimed,
        nullif(trim(to_varchar("ASSIGNEE")), '') as assignee,
        nullif(trim(to_varchar("ASTHMA_YN")), '') as asthma_yn,
        nullif(trim(to_varchar("BODY_MAS_INDX")), '') as body_mas_indx,
        nullif(trim(to_varchar("CLAIM_HISTORY")), '') as claim_history,
        nullif(trim(to_varchar("CLM_LOAD")), '') as clm_load,
        nullif(trim(to_varchar("COMPANY_NAME")), '') as company_name,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("CUMM_BONUS")), '') as cumm_bonus,
        nullif(trim(to_varchar("CUMM_BONUS_PER")), '') as cumm_bonus_per,
        nullif(trim(to_varchar("DATE_OF_BIRTH")), '') as date_of_birth,
        nullif(trim(to_varchar("DIABETES_YN")), '') as diabetes_yn,
        nullif(trim(to_varchar("DISEASE_DTLS")), '') as disease_dtls,
        nullif(trim(to_varchar("EFFETIVE_DATE")), '') as effetive_date,
        nullif(trim(to_varchar("EXPIRY_DATE")), '') as expiry_date,
        nullif(trim(to_varchar("FIRST_POLICY_REF")), '') as first_policy_ref,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        nullif(trim(to_varchar("GROSS_INCOME")), '') as gross_income,
        nullif(trim(to_varchar("HEIGHT_CM")), '') as height_cm,
        nullif(trim(to_varchar("HYPERTENSION_YN")), '') as hypertension_yn,
        nullif(trim(to_varchar("INCEPTION_DATE")), '') as inception_date,
        nullif(trim(to_varchar("LOAD_AMT")), '') as load_amt,
        nullif(trim(to_varchar("LOAD_RATE")), '') as load_rate,
        nullif(trim(to_varchar("MEDICAL_CHECKUP")), '') as medical_checkup,
        nullif(trim(to_varchar("MEDICAL_REPORT")), '') as medical_report,
        nullif(trim(to_varchar("MEMBER_NO")), '') as member_no,
        nullif(trim(to_varchar("NAME")), '') as name,
        nullif(trim(to_varchar("NOMINEE_RLTN")), '') as nominee_rltn,
        nullif(trim(to_varchar("OCCUPATION")), '') as occupation,
        nullif(trim(to_varchar("OTHER_HLT_DTLS")), '') as other_hlt_dtls,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("PREMIUM")), '') as premium,
        nullif(trim(to_varchar("PREV_POLICY_DTLS")), '') as prev_policy_dtls,
        nullif(trim(to_varchar("PREV_SUM_INSURED")), '') as prev_sum_insured,
        nullif(trim(to_varchar("RELATION")), '') as relation,
        nullif(trim(to_varchar("SMOKER_YN")), '') as smoker_yn,
        nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured,
        nullif(trim(to_varchar("WAITING_PERIOD")), '') as waiting_period,
        nullif(trim(to_varchar("WEIGHT_KG")), '') as weight_kg
    from {{ source('health_raw', 'BJAZ_IHG_MEM_DTLS_EXTN') }}

)

select * from source
