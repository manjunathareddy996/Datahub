{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_PROCESS_STEP_LOG only. Original precedence comments are kept below (from stitch_v09_claim).
-- CENTRAL VIEW v09_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_USER_TAT (opus_health_v2)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_ECARD_MEMBR_DEL_DTLS (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_CO_RI_SHARE
--   SAT_AUG_CLAIM_PROCESS_STEP_LOG
--   SAT_AUG_PARTY_CLAIM_HISTORY
--   SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS
--   SAT_AUG_POLICY_CERTIFICATE
--   SAT_CLAIM_CO_RI_SHARE
--   SAT_CLAIM_RESERVE
--   SAT_DOCUMENT_CHECKLIST
--   SAT_INSTRUMENT_DEFINITION
--   SAT_LOCATION_PROFILE
--   SAT_PARTY_GROUP_CENSUS
--   SAT_PARTY_GROUP_SCHEME
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_AGREEMENT_DOCUMENT
--   LNK_AGREEMENT_PARTY
--   LNK_CLAIM_DOCUMENT
--   LNK_CLAIM_LOCATION
--   LNK_CLAIM_LOSS_EVENT
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_PAYMENT_INSTRUMENT
--   LNK_CLAIM_POLICY
--   LNK_FINTXN_ACCOUNT
--   LNK_FINTXN_CLAIM
--   LNK_FINTXN_INSTRUMENT
--   LNK_FINTXN_PARTY
--   LNK_FINTXN_POLICY
--   LNK_LOSS_EVENT_LOCATION
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_DOCUMENT
--   LNK_PARTY_LOCATION
--   LNK_PARTY_PAYMENT_INSTRUMENT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_DOCUMENT
--   LNK_POLICY_LOCATION
--   LNK_POLICY_PARTY
--   LNK_POLICY_PAYMENT_INSTRUMENT
--   LNK_POLICY_PRODUCT
--   LNK_QUOTE_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_user_tat') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_user_tat',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_USER_TAT',
      'columns': [
        {'src': 'log_type', 'tgt': 'aug_claim_process_step_log__log_type_code'},
        {'src': 'next_case', 'tgt': 'aug_claim_process_step_log__next_case_reference'},
        {'src': 'log_id', 'tgt': 'aug_claim_process_step_log__process_log_reference'},
        {'src': 'process_type', 'tgt': 'aug_claim_process_step_log__process_type_code'},
        {'src': 'updated_by', 'tgt': 'aug_claim_process_step_log__step_actor_user_reference'},
        {'src': 'actual_start_on', 'tgt': 'aug_claim_process_step_log__step_actual_start_timestamp'},
        {'src': 'end_on', 'tgt': 'aug_claim_process_step_log__step_end_timestamp'},
        {'src': 'coalesce(start_on, updated_on)', 'tgt': 'aug_claim_process_step_log__step_start_timestamp'},
        {'src': 'status_type', 'tgt': 'aug_claim_process_step_log__step_status_code'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_claim_process_step_log__log_type_code',
    'aug_claim_process_step_log__next_case_reference',
    'aug_claim_process_step_log__process_log_reference',
    'aug_claim_process_step_log__process_type_code',
    'aug_claim_process_step_log__step_actor_user_reference',
    'aug_claim_process_step_log__step_actual_start_timestamp',
    'aug_claim_process_step_log__step_end_timestamp',
    'aug_claim_process_step_log__step_start_timestamp',
    'aug_claim_process_step_log__step_status_code'
] -%}
{%- set coalesce_rules = {
    'aug_claim_process_step_log__log_type_code': ['t0'],
    'aug_claim_process_step_log__next_case_reference': ['t0'],
    'aug_claim_process_step_log__process_log_reference': ['t0'],
    'aug_claim_process_step_log__process_type_code': ['t0'],
    'aug_claim_process_step_log__step_actor_user_reference': ['t0'],
    'aug_claim_process_step_log__step_actual_start_timestamp': ['t0'],
    'aug_claim_process_step_log__step_end_timestamp': ['t0'],
    'aug_claim_process_step_log__step_start_timestamp': ['t0'],
    'aug_claim_process_step_log__step_status_code': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_aug_claim_process_step_log'
) }}
