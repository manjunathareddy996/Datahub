{{ config(materialized='view') }}
-- This part feeds SAT_DOCUMENT_CHECKLIST only. Original precedence comments are kept below (from stitch_v09_claim).
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
-- depends_on: {{ ref('stg_health__bjaz_remedinet_claim_details') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_remedinet_claim_details',
      'alias': 't0',
      'key_column': "omni_inward_no || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_CLAIM_DETAILS',
      'columns': [
        {'src': 'omni_inward_no', 'tgt': 'document_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'document_checklist__required_document_type_ck'},
        {'src': 'is_document_received', 'tgt': 'document_checklist__received_indicator'}
      ]
    }
] -%}
{%- set output_columns = [
    'document_bk',
    'document_checklist__required_document_type_ck',
    'document_checklist__received_indicator'
] -%}
{%- set coalesce_rules = {
    'document_bk': ['t0'],
    'document_checklist__required_document_type_ck': ['t0'],
    'document_checklist__received_indicator': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='document_checklist_pk',
    target_sat='sat_document_checklist'
) }}
