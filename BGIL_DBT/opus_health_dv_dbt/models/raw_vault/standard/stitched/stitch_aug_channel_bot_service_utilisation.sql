{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CHANNEL_BOT_SERVICE_UTILISATION only. Original precedence comments are kept below (from stitch_v13_financial_account).
-- CENTRAL VIEW v13_financial_account -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_EHH_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GP_HOSPITAL_CASH (opus_health_legacy_v4)
--   BJAZ_HDFC_SEC_FHPP (opus_health_legacy_v4)
--   BJAZ_BOT_UTILIZATION_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ACCOUNT_BALANCE
--   SAT_ACCOUNT_DEFINITION
--   SAT_AUG_ACCOUNT_BALANCE
--   SAT_AUG_ACCOUNT_DEFINITION
--   SAT_AUG_CHANNEL_BOT_SERVICE_UTILISATION
--   SAT_AUG_CHANNEL_DEFINITION
--   SAT_CHANNEL_DEFINITION
--   SAT_POLICY_TENURE_SCHEDULE
--   SAT_RISK_OBJECT_CORE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_ASSESSMENT_PARTY
--   LNK_CHANNEL_ORG_UNIT
--   LNK_CLAIM_ASSESSMENT
--   LNK_CLAIM_LOCATION
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_POLICY
--   LNK_ORG_UNIT_LOCATION
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_LOCATION
--   LNK_PARTY_ORG_UNIT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_LOCATION
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PROPOSAL_PARTY
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_PRODUCT
--   LNK_RISK_OBJECT_ASSESSMENT
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_bot_utilization_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_bot_utilization_dtls',
      'alias': 't0',
      'key_column': "nullif('CHATBOT:' || nullif(trim(chatbot_id),''), 'CHATBOT:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BOT_UTILIZATION_DTLS',
      'columns': [
        {'src': 'service_name', 'tgt': 'aug_channel_bot_service_utilisation__bot_service_name'},
        {'src': 'prev_reference_no', 'tgt': 'aug_channel_bot_service_utilisation__previous_session_business_reference'},
        {'src': 'request_type', 'tgt': 'aug_channel_bot_service_utilisation__request_type'},
        {'src': 'service_hit_cnt', 'tgt': 'aug_channel_bot_service_utilisation__service_invocation_count'},
        {'src': 'reference_no', 'tgt': 'aug_channel_bot_service_utilisation__session_business_reference'},
        {'src': 'date_generated', 'tgt': 'aug_channel_bot_service_utilisation__utilisation_record_date'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_channel_bot_service_utilisation__bot_service_name',
    'aug_channel_bot_service_utilisation__previous_session_business_reference',
    'aug_channel_bot_service_utilisation__request_type',
    'aug_channel_bot_service_utilisation__service_invocation_count',
    'aug_channel_bot_service_utilisation__session_business_reference',
    'aug_channel_bot_service_utilisation__utilisation_record_date'
] -%}
{%- set coalesce_rules = {
    'aug_channel_bot_service_utilisation__bot_service_name': ['t0'],
    'aug_channel_bot_service_utilisation__previous_session_business_reference': ['t0'],
    'aug_channel_bot_service_utilisation__request_type': ['t0'],
    'aug_channel_bot_service_utilisation__service_invocation_count': ['t0'],
    'aug_channel_bot_service_utilisation__session_business_reference': ['t0'],
    'aug_channel_bot_service_utilisation__utilisation_record_date': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='distribution_channel_bk',
    target_sat='sat_aug_channel_bot_service_utilisation'
) }}
