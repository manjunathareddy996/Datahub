{{ config(materialized='view') }}
-- This part feeds SAT_LNK_ROLE_TPA only. Original precedence comments are kept below (from stitch_v11_claim).
-- CENTRAL VIEW v11_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PP_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_EHH_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GENERIC_LOADER_LOG_TABLE (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_SETTLEMENT
--   SAT_AUG_FINTXN_CLAIM_PAYMENT
--   SAT_AUG_PARTY_BANKING
--   SAT_AUG_PROVIDER_BANKING
--   SAT_CLAIM_COMMUNICATION
--   SAT_CLAIM_DISBURSEMENT_BATCH
--   SAT_CLAIM_FNOL
--   SAT_COMMON_ADDRESS
--   SAT_COMMON_GEO
--   SAT_FINTXN_CLAIM_PAYMENT
--   SAT_LNK_ROLE_TPA
--   SAT_LOSS_EVENT_DETAIL
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_AGREEMENT_CHANNEL
--   LNK_AGREEMENT_PARTY
--   LNK_CHANNEL_ORG_UNIT
--   LNK_CLAIM_DOCUMENT
--   LNK_CLAIM_LOCATION
--   LNK_CLAIM_LOSS_EVENT
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_PAYMENT_INSTRUMENT
--   LNK_CLAIM_POLICY
--   LNK_FINTXN_CLAIM
--   LNK_FINTXN_INSTRUMENT
--   LNK_FINTXN_PARTY
--   LNK_FINTXN_POLICY
--   LNK_LOSS_EVENT_LOCATION
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_DOCUMENT
--   LNK_PARTY_LOCATION
--   LNK_PARTY_ORG_UNIT
--   LNK_PARTY_PAYMENT_INSTRUMENT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_DOCUMENT
--   LNK_POLICY_LOCATION
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PAYMENT_INSTRUMENT
--   LNK_POLICY_PRODUCT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't0',
      'key_column': 'customer_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'tpa_id', 'tgt': 'lnk_role_tpa__tpa_code'},
        {'src': "'TPA'", 'tgt': 'lnk_role_tpa__role_type_ck'}
      ]
    }
] -%}
{%- set output_columns = [
    'lnk_role_tpa__tpa_code',
    'lnk_role_tpa__role_type_ck'
] -%}
{%- set coalesce_rules = {
    'lnk_role_tpa__tpa_code': ['t0'],
    'lnk_role_tpa__role_type_ck': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_bk',
    target_sat='sat_lnk_role_tpa'
) }}
