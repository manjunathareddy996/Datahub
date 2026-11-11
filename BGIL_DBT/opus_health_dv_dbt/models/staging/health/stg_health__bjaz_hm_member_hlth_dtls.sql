-- Staging for source table BJAZ_HM_MEMBER_HLTH_DTLS (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AGE_PROOF")), '') as age_proof,
        nullif(trim(to_varchar("AMOUNT_CLAIMED")), '') as amount_claimed,
        nullif(trim(to_varchar("ASTHMA_YN")), '') as asthma_yn,
        nullif(trim(to_varchar("BODY_MAS_INDES")), '') as body_mas_indes,
        nullif(trim(to_varchar("CLAIM_HISTORY")), '') as claim_history,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("DIABETES_YN")), '') as diabetes_yn,
        nullif(trim(to_varchar("DISEASE_DTLS")), '') as disease_dtls,
        nullif(trim(to_varchar("FIRST_POLICY_REF")), '') as first_policy_ref,
        nullif(trim(to_varchar("GMC_DISEASE_TO_BE_EXCLUDED")), '') as gmc_disease_to_be_excluded,
        nullif(trim(to_varchar("GMC_FAMILY_HIST")), '') as gmc_family_hist,
        nullif(trim(to_varchar("GMC_FAMILY_HIST_DETAILS")), '') as gmc_family_hist_details,
        nullif(trim(to_varchar("GMC_GROUP_NO")), '') as gmc_group_no,
        nullif(trim(to_varchar("GMC_IHD")), '') as gmc_ihd,
        nullif(trim(to_varchar("GMC_LOAD_FLAG")), '') as gmc_load_flag,
        nullif(trim(to_varchar("GMC_METRO")), '') as gmc_metro,
        nullif(trim(to_varchar("HAT_ID_CITY")), '') as hat_id_city,
        nullif(trim(to_varchar("HAT_ID_STATE")), '') as hat_id_state,
        nullif(trim(to_varchar("HC_BENEFIT_OPTED")), '') as hc_benefit_opted,
        nullif(trim(to_varchar("HC_HOSPITAL")), '') as hc_hospital,
        nullif(trim(to_varchar("HC_PRESCRIPTION_DETAILS")), '') as hc_prescription_details,
        nullif(trim(to_varchar("HC_PRESCRIPTION_YN")), '') as hc_prescription_yn,
        nullif(trim(to_varchar("HC_RATE_STATUS")), '') as hc_rate_status,
        nullif(trim(to_varchar("HC_WAITING_PERIOD")), '') as hc_waiting_period,
        nullif(trim(to_varchar("HEIGHT_CM")), '') as height_cm,
        nullif(trim(to_varchar("HYPERTENSION_YN")), '') as hypertension_yn,
        nullif(trim(to_varchar("IHG_CLM_LOAD")), '') as ihg_clm_load,
        nullif(trim(to_varchar("IHG_POLICY_COLLECTED")), '') as ihg_policy_collected,
        nullif(trim(to_varchar("IHG_WAITING_PERIOD")), '') as ihg_waiting_period,
        nullif(trim(to_varchar("INCEPTION_DATE")), '') as inception_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("MEDICAL_CHECKUP")), '') as medical_checkup,
        nullif(trim(to_varchar("MEDICAL_REPORT")), '') as medical_report,
        nullif(trim(to_varchar("MEMBER_ID")), '') as member_id,
        nullif(trim(to_varchar("OTHER_HLT_DTLS")), '') as other_hlt_dtls,
        nullif(trim(to_varchar("PREV_POLICY_DTLS")), '') as prev_policy_dtls,
        nullif(trim(to_varchar("PREV_SUM_INSURED")), '') as prev_sum_insured,
        nullif(trim(to_varchar("PRE_EXISTING_DISEASES")), '') as pre_existing_diseases,
        nullif(trim(to_varchar("REMARK_CENTER")), '') as remark_center,
        nullif(trim(to_varchar("REMARK_ENROLLMENT")), '') as remark_enrollment,
        nullif(trim(to_varchar("RENAL_PROBLEM")), '') as renal_problem,
        nullif(trim(to_varchar("SH_COMMENTS")), '') as sh_comments,
        nullif(trim(to_varchar("SH_DOCTOR_NAME")), '') as sh_doctor_name,
        nullif(trim(to_varchar("SH_PERIOD_OF_INSURANCE")), '') as sh_period_of_insurance,
        nullif(trim(to_varchar("SH_PERIOD_TREATMENT")), '') as sh_period_treatment,
        nullif(trim(to_varchar("SMOKER_YN")), '') as smoker_yn,
        nullif(trim(to_varchar("WEIGHT_KG")), '') as weight_kg
    from {{ source('health_raw', 'BJAZ_HM_MEMBER_HLTH_DTLS') }}

)

select * from source
