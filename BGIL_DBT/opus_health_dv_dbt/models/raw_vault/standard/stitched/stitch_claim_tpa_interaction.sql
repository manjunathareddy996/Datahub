{{ config(materialized='view') }}
-- This part feeds SAT_CLAIM_TPA_INTERACTION only. Original precedence comments are kept below (from stitch_v10_claim).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_claim_details') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_preauth_request',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_REQUEST',
      'columns': [
        {'src': 'preaut_amt', 'tgt': 'claim_tpa_interaction__pre_auth_amount'},
        {'src': 'inserted_date', 'tgt': 'claim_tpa_interaction__pre_auth_request_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_cashless_inward',
      'alias': 't1',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_CASHLESS_INWARD',
      'columns': [
        {'src': 'inward_remark', 'tgt': 'claim_tpa_interaction__authorisation_remarks'},
        {'src': 'cashless_in_date', 'tgt': 'claim_tpa_interaction__pre_auth_request_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't2',
      'key_column': 'clid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'preauth_exclause', 'tgt': 'claim_tpa_interaction__authorisation_message'},
        {'src': 'authorization_remarks', 'tgt': 'claim_tpa_interaction__authorisation_remarks'},
        {'src': 'denial_reason', 'tgt': 'claim_tpa_interaction__denial_reason'},
        {'src': 'auth_amount', 'tgt': 'claim_tpa_interaction__final_authorisation_amount'},
        {'src': 'pre_auth_amt', 'tgt': 'claim_tpa_interaction__pre_auth_amount'},
        {'src': 'auth_date', 'tgt': 'claim_tpa_interaction__pre_auth_approved_date'},
        {'src': 'pre_auth_date', 'tgt': 'claim_tpa_interaction__pre_auth_request_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_preauth_enhance',
      'alias': 't3',
      'key_column': 'clid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_ENHANCE',
      'columns': [
        {'src': 'enhance_request', 'tgt': 'claim_tpa_interaction__enhancement_amount'},
        {'src': 'trans_amount', 'tgt': 'claim_tpa_interaction__final_authorisation_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_claim_details',
      'alias': 't4',
      'key_column': 'claim_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_CLAIM_DETAILS',
      'columns': [
        {'src': 'payer_remarks', 'tgt': 'claim_tpa_interaction__authorisation_remarks'},
        {'src': 'claimed_package_amount', 'tgt': 'claim_tpa_interaction__claimed_package_amount'},
        {'src': 'approved_date', 'tgt': 'claim_tpa_interaction__pre_auth_approved_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't5',
      'key_column': 'bjaz_claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'date_of_doc_rec', 'tgt': 'claim_tpa_interaction__bill_submission_date'},
        {'src': 'pre_auth_approved_on', 'tgt': 'claim_tpa_interaction__pre_auth_approved_date'},
        {'src': 'pre_auth_received_on', 'tgt': 'claim_tpa_interaction__pre_auth_request_date'},
        {'src': 'tpa_claim_no', 'tgt': 'claim_tpa_interaction__tpa_reference'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_tpa_interaction__pre_auth_amount',
    'claim_tpa_interaction__pre_auth_request_date',
    'claim_tpa_interaction__authorisation_remarks',
    'claim_tpa_interaction__authorisation_message',
    'claim_tpa_interaction__denial_reason',
    'claim_tpa_interaction__final_authorisation_amount',
    'claim_tpa_interaction__pre_auth_approved_date',
    'claim_tpa_interaction__enhancement_amount',
    'claim_tpa_interaction__claimed_package_amount',
    'claim_tpa_interaction__bill_submission_date',
    'claim_tpa_interaction__tpa_reference'
] -%}
{%- set coalesce_rules = {
    'claim_tpa_interaction__pre_auth_amount': ['t0', 't2'],
    'claim_tpa_interaction__pre_auth_request_date': ['t0', 't1', 't2', 't5'],
    'claim_tpa_interaction__authorisation_remarks': ['t1', 't2', 't4'],
    'claim_tpa_interaction__authorisation_message': ['t2'],
    'claim_tpa_interaction__denial_reason': ['t2'],
    'claim_tpa_interaction__final_authorisation_amount': ['t2', 't3'],
    'claim_tpa_interaction__pre_auth_approved_date': ['t2', 't4', 't5'],
    'claim_tpa_interaction__enhancement_amount': ['t3'],
    'claim_tpa_interaction__claimed_package_amount': ['t4'],
    'claim_tpa_interaction__bill_submission_date': ['t5'],
    'claim_tpa_interaction__tpa_reference': ['t5']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_claim_tpa_interaction'
) }}
