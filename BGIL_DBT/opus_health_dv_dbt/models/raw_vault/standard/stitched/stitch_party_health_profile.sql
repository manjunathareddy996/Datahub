{{ config(materialized='view') }}
-- This part feeds SAT_PARTY_HEALTH_PROFILE only. Original precedence comments are kept below (from stitch_v18_party).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_preauth_request') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_id_mem_detls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_preauth_request',
      'alias': 't0',
      'key_column': "nullif('HEALTHCARD:' || nullif(trim(patient_id_card),''), 'HEALTHCARD:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_REQUEST',
      'columns': [
        {'src': 'past_his_ailment', 'tgt': 'party_health_profile__pre_existing_disease_description'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't1',
      'key_column': 'pd_premium_payer_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'md_pre_exi_dis_dis_inf', 'tgt': 'party_health_profile__pre_existing_disease_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't2',
      'key_column': 'member_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'smoke_consump', 'tgt': 'party_health_profile__tobacco_consumption_detail'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_id_mem_detls',
      'alias': 't3',
      'key_column': 'member_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_ID_MEM_DETLS',
      'columns': [
        {'src': 'family_hist', 'tgt': 'party_health_profile__family_medical_history_indicator'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_health_profile__pre_existing_disease_description',
    'party_health_profile__tobacco_consumption_detail',
    'party_health_profile__family_medical_history_indicator'
] -%}
{%- set coalesce_rules = {
    'party_health_profile__pre_existing_disease_description': ['t0', 't1'],
    'party_health_profile__tobacco_consumption_detail': ['t2'],
    'party_health_profile__family_medical_history_indicator': ['t3']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_bk',
    target_sat='sat_party_health_profile'
) }}
