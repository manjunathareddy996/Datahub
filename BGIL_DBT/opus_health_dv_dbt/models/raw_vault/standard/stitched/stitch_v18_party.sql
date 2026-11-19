-- CENTRAL VIEW v18_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_INTERMEDIARY (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_DT_MEM (opus_health_legacy_v4)
--   BA_HCP_DT_MEM_COV (opus_health_legacy_v4)
--   BA_HCP_DT_POL_COV (opus_health_legacy_v4)
--   BA_HCP_POL_MST (opus_health_legacy_v4)
--   BA_HCP_PP_MEM_DTLS (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GP_HOSPITAL_CASH (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HDFC_SEC_FHPP (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_CASHLESS_INWARD (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER_EXTN (opus_health_legacy_v4)
--   BJAZ_HM_HOSP_MASTER_EXTN1 (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SCR_HLTH_PORTABLE_DTLS (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_REMEDINET_PATIENT_DETAILS (opus_health_delta3)
--   OCP_INTERESTED_PARTIES (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_LNK_ROLE_CUSTOMER
--   SAT_PARTY_EMPLOYMENT
--   SAT_PARTY_HEALTH_PROFILE
--   SAT_PARTY_IDENTITY
--   SAT_PARTY_PROVIDER_CAPABILITY
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_ENROLL_POL_DTLS
    select
        nullif(trim(imd_code),'') as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        imd_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
    where (nullif(trim(imd_code),'')) is not null

    union all

    -- branch 1: BJAZ_ENROLL_POL_DTLS
    select
        nullif('EMP:' || nullif(trim(rm_code),''), 'EMP:') as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        rm_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
    where (nullif('EMP:' || nullif(trim(rm_code),''), 'EMP:')) is not null

    union all

    -- branch 2: BJAZ_ENROLL_POL_DTLS
    select
        nullif(trim(ph_id),'') as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        ph_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
    where (nullif(trim(ph_id),'')) is not null

    union all

    -- branch 3: BJAZ_ENROLL_POL_DTLS
    select
        nullif(trim(pp_id),'') as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        pp_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
    where (nullif(trim(pp_id),'')) is not null

    union all

    -- branch 4: BJAZ_ENROLL_POL_DTLS
    select
        nullif(trim(subimd_code),'') as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        subimd_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
    where (nullif(trim(subimd_code),'')) is not null

    union all

    -- branch 5: BJAZ_HM_PREAUTH_REQUEST
    select
        nullif('HEALTHCARD:' || nullif(trim(patient_id_card),''), 'HEALTHCARD:') as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        past_his_ailment as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age_in_years as PARTY_IDENTITY__AGE,
        date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        patient_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_preauth_request') }}
    where (nullif('HEALTHCARD:' || nullif(trim(patient_id_card),''), 'HEALTHCARD:')) is not null

    union all

    -- branch 6: BJAZ_INTERMEDIARY
    select
        nullif(trim(intermediary_id),'') as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        intermediary_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        2 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_intermediary') }}
    where (nullif(trim(intermediary_id),'')) is not null

    union all

    -- branch 7: BJAZ_PMSBY_DATA_WEB_SERVICE
    select
        nullif(trim(cust_id),'') as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        dob as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        accountholdername as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        3 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
    where (nullif(trim(cust_id),'')) is not null

    union all

    -- branch 8: BA_HCP_DT_MEM
    select
        part_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        member_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_dt_mem') }}
    where (part_id) is not null

    union all

    -- branch 9: BA_HCP_DT_MEM_COV
    select
        part_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        member_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1005 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_dt_mem_cov') }}
    where (part_id) is not null

    union all

    -- branch 10: BA_HCP_DT_POL_COV
    select
        part_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        member_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1006 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
    where (part_id) is not null

    union all

    -- branch 11: BA_HCP_POL_MST
    select
        user_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(imd_name, member_name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1007 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where (user_id) is not null

    union all

    -- branch 12: BA_HCP_PP_MEM_DTLS
    select
        alloted_to as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(dc_name, member_name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1008 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where (alloted_to) is not null

    union all

    -- branch 13: BA_HCP_PROD_8428_GPG_LOADER
    select
        pd_premium_payer_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        md_date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        md_first_name as PARTY_IDENTITY__FIRST_NAME,
        md_gender as PARTY_IDENTITY__GENDER_CODE,
        md_last_name as PARTY_IDENTITY__LAST_NAME,
        md_middle_name as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        md_nominee as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1009 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where (pd_premium_payer_id) is not null

    union all

    -- branch 14: BA_HCP_PROD_8439_CLH_LOADER
    select
        pd_premium_payer_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        md_occupation_type as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        md_pre_exi_dis_dis_inf as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        md_date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        md_first_name as PARTY_IDENTITY__FIRST_NAME,
        md_gender as PARTY_IDENTITY__GENDER_CODE,
        md_last_name as PARTY_IDENTITY__LAST_NAME,
        md_middle_name as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(md_nominee, plc_name_of_assignee, plc_name_of_assignor) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1010 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where (pd_premium_payer_id) is not null

    union all

    -- branch 15: BGIL_GMC_FINAL_INSTL_DATA
    select
        emp_code as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        emp_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1011 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bgil_gmc_final_instl_data') }}
    where (emp_code) is not null

    union all

    -- branch 16: BJAZ_BANDHAN_MEDI_CLAM
    select
        customer_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        dob as PARTY_IDENTITY__DATE_OF_BIRTH,
        first_name as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        last_name as PARTY_IDENTITY__LAST_NAME,
        middle_name as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(customer_name, nominee_name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1012 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where (customer_id) is not null

    union all

    -- branch 17: BJAZ_EC_MEM_DTLS_EXTN
    select
        member_no as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        occupation as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        smoke_consump as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(assignee, name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1013 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where (member_no) is not null

    union all

    -- branch 18: BJAZ_GP_HOSPITAL_CASH
    select
        user_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        dob as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(customer_name, nominee_name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        customer_type as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1014 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where (user_id) is not null

    union all

    -- branch 19: BJAZ_HAT_ID_MEM_DETLS
    select
        member_no as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        designation as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        profession as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        family_hist as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        first_name as PARTY_IDENTITY__FIRST_NAME,
        sex as PARTY_IDENTITY__GENDER_CODE,
        last_name as PARTY_IDENTITY__LAST_NAME,
        middle_name as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(assignee, emp_name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1015 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
    where (member_no) is not null

    union all

    -- branch 20: BJAZ_HCF_MEMBER_DTLS
    select
        member_no as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        member_occupation as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(assignee, insured_name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        company_name as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1016 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where (member_no) is not null

    union all

    -- branch 21: BJAZ_HC_PART_EXTN
    select
        part_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        occupation as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        sex as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(assignee_name, hospital, member_name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1017 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hc_part_extn') }}
    where (part_id) is not null

    union all

    -- branch 22: BJAZ_HC_PART_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=HOSPITAL_DETAIL
    select
        part_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'HOSPITAL_DETAIL' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        hospital_detail as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1017 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hc_part_extn') }}
    where (part_id) is not null

    union all

    -- branch 23: BJAZ_HDFC_SEC_FHPP
    select
        client_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        dob as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(customer_name, nominee_name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        customer_type as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1018 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where (client_id) is not null

    union all

    -- branch 24: BJAZ_HG_POL_DTLS
    select
        part_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        first_name as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        last_name as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1019 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where (part_id) is not null

    union all

    -- branch 25: BJAZ_HLT_ENSURE_MEM_DTLS
    select
        member_no as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(assignee, name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1020 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
    where (member_no) is not null

    union all

    -- branch 26: BJAZ_HM_CASHLESS_INWARD | child-key literal(s): LNK_ROLE_CUSTOMER.Role Type=CUSTOMER
    select
        hospital_id as PARTY_BK,
        'CUSTOMER' as ROLE_TYPE_CODE,
        'CUSTOMER' as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        vip_flag_inward as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1021 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_cashless_inward') }}
    where (hospital_id) is not null

    union all

    -- branch 27: BJAZ_HM_CASHLESS_INWARD
    select
        hospital_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        patient_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1021 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_cashless_inward') }}
    where (hospital_id) is not null

    union all

    -- branch 28: BJAZ_HM_COINSU_CLM_DTLS
    select
        ldr_pid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        sex as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(emp_name, name, name_of_hospital) as PARTY_IDENTITY__PARTY_FULL_NAME,
        name_coinsr_co as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1022 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
    where (ldr_pid) is not null

    union all

    -- branch 29: BJAZ_HM_HCM_EXTRACT
    select
        hospital_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        processor as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(employee_name, hospital, insured, name_dr, patient) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1023 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where (hospital_id) is not null

    union all

    -- branch 30: BJAZ_HM_HOSPITAL_MASTER
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        hospital_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        hosp_type as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1024 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where (hosid) is not null

    union all

    -- branch 31: BJAZ_HM_HOSPITAL_MASTER | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DIAGNO_YN
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DIAGNO_YN' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        diagno_yn as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1024 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where (hosid) is not null

    union all

    -- branch 32: BJAZ_HM_HOSPITAL_MASTER | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=HOSP_SPECIALITY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'HOSP_SPECIALITY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        hosp_speciality as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1024 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where (hosid) is not null

    union all

    -- branch 33: BJAZ_HM_HOSPITAL_MASTER | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=HOSP_SPEC_TYPE
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'HOSP_SPEC_TYPE' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        hosp_spec_type as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1024 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where (hosid) is not null

    union all

    -- branch 34: BJAZ_HM_HOSPITAL_MASTER_EXTN
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(admission_person, auth_signatory, billing_person, closure_by, initiated_by, referral_by) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 35: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=TOTAL_BEDS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'TOTAL_BEDS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        total_beds as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 36: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ICU_BEDS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ICU_BEDS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        icu_beds as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 37: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DELUXE_BEDS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DELUXE_BEDS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        deluxe_beds as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 38: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=SINGLE_AC_BEDS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'SINGLE_AC_BEDS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        single_ac_beds as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 39: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=SINGLE_NONAC_BEDS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'SINGLE_NONAC_BEDS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        single_nonac_beds as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 40: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=GENERAL_WARD_BEDS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'GENERAL_WARD_BEDS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        general_ward_beds as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 41: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NO_OPRN_THEATRES
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NO_OPRN_THEATRES' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        no_oprn_theatres as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 42: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=CR_CARD_ACCEPTED
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'CR_CARD_ACCEPTED' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cr_card_accepted as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 43: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=BIOCHEMISTRY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'BIOCHEMISTRY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        biochemistry as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 44: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=CLINIC_PATHOLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'CLINIC_PATHOLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        clinic_pathology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 45: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=HEMATOLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'HEMATOLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        hematology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 46: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=RAD_IMM_ASSAY_RIA
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'RAD_IMM_ASSAY_RIA' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        rad_imm_assay_ria as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 47: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ULTRASOUND
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ULTRASOUND' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        ultrasound as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 48: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=X_RAY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'X_RAY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        x_ray as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 49: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ECG
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ECG' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        ecg as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 50: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=CT_SCAN
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'CT_SCAN' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        ct_scan as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 51: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=MRI
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'MRI' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        mri as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 52: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=PFT_SPIROMETRY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'PFT_SPIROMETRY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        pft_spirometry as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 53: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=TREAD_MILL_TEST
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'TREAD_MILL_TEST' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        tread_mill_test as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 54: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=CHEMOTHERAPY_UNIT
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'CHEMOTHERAPY_UNIT' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        chemotherapy_unit as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 55: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DIALYSIS_UNIT
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DIALYSIS_UNIT' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        dialysis_unit as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 56: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=BLOOD_BANK
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'BLOOD_BANK' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        blood_bank as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 57: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=INHOUSE_PHARMACY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'INHOUSE_PHARMACY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        inhouse_pharmacy as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 58: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ISOLATION_WARDS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ISOLATION_WARDS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        isolation_wards as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 59: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=HOLTER
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'HOLTER' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        holter as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 60: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ECHO
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ECHO' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        echo as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 61: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=EEG
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'EEG' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        eeg as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 62: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=EMG
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'EMG' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        emg as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 63: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=GAMMA_KNIFE
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'GAMMA_KNIFE' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        gamma_knife as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 64: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=COBALT_UNIT
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'COBALT_UNIT' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cobalt_unit as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 65: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=X_KNIFE
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'X_KNIFE' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        x_knife as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 66: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=BRONCHOSCOPY_LAB
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'BRONCHOSCOPY_LAB' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        bronchoscopy_lab as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 67: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=CATH_LAB
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'CATH_LAB' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cath_lab as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 68: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=LR_ACCELERATOR
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'LR_ACCELERATOR' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        lr_accelerator as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 69: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DSA
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DSA' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        dsa as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 70: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=LASERS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'LASERS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        lasers as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 71: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=PHYSIOTHERAPY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'PHYSIOTHERAPY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        physiotherapy as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 72: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=AMBULANCE
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'AMBULANCE' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        ambulance as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 73: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=EMERGENCY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'EMERGENCY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        emergency as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 74: BJAZ_HM_HOSPITAL_MASTER_EXTN | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=PHOTOTHERAPY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'PHOTOTHERAPY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        phototherapy as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1025 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where (hosid) is not null

    union all

    -- branch 75: BJAZ_HM_HOSP_MASTER_EXTN1
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        delistedhosp as PARTY_IDENTITY__PARTY_STATUS,
        delistedhospreason as PARTY_IDENTITY__PARTY_STATUS_REASON,
        hospcatg as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        pcatghosp as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 76: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DIAGCENTER
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DIAGCENTER' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        diagcenter as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 77: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=WELLCENTER
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'WELLCENTER' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        wellcenter as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 78: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ONLINEHOSPREF
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ONLINEHOSPREF' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        onlinehospref as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 79: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DOCAVAILMDMS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DOCAVAILMDMS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        docavailmdms as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 80: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DOCAVAILMBBS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DOCAVAILMBBS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        docavailmbbs as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 81: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DOCAVAILMEDICINE
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DOCAVAILMEDICINE' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        docavailmedicine as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 82: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DOCAVAILBLEND
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DOCAVAILBLEND' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        docavailblend as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 83: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NURSEAVAILREG
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NURSEAVAILREG' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        nurseavailreg as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 84: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NURSEAVAILBLEND
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NURSEAVAILBLEND' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        nurseavailblend as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 85: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NURSEAVAILANM
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NURSEAVAILANM' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        nurseavailanm as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 86: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DNBTRAINING
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DNBTRAINING' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        dnbtraining as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 87: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DIPLOMATRAINING
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DIPLOMATRAINING' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        diplomatraining as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 88: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NURSINGSCH
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NURSINGSCH' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        nursingsch as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 89: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NOTRAINING
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NOTRAINING' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        notraining as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 90: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NABHCERTIFIED
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NABHCERTIFIED' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        nabhcertified as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 91: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=JCI
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'JCI' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        jci as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 92: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ISO
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ISO' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        iso as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 93: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=IPHS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'IPHS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        iphs as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 94: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NOACCR
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NOACCR' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        noaccr as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 95: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=MTP
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'MTP' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        mtp as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 96: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=HOTA
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'HOTA' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        hota as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 97: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=PNDT
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'PNDT' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        pndt as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 98: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=FDAPHARMA
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'FDAPHARMA' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        fdapharma as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 99: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NABL
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NABL' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        nabl as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 100: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=OPTHAMOLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'OPTHAMOLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        opthamology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 101: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=PEDIATRIC
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'PEDIATRIC' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        pediatric as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 102: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=CARDIOLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'CARDIOLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cardiology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 103: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=PULMONOLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'PULMONOLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        pulmonology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 104: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ENT
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ENT' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        ent as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 105: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ONCOLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ONCOLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        oncology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 106: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=CRITICALCARE
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'CRITICALCARE' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        criticalcare as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 107: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DERMATOLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DERMATOLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        dermatology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 108: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=BURN
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'BURN' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        burn as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 109: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ORTHOPEDICS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ORTHOPEDICS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        orthopedics as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 110: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=GENERALMEDICINE
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'GENERALMEDICINE' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        generalmedicine as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 111: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ENDOCRINOLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ENDOCRINOLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        endocrinology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 112: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=PLASTICSURGERY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'PLASTICSURGERY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        plasticsurgery as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 113: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=TRAUMA
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'TRAUMA' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        trauma as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 114: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=INFECTIOUSDISEASE
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'INFECTIOUSDISEASE' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        infectiousdisease as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 115: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DENTAL
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DENTAL' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        dental as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 116: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=OBSGYNECOLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'OBSGYNECOLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        obsgynecology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 117: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=GENERALSURGERY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'GENERALSURGERY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        generalsurgery as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 118: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NEPHROLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NEPHROLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        nephrology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 119: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=DAYCARE
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'DAYCARE' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        daycare as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 120: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=GENITOURINARY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'GENITOURINARY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        genitourinary as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 121: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=GASTROENTROLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'GASTROENTROLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        gastroentrology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 122: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NEUROLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NEUROLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        neurology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 123: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=LAPAROSCOPICSURGERY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'LAPAROSCOPICSURGERY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        laparoscopicsurgery as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 124: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=RHEUMATOLOGY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'RHEUMATOLOGY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        rheumatology as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 125: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=SEMITWIN
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'SEMITWIN' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        semitwin as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 126: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=TRIPPLESHARING
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'TRIPPLESHARING' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        tripplesharing as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 127: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=SUIT
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'SUIT' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        suit as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 128: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NICUBEDS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NICUBEDS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        nicubeds as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 129: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=OPERATINGHRS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'OPERATINGHRS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        operatinghrs as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 130: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=RECOVERYROOMS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'RECOVERYROOMS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        recoveryrooms as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 131: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=MEDICALESTCOV
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'MEDICALESTCOV' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        medicalestcov as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 132: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=FIRESAFETY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'FIRESAFETY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        firesafety as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 133: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=PORTABLEECG
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'PORTABLEECG' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        portableecg as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 134: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ULTRASOUDREG
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ULTRASOUDREG' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        ultrasoudreg as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 135: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=MEDICALRECORD
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'MEDICALRECORD' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        medicalrecord as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 136: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=BOYLEAPPR
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'BOYLEAPPR' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        boyleappr as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 137: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=CODINGPROC
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'CODINGPROC' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        codingproc as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 138: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=BIOMEDWASTE
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'BIOMEDWASTE' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        biomedwaste as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 139: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=PORTABLEXRAY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'PORTABLEXRAY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        portablexray as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 140: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ICD10
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'ICD10' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        icd10 as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 141: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=CENTROXY
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'CENTROXY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        centroxy as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 142: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=CENTRSTERIL
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'CENTRSTERIL' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        centrsteril as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 143: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=INCUBATOR
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'INCUBATOR' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        incubator as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 144: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=STERIAREA
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'STERIAREA' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        steriarea as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 145: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=POWERBKUP
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'POWERBKUP' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        powerbkup as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 146: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=LAMINARFLOW
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'LAMINARFLOW' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        laminarflow as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 147: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=MEDICALAUDIT
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'MEDICALAUDIT' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        medicalaudit as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 148: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=INFECTNCTRL
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'INFECTNCTRL' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        infectnctrl as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 149: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=TOT_NO_DOCT
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'TOT_NO_DOCT' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        tot_no_doct as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 150: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=TOT_NO_NURSE
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'TOT_NO_NURSE' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        tot_no_nurse as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 151: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=TOT_MBBS_DOCT
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'TOT_MBBS_DOCT' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        tot_mbbs_doct as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 152: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=VISIT_CONSLNT
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'VISIT_CONSLNT' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        visit_conslnt as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 153: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=TOT_NO_SURGEN
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'TOT_NO_SURGEN' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        tot_no_surgen as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 154: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=NURSE_NO_ICU
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'NURSE_NO_ICU' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        nurse_no_icu as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 155: BJAZ_HM_HOSP_MASTER_EXTN1 | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=STAT_LVL_NQAS
    select
        hosid as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        'STAT_LVL_NQAS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        stat_lvl_nqas as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1026 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where (hosid) is not null

    union all

    -- branch 156: BJAZ_HM_INWARD_DTLS | child-key literal(s): LNK_ROLE_CUSTOMER.Role Type=CUSTOMER
    select
        courier_id as PARTY_BK,
        'CUSTOMER' as ROLE_TYPE_CODE,
        'CUSTOMER' as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        vip_flag as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1027 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where (courier_id) is not null

    union all

    -- branch 157: BJAZ_HM_INWARD_DTLS
    select
        courier_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(member_name, proposer_name, sender_name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1027 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where (courier_id) is not null

    union all

    -- branch 158: BJAZ_HM_MEMBER_DTLS | child-key literal(s): LNK_ROLE_CUSTOMER.Role Type=CUSTOMER
    select
        member_id as PARTY_BK,
        'CUSTOMER' as ROLE_TYPE_CODE,
        'CUSTOMER' as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        vip_flg as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1028 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where (member_id) is not null

    union all

    -- branch 159: BJAZ_HM_MEMBER_DTLS
    select
        member_id as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        designation as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        occupation as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        dob as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(assignee_name, member_name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1028 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where (member_id) is not null

    union all

    -- branch 160: BJAZ_IHG_MEM_DTLS_EXTN
    select
        member_no as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        occupation as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(assignee, name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        company_name as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1029 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where (member_no) is not null

    union all

    -- branch 161: BJAZ_SCR_HLTH_PORTABLE_DTLS
    select
        member_identifier as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        insured_dob as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        insured_gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        insured_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1030 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}
    where (member_identifier) is not null

    union all

    -- branch 162: BJAZ_SH_MEM_DTLS_EXTN
    select
        member_no as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        occupation as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age as PARTY_IDENTITY__AGE,
        date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        coalesce(assignee, doctor_name, name) as PARTY_IDENTITY__PARTY_FULL_NAME,
        company_name as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        1031 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where (member_no) is not null

    union all

    -- branch 163: BJAZ_REMEDINET_PATIENT_DETAILS
    select
        nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:') as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        age_year as PARTY_IDENTITY__AGE,
        dob as PARTY_IDENTITY__DATE_OF_BIRTH,
        first_name as PARTY_IDENTITY__FIRST_NAME,
        gender as PARTY_IDENTITY__GENDER_CODE,
        last_name as PARTY_IDENTITY__LAST_NAME,
        middle_name as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        2032 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_remedinet_patient_details') }}
    where (nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:')) is not null

    union all

    -- branch 164: OCP_INTERESTED_PARTIES
    select
        nullif('PARTNER:' || nullif(trim(partner_id),''), 'PARTNER:') as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        customer_name_text as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME,
        2033 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ocp_interested_parties') }}
    where (nullif('PARTNER:' || nullif(trim(partner_id),''), 'PARTNER:')) is not null

)

select
    PARTY_BK,
    ROLE_TYPE_CODE,
    LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
    first_value(LNK_ROLE_CUSTOMER__VIP_INDICATOR) ignore nulls over (partition by PARTY_BK, LNK_ROLE_CUSTOMER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
    first_value(PARTY_EMPLOYMENT__DESIGNATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__DESIGNATION,
    first_value(PARTY_EMPLOYMENT__OCCUPATION_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
    first_value(PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
    first_value(PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
    first_value(PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
    first_value(PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
    first_value(PARTY_IDENTITY__AGE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__AGE,
    first_value(PARTY_IDENTITY__DATE_OF_BIRTH) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__DATE_OF_BIRTH,
    first_value(PARTY_IDENTITY__FIRST_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__FIRST_NAME,
    first_value(PARTY_IDENTITY__GENDER_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__GENDER_CODE,
    first_value(PARTY_IDENTITY__LAST_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__LAST_NAME,
    first_value(PARTY_IDENTITY__MIDDLE_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__MIDDLE_NAME,
    first_value(PARTY_IDENTITY__PARTY_DISPLAY_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
    first_value(PARTY_IDENTITY__PARTY_FULL_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_FULL_NAME,
    first_value(PARTY_IDENTITY__PARTY_LEGAL_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
    first_value(PARTY_IDENTITY__PARTY_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_STATUS,
    first_value(PARTY_IDENTITY__PARTY_STATUS_REASON) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_STATUS_REASON,
    first_value(PARTY_IDENTITY__PARTY_SUB_TYPE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
    first_value(PARTY_IDENTITY__PARTY_TYPE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_TYPE_CODE,
    PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
    first_value(PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR) ignore nulls over (partition by PARTY_BK, PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR,
    first_value(PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE) ignore nulls over (partition by PARTY_BK, PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE,
    first_value(PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR) ignore nulls over (partition by PARTY_BK, PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
    first_value(PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS) ignore nulls over (partition by PARTY_BK, PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS,
    first_value(PARTY_PROVIDER_CAPABILITY__CAPACITY) ignore nulls over (partition by PARTY_BK, PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PROVIDER_CAPABILITY__CAPACITY,
    first_value(PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY) ignore nulls over (partition by PARTY_BK, PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY,
    first_value(PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT) ignore nulls over (partition by PARTY_BK, PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT,
    first_value(PARTY_PROVIDER_CAPABILITY__FACILITY_NAME) ignore nulls over (partition by PARTY_BK, PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PROVIDER_CAPABILITY__FACILITY_NAME
from merged
