{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_STATUS_TRANSITION only. Original precedence comments are kept below (from stitch_v34_risk_object).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_claim_tracker') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_claim_tracker',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_CLAIM_TRACKER',
      'columns': [
        {'src': 'version_no', 'tgt': 'aug_claim_status_transition__claim_record_version_number'},
        {'src': 'prev_claim_status', 'tgt': 'aug_claim_status_transition__previous_claim_status_code'},
        {'src': 'updated_by', 'tgt': 'aug_claim_status_transition__transition_actor_user_reference'},
        {'src': 'process_name', 'tgt': 'aug_claim_status_transition__workflow_process_name'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_claim_status_transition__claim_record_version_number',
    'aug_claim_status_transition__previous_claim_status_code',
    'aug_claim_status_transition__transition_actor_user_reference',
    'aug_claim_status_transition__workflow_process_name'
] -%}
{%- set coalesce_rules = {
    'aug_claim_status_transition__claim_record_version_number': ['t0'],
    'aug_claim_status_transition__previous_claim_status_code': ['t0'],
    'aug_claim_status_transition__transition_actor_user_reference': ['t0'],
    'aug_claim_status_transition__workflow_process_name': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_aug_claim_status_transition'
) }}
