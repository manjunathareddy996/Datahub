{{ config(materialized='view') }}
-- This part feeds SAT_AUG_PARTY_IDENTITY only. Original precedence comments are kept below (from stitch_v15_party).
-- CENTRAL VIEW v15_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_INTERMEDIARY (opus_health_v2)
--   BJAZ_NEFT_PARTNER_DTLS (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_PP_MEM_DTLS (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER_EXTN (opus_health_legacy_v4)
--   BJAZ_HM_HOSP_MASTER_EXTN1 (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_POLICY_SUMMARY (opus_health_delta3)
--   BJAZ_REMEDINET_PATIENT_DETAILS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_COMMON_CONTACT
--   SAT_AUG_PARTY_HEALTH_PROFILE
--   SAT_AUG_PARTY_IDENTITY
--   SAT_AUG_PROVIDER_QUALITY
--   SAT_COMMON_CONTACT
--   SAT_PARTY_BANKING
--   SAT_PARTY_ORGANISATION_PROFILE
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_preauth_request') }}
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_patient_details') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_preauth_request',
      'alias': 't0',
      'key_column': "nullif('HEALTHCARD:' || nullif(trim(patient_id_card),''), 'HEALTHCARD:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_REQUEST',
      'columns': [
        {'src': 'age_in_mon', 'tgt': 'aug_party_identity__age_residual_months'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't1',
      'key_column': 'part_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'ind_national_card_holders', 'tgt': 'aug_party_identity__national_card_holder_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hosp_master_extn1',
      'alias': 't2',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSP_MASTER_EXTN1',
      'columns': [
        {'src': 'reactidate', 'tgt': 'aug_party_identity__reactivation_date'},
        {'src': 'hosstatusremark', 'tgt': 'aug_party_identity__status_remark'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't3',
      'key_column': 'member_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'old_member_no', 'tgt': 'aug_party_identity__legacy_member_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_patient_details',
      'alias': 't4',
      'key_column': "nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_PATIENT_DETAILS',
      'columns': [
        {'src': 'age_day', 'tgt': 'aug_party_identity__age_days_component'},
        {'src': 'age_month', 'tgt': 'aug_party_identity__age_months_component'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_party_identity__age_residual_months',
    'aug_party_identity__national_card_holder_indicator',
    'aug_party_identity__reactivation_date',
    'aug_party_identity__status_remark',
    'aug_party_identity__legacy_member_number',
    'aug_party_identity__age_days_component',
    'aug_party_identity__age_months_component'
] -%}
{%- set coalesce_rules = {
    'aug_party_identity__age_residual_months': ['t0'],
    'aug_party_identity__national_card_holder_indicator': ['t1'],
    'aug_party_identity__reactivation_date': ['t2'],
    'aug_party_identity__status_remark': ['t2'],
    'aug_party_identity__legacy_member_number': ['t3'],
    'aug_party_identity__age_days_component': ['t4'],
    'aug_party_identity__age_months_component': ['t4']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_bk',
    target_sat='sat_aug_party_identity'
) }}
