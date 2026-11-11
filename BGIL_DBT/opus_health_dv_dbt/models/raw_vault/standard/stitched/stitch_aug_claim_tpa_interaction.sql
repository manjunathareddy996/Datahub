{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_TPA_INTERACTION only. Original precedence comments are kept below (from stitch_v10_claim).
-- CENTRAL VIEW v10_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_GPA_BILL_DTLS (opus_health_v2)
--   BJAZ_HM_HCS_TECH_ASSESS_COV (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_HM_BILL_DETAIL (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL_OCR (opus_health_legacy_v4)
--   BJAZ_HM_CASHLESS_INWARD (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_DOCTOR_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_DOCTOR_MULTI_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_AUTOALLOCATION (opus_health_legacy_v4)
--   BJAZ_HM_PREAUTH_ENHANCE (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_REMEDINET_PATIENT_DETAILS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_HEALTH_DETAIL
--   SAT_AUG_CLAIM_TPA_INTERACTION
--   SAT_CLAIM_HEALTH_DETAIL
--   SAT_CLAIM_TPA_INTERACTION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CASE_DOCUMENT
--   LNK_CASE_PARTY
--   LNK_CLAIM_CASE
--   LNK_CLAIM_DOCUMENT
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_POLICY
--   LNK_PARTY_DOCUMENT
--   LNK_POLICY_PARTY
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_preauth_request') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_cashless_inward') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_preauth_request',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_REQUEST',
      'columns': [
        {'src': 'mail_sent_dt', 'tgt': 'aug_claim_tpa_interaction__decision_notification_sent_date'},
        {'src': 'mail_send_flag', 'tgt': 'aug_claim_tpa_interaction__decision_notification_sent_indicator'},
        {'src': 'preauth_opt', 'tgt': 'aug_claim_tpa_interaction__pre_authorisation_option_code'},
        {'src': 'process_type', 'tgt': 'aug_claim_tpa_interaction__pre_authorisation_process_type'},
        {'src': 'valid_flag', 'tgt': 'aug_claim_tpa_interaction__pre_authorisation_request_valid_indicator'},
        {'src': 'hos_ref_id', 'tgt': 'aug_claim_tpa_interaction__provider_pre_authorisation_request_reference'},
        {'src': 'declaration_yn', 'tgt': 'aug_claim_tpa_interaction__request_declaration_accepted_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_cashless_inward',
      'alias': 't1',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_CASHLESS_INWARD',
      'columns': [
        {'src': 'inward_status', 'tgt': 'aug_claim_tpa_interaction__cashless_request_status'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't2',
      'key_column': 'clid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'denial_date', 'tgt': 'aug_claim_tpa_interaction__denial_date'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_claim_tpa_interaction__decision_notification_sent_date',
    'aug_claim_tpa_interaction__decision_notification_sent_indicator',
    'aug_claim_tpa_interaction__pre_authorisation_option_code',
    'aug_claim_tpa_interaction__pre_authorisation_process_type',
    'aug_claim_tpa_interaction__pre_authorisation_request_valid_indicator',
    'aug_claim_tpa_interaction__provider_pre_authorisation_request_reference',
    'aug_claim_tpa_interaction__request_declaration_accepted_indicator',
    'aug_claim_tpa_interaction__cashless_request_status',
    'aug_claim_tpa_interaction__denial_date'
] -%}
{%- set coalesce_rules = {
    'aug_claim_tpa_interaction__decision_notification_sent_date': ['t0'],
    'aug_claim_tpa_interaction__decision_notification_sent_indicator': ['t0'],
    'aug_claim_tpa_interaction__pre_authorisation_option_code': ['t0'],
    'aug_claim_tpa_interaction__pre_authorisation_process_type': ['t0'],
    'aug_claim_tpa_interaction__pre_authorisation_request_valid_indicator': ['t0'],
    'aug_claim_tpa_interaction__provider_pre_authorisation_request_reference': ['t0'],
    'aug_claim_tpa_interaction__request_declaration_accepted_indicator': ['t0'],
    'aug_claim_tpa_interaction__cashless_request_status': ['t1'],
    'aug_claim_tpa_interaction__denial_date': ['t2']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_aug_claim_tpa_interaction'
) }}
