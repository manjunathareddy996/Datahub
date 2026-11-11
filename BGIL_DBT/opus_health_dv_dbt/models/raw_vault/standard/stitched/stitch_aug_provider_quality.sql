{{ config(materialized='view') }}
-- This part feeds SAT_AUG_PROVIDER_QUALITY only. Original precedence comments are kept below (from stitch_v15_party).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_summary') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't0',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'special_remarks', 'tgt': 'aug_provider_quality__provider_remarks'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hosp_master_extn1',
      'alias': 't1',
      'key_column': 'hosid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSP_MASTER_EXTN1',
      'columns': [
        {'src': 'avg_admsion_time', 'tgt': 'aug_provider_quality__average_admission_time'},
        {'src': 'avg_dscrg_time', 'tgt': 'aug_provider_quality__average_discharge_time'},
        {'src': 'avg_sty_medi_case', 'tgt': 'aug_provider_quality__average_length_of_stay_medical'},
        {'src': 'avg_sty_surgcl_case', 'tgt': 'aug_provider_quality__average_length_of_stay_surgical'},
        {'src': 'bedoccuprate', 'tgt': 'aug_provider_quality__bed_occupancy_rate'},
        {'src': 'c_section_rate', 'tgt': 'aug_provider_quality__caesarean_section_rate'},
        {'src': 'doct_bed_ratio', 'tgt': 'aug_provider_quality__doctor_to_bed_ratio'},
        {'src': 'coalesce(doct_patnt_ratio, dtopratio)', 'tgt': 'aug_provider_quality__doctor_to_patient_ratio'},
        {'src': 'nurse_bed_ratio', 'tgt': 'aug_provider_quality__nurse_to_bed_ratio'},
        {'src': 'nurse_ptnt_ratio', 'tgt': 'aug_provider_quality__nurse_to_patient_ratio'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't2',
      'key_column': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': 'configured_date', 'tgt': 'aug_provider_quality__provider_configured_date'},
        {'src': 'flag', 'tgt': 'aug_provider_quality__provider_record_flag'},
        {'src': 'updated_by', 'tgt': 'aug_provider_quality__provider_record_last_updated_by_user_reference'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_provider_quality__provider_remarks',
    'aug_provider_quality__average_admission_time',
    'aug_provider_quality__average_discharge_time',
    'aug_provider_quality__average_length_of_stay_medical',
    'aug_provider_quality__average_length_of_stay_surgical',
    'aug_provider_quality__bed_occupancy_rate',
    'aug_provider_quality__caesarean_section_rate',
    'aug_provider_quality__doctor_to_bed_ratio',
    'aug_provider_quality__doctor_to_patient_ratio',
    'aug_provider_quality__nurse_to_bed_ratio',
    'aug_provider_quality__nurse_to_patient_ratio',
    'aug_provider_quality__provider_configured_date',
    'aug_provider_quality__provider_record_flag',
    'aug_provider_quality__provider_record_last_updated_by_user_reference'
] -%}
{%- set coalesce_rules = {
    'aug_provider_quality__provider_remarks': ['t0'],
    'aug_provider_quality__average_admission_time': ['t1'],
    'aug_provider_quality__average_discharge_time': ['t1'],
    'aug_provider_quality__average_length_of_stay_medical': ['t1'],
    'aug_provider_quality__average_length_of_stay_surgical': ['t1'],
    'aug_provider_quality__bed_occupancy_rate': ['t1'],
    'aug_provider_quality__caesarean_section_rate': ['t1'],
    'aug_provider_quality__doctor_to_bed_ratio': ['t1'],
    'aug_provider_quality__doctor_to_patient_ratio': ['t1'],
    'aug_provider_quality__nurse_to_bed_ratio': ['t1'],
    'aug_provider_quality__nurse_to_patient_ratio': ['t1'],
    'aug_provider_quality__provider_configured_date': ['t2'],
    'aug_provider_quality__provider_record_flag': ['t2'],
    'aug_provider_quality__provider_record_last_updated_by_user_reference': ['t2']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_bk',
    target_sat='sat_aug_provider_quality'
) }}
