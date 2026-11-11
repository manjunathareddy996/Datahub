{{ config(materialized='view') }}
-- This part feeds SAT_AUG_RISK_HEALTH_MEMBER_MEDICAL only. Original precedence comments are kept below (from stitch_v34_risk_object).
-- CENTRAL VIEW v34_risk_object -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_CLAIM_TRACKER (opus_health_v2)
--   BJAZ_HM_HCS_TECH_ASSESS_COV (opus_health_v2)
--   BJAZ_HM_MEMBER_HLTH_DTLS (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_REMEDINET_PATIENT_DETAILS (opus_health_delta3)
--   BJAZ_RISK_TRANS_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CHANNEL_DIGITAL_INTEGRATION
--   SAT_AUG_CLAIM_STATUS_TRANSITION
--   SAT_AUG_RISK_HEALTH_MEMBER_MEDICAL
--   SAT_AUG_RISK_PERSON_INSURED
--   SAT_CLAIM_SLA_TRACKING
--   SAT_LNK_ROLE_BANCASSURANCE
--   SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
--   SAT_POLICY_PREMIUM_SETTLEMENT
--   SAT_RISK_HEALTH_MEMBER_COVERAGE
--   SAT_RISK_HEALTH_MEMBER_MEDICAL
--   SAT_RISK_PERSON_INSURED
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_RISK_OBJECT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_member_hlth_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#'))) || '|' || coalesce(member_id, '~') || '|' || 'DECLARED_OTHER'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': "nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#')", 'tgt': 'risk_object_bk'},
        {'src': 'member_id', 'tgt': 'aug_risk_health_member_medical__member_reference_ck'},
        {'src': "'DECLARED_OTHER'", 'tgt': 'aug_risk_health_member_medical__condition_code_ck'},
        {'src': 'sh_comments', 'tgt': 'aug_risk_health_member_medical__declared_health_remarks'},
        {'src': 'sh_period_of_insurance', 'tgt': 'aug_risk_health_member_medical__declared_insurance_period'},
        {'src': 'remark_center', 'tgt': 'aug_risk_health_member_medical__diagnostic_centre_remarks'},
        {'src': 'hc_prescription_details', 'tgt': 'aug_risk_health_member_medical__prescription_detail'},
        {'src': 'hc_prescription_yn', 'tgt': 'aug_risk_health_member_medical__prescription_submitted_indicator'},
        {'src': 'sh_doctor_name', 'tgt': 'aug_risk_health_member_medical__treating_doctor_name'},
        {'src': 'sh_period_treatment', 'tgt': 'aug_risk_health_member_medical__treatment_period'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'aug_risk_health_member_medical__member_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'aug_risk_health_member_medical__condition_code_ck'},
        {'src': 'fmly_hlth_complains', 'tgt': 'aug_risk_health_member_medical__family_medical_history_detail'},
        {'src': 'pregnant_months', 'tgt': 'aug_risk_health_member_medical__gestation_months'},
        {'src': 'illness_duration', 'tgt': 'aug_risk_health_member_medical__illness_duration'},
        {'src': 'coalesce(past_4yr_treatment, prior_4yr_treatment)', 'tgt': 'aug_risk_health_member_medical__treatment_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'aug_risk_health_member_medical__member_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'aug_risk_health_member_medical__condition_code_ck'},
        {'src': 'decease_treatment_dtls', 'tgt': 'aug_risk_health_member_medical__treatment_details_narrative'}
      ]
    }
] -%}
{%- set output_columns = [
    'risk_object_bk',
    'aug_risk_health_member_medical__member_reference_ck',
    'aug_risk_health_member_medical__condition_code_ck',
    'aug_risk_health_member_medical__declared_health_remarks',
    'aug_risk_health_member_medical__declared_insurance_period',
    'aug_risk_health_member_medical__diagnostic_centre_remarks',
    'aug_risk_health_member_medical__prescription_detail',
    'aug_risk_health_member_medical__prescription_submitted_indicator',
    'aug_risk_health_member_medical__treating_doctor_name',
    'aug_risk_health_member_medical__treatment_period',
    'aug_risk_health_member_medical__family_medical_history_detail',
    'aug_risk_health_member_medical__gestation_months',
    'aug_risk_health_member_medical__illness_duration',
    'aug_risk_health_member_medical__treatment_description',
    'aug_risk_health_member_medical__treatment_details_narrative'
] -%}
{%- set coalesce_rules = {
    'risk_object_bk': ['t0', 't1', 't2'],
    'aug_risk_health_member_medical__member_reference_ck': ['t0', 't1', 't2'],
    'aug_risk_health_member_medical__condition_code_ck': ['t0', 't1', 't2'],
    'aug_risk_health_member_medical__declared_health_remarks': ['t0'],
    'aug_risk_health_member_medical__declared_insurance_period': ['t0'],
    'aug_risk_health_member_medical__diagnostic_centre_remarks': ['t0'],
    'aug_risk_health_member_medical__prescription_detail': ['t0'],
    'aug_risk_health_member_medical__prescription_submitted_indicator': ['t0'],
    'aug_risk_health_member_medical__treating_doctor_name': ['t0'],
    'aug_risk_health_member_medical__treatment_period': ['t0'],
    'aug_risk_health_member_medical__family_medical_history_detail': ['t1'],
    'aug_risk_health_member_medical__gestation_months': ['t1'],
    'aug_risk_health_member_medical__illness_duration': ['t1'],
    'aug_risk_health_member_medical__treatment_description': ['t1'],
    'aug_risk_health_member_medical__treatment_details_narrative': ['t2']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='aug_risk_health_member_medical_pk',
    target_sat='sat_aug_risk_health_member_medical'
) }}
