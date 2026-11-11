{{ config(materialized='view') }}
-- This part feeds SAT_PARTY_IDENTITY only. Original precedence comments are kept below (from stitch_v18_party).
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
-- depends_on: {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_preauth_request') }}
-- depends_on: {{ ref('stg_health__bjaz_intermediary') }}
-- depends_on: {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
-- depends_on: {{ ref('stg_health__ba_hcp_dt_mem') }}
-- depends_on: {{ ref('stg_health__ba_hcp_dt_mem_cov') }}
-- depends_on: {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
-- depends_on: {{ ref('stg_health__ba_hcp_pol_mst') }}
-- depends_on: {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bgil_gmc_final_instl_data') }}
-- depends_on: {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_gp_hospital_cash') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hc_part_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_cashless_inward') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_inward_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_patient_details') }}
-- depends_on: {{ ref('stg_health__ocp_interested_parties') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(imd_code),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': 'imd_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't1',
      'key_column': "nullif('EMP:' || nullif(trim(rm_code),''), 'EMP:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': 'rm_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't2',
      'key_column': "nullif(trim(ph_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': 'ph_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't3',
      'key_column': "nullif(trim(pp_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': 'pp_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't4',
      'key_column': "nullif(trim(subimd_code),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': 'subimd_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_preauth_request',
      'alias': 't5',
      'key_column': "nullif('HEALTHCARD:' || nullif(trim(patient_id_card),''), 'HEALTHCARD:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_REQUEST',
      'columns': [
        {'src': 'age_in_years', 'tgt': 'party_identity__age'},
        {'src': 'date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'patient_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_intermediary',
      'alias': 't6',
      'key_column': "nullif(trim(intermediary_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_INTERMEDIARY',
      'columns': [
        {'src': 'intermediary_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't7',
      'key_column': "nullif(trim(cust_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': 'dob', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'accountholdername', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_dt_mem',
      'alias': 't8',
      'key_column': 'part_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_MEM',
      'columns': [
        {'src': 'member_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_dt_mem_cov',
      'alias': 't9',
      'key_column': 'part_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_MEM_COV',
      'columns': [
        {'src': 'member_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_dt_pol_cov',
      'alias': 't10',
      'key_column': 'part_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_POL_COV',
      'columns': [
        {'src': 'member_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_pol_mst',
      'alias': 't11',
      'key_column': 'user_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_POL_MST',
      'columns': [
        {'src': 'coalesce(imd_name, member_name)', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_pp_mem_dtls',
      'alias': 't12',
      'key_column': 'alloted_to',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PP_MEM_DTLS',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'coalesce(dc_name, member_name)', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't13',
      'key_column': 'pd_premium_payer_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'md_date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'md_first_name', 'tgt': 'party_identity__first_name'},
        {'src': 'md_gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'md_last_name', 'tgt': 'party_identity__last_name'},
        {'src': 'md_middle_name', 'tgt': 'party_identity__middle_name'},
        {'src': 'md_nominee', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't14',
      'key_column': 'pd_premium_payer_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'md_date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'md_first_name', 'tgt': 'party_identity__first_name'},
        {'src': 'md_gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'md_last_name', 'tgt': 'party_identity__last_name'},
        {'src': 'md_middle_name', 'tgt': 'party_identity__middle_name'},
        {'src': 'coalesce(md_nominee, plc_name_of_assignee, plc_name_of_assignor)', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bgil_gmc_final_instl_data',
      'alias': 't15',
      'key_column': 'emp_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BGIL_GMC_FINAL_INSTL_DATA',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'emp_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_bandhan_medi_clam',
      'alias': 't16',
      'key_column': 'customer_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BANDHAN_MEDI_CLAM',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'dob', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'first_name', 'tgt': 'party_identity__first_name'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'last_name', 'tgt': 'party_identity__last_name'},
        {'src': 'middle_name', 'tgt': 'party_identity__middle_name'},
        {'src': 'coalesce(customer_name, nominee_name)', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't17',
      'key_column': 'member_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'coalesce(assignee, name)', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gp_hospital_cash',
      'alias': 't18',
      'key_column': 'user_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GP_HOSPITAL_CASH',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'dob', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'coalesce(customer_name, nominee_name)', 'tgt': 'party_identity__party_full_name'},
        {'src': 'customer_type', 'tgt': 'party_identity__party_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_id_mem_detls',
      'alias': 't19',
      'key_column': 'member_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_ID_MEM_DETLS',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'first_name', 'tgt': 'party_identity__first_name'},
        {'src': 'sex', 'tgt': 'party_identity__gender_code'},
        {'src': 'last_name', 'tgt': 'party_identity__last_name'},
        {'src': 'middle_name', 'tgt': 'party_identity__middle_name'},
        {'src': 'coalesce(assignee, emp_name)', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't20',
      'key_column': 'member_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'coalesce(assignee, insured_name)', 'tgt': 'party_identity__party_full_name'},
        {'src': 'company_name', 'tgt': 'party_identity__party_legal_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hc_part_extn',
      'alias': 't21',
      'key_column': 'part_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HC_PART_EXTN',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'sex', 'tgt': 'party_identity__gender_code'},
        {'src': 'coalesce(assignee_name, hospital, member_name)', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hdfc_sec_fhpp',
      'alias': 't22',
      'key_column': 'client_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HDFC_SEC_FHPP',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'dob', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'coalesce(customer_name, nominee_name)', 'tgt': 'party_identity__party_full_name'},
        {'src': 'customer_type', 'tgt': 'party_identity__party_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't23',
      'key_column': 'part_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'first_name', 'tgt': 'party_identity__first_name'},
        {'src': 'last_name', 'tgt': 'party_identity__last_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hlt_ensure_mem_dtls',
      'alias': 't24',
      'key_column': 'member_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HLT_ENSURE_MEM_DTLS',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'coalesce(assignee, name)', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_cashless_inward',
      'alias': 't25',
      'key_column': 'hospital_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_CASHLESS_INWARD',
      'columns': [
        {'src': 'patient_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_coinsu_clm_dtls',
      'alias': 't26',
      'key_column': 'ldr_pid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_COINSU_CLM_DTLS',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'sex', 'tgt': 'party_identity__gender_code'},
        {'src': 'coalesce(emp_name, name, name_of_hospital)', 'tgt': 'party_identity__party_full_name'},
        {'src': 'name_coinsr_co', 'tgt': 'party_identity__party_legal_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't27',
      'key_column': 'hospital_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'processor', 'tgt': 'party_identity__party_display_name'},
        {'src': 'coalesce(employee_name, hospital, insured, name_dr, patient)', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master',
      'alias': 't28',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER',
      'columns': [
        {'src': 'hospital_name', 'tgt': 'party_identity__party_full_name'},
        {'src': 'hosp_type', 'tgt': 'party_identity__party_sub_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't29',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'coalesce(admission_person, auth_signatory, billing_person, closure_by, initiated_by, referral_by)', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hosp_master_extn1',
      'alias': 't30',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSP_MASTER_EXTN1',
      'columns': [
        {'src': 'delistedhosp', 'tgt': 'party_identity__party_status'},
        {'src': 'delistedhospreason', 'tgt': 'party_identity__party_status_reason'},
        {'src': 'hospcatg', 'tgt': 'party_identity__party_sub_type_code'},
        {'src': 'pcatghosp', 'tgt': 'party_identity__party_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_inward_dtls',
      'alias': 't31',
      'key_column': 'courier_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_INWARD_DTLS',
      'columns': [
        {'src': 'coalesce(member_name, proposer_name, sender_name)', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't32',
      'key_column': 'member_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'dob', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'coalesce(assignee_name, member_name)', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ihg_mem_dtls_extn',
      'alias': 't33',
      'key_column': 'member_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_IHG_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'coalesce(assignee, name)', 'tgt': 'party_identity__party_full_name'},
        {'src': 'company_name', 'tgt': 'party_identity__party_legal_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_scr_hlth_portable_dtls',
      'alias': 't34',
      'key_column': 'member_identifier',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_SCR_HLTH_PORTABLE_DTLS',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'insured_dob', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'insured_gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'insured_name', 'tgt': 'party_identity__party_full_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_sh_mem_dtls_extn',
      'alias': 't35',
      'key_column': 'member_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_SH_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'age', 'tgt': 'party_identity__age'},
        {'src': 'date_of_birth', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'coalesce(assignee, doctor_name, name)', 'tgt': 'party_identity__party_full_name'},
        {'src': 'company_name', 'tgt': 'party_identity__party_legal_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_patient_details',
      'alias': 't36',
      'key_column': "nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_PATIENT_DETAILS',
      'columns': [
        {'src': 'age_year', 'tgt': 'party_identity__age'},
        {'src': 'dob', 'tgt': 'party_identity__date_of_birth'},
        {'src': 'first_name', 'tgt': 'party_identity__first_name'},
        {'src': 'gender', 'tgt': 'party_identity__gender_code'},
        {'src': 'last_name', 'tgt': 'party_identity__last_name'},
        {'src': 'middle_name', 'tgt': 'party_identity__middle_name'}
      ]
    },
    {
      'model': 'stg_health__ocp_interested_parties',
      'alias': 't37',
      'key_column': "nullif('PARTNER:' || nullif(trim(partner_id),''), 'PARTNER:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_OCP_INTERESTED_PARTIES',
      'columns': [
        {'src': 'customer_name_text', 'tgt': 'party_identity__party_full_name'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_identity__party_full_name',
    'party_identity__age',
    'party_identity__date_of_birth',
    'party_identity__gender_code',
    'party_identity__first_name',
    'party_identity__last_name',
    'party_identity__middle_name',
    'party_identity__party_type_code',
    'party_identity__party_legal_name',
    'party_identity__party_display_name',
    'party_identity__party_sub_type_code',
    'party_identity__party_status',
    'party_identity__party_status_reason'
] -%}
{%- set coalesce_rules = {
    'party_identity__party_full_name': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't24', 't25', 't26', 't27', 't28', 't29', 't31', 't32', 't33', 't34', 't35', 't37'],
    'party_identity__age': ['t5', 't12', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't24', 't26', 't27', 't32', 't33', 't34', 't35', 't36'],
    'party_identity__date_of_birth': ['t5', 't7', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't26', 't32', 't33', 't34', 't35', 't36'],
    'party_identity__gender_code': ['t5', 't7', 't13', 't14', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't24', 't26', 't27', 't32', 't33', 't34', 't35', 't36'],
    'party_identity__first_name': ['t13', 't14', 't16', 't19', 't23', 't36'],
    'party_identity__last_name': ['t13', 't14', 't16', 't19', 't23', 't36'],
    'party_identity__middle_name': ['t13', 't14', 't16', 't19', 't36'],
    'party_identity__party_type_code': ['t18', 't22', 't30'],
    'party_identity__party_legal_name': ['t20', 't26', 't33', 't35'],
    'party_identity__party_display_name': ['t27'],
    'party_identity__party_sub_type_code': ['t28', 't30'],
    'party_identity__party_status': ['t30'],
    'party_identity__party_status_reason': ['t30']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_bk',
    target_sat='sat_party_identity'
) }}
