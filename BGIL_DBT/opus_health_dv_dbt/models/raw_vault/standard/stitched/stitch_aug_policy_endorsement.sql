{{ config(materialized='view') }}
-- This part feeds SAT_AUG_POLICY_ENDORSEMENT only. Original precedence comments are kept below (from stitch_v23_policy).
-- CENTRAL VIEW v23_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HAT_POL_EMP_MAP (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_POLICY_USERMAPPING (opus_health_legacy_v4)
--   BJAZ_PMJAY_PRMBOOK_DTLS (opus_health_legacy_v4)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_POLICY_SUMMARY (opus_health_delta3)
--   BJAZ_VERSIONS_EXTN (opus_health_delta3)
--   OCP_INTERESTED_PARTIES (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_COMMON_BUSINESS_AUDIT
--   SAT_AUG_LNK_POLICY_PARTY_ROLE
--   SAT_AUG_PARTY_HIERARCHY
--   SAT_AUG_POLICY_ENDORSEMENT
--   SAT_AUG_POLICY_INTERMEDIARY_SPLIT
--   SAT_COMMON_COMMUNICATION_PREFERENCE
--   SAT_COMMON_LIFECYCLE
--   SAT_LNK_POLICY_PARTY_ROLE
--   SAT_PARTY_DIGITAL_IDENTITY
--   SAT_POLICY_ENDORSEMENT
--   SAT_POLICY_EXTERNAL_TP_LINK
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_FINTXN_POLICY
--   LNK_PARTY_LOCATION
--   LNK_POLICY_ENDORSEMENT
--   LNK_POLICY_LOCATION
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_versions_extn') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't0',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': 'endorse_brokerage_amt', 'tgt': 'aug_policy_endorsement__brokerage_on_endorsement'},
        {'src': 'endorse_main_agt_comm', 'tgt': 'aug_policy_endorsement__main_agent_commission_on_endorsement'},
        {'src': 'endorse_main_agt_sc', 'tgt': 'aug_policy_endorsement__main_agent_service_charge_on_endorsement'},
        {'src': 'endorse_ser_tax', 'tgt': 'aug_policy_endorsement__service_tax_on_endorsement'},
        {'src': 'endorse_spl_disc_amt', 'tgt': 'aug_policy_endorsement__special_discount_on_endorsement'},
        {'src': 'endorse_sub_agt_sc', 'tgt': 'aug_policy_endorsement__sub_agent_service_charge_on_endorsement'}
      ]
    },
    {
      'model': 'stg_health__bjaz_versions_extn',
      'alias': 't1',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_VERSIONS_EXTN',
      'columns': [
        {'src': 'endorse_due_to', 'tgt': 'aug_policy_endorsement__endorsement_raised_due_to_code'},
        {'src': 'endorse_wording', 'tgt': 'aug_policy_endorsement__endorsement_wording_text'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_policy_endorsement__brokerage_on_endorsement',
    'aug_policy_endorsement__main_agent_commission_on_endorsement',
    'aug_policy_endorsement__main_agent_service_charge_on_endorsement',
    'aug_policy_endorsement__service_tax_on_endorsement',
    'aug_policy_endorsement__special_discount_on_endorsement',
    'aug_policy_endorsement__sub_agent_service_charge_on_endorsement',
    'aug_policy_endorsement__endorsement_raised_due_to_code',
    'aug_policy_endorsement__endorsement_wording_text'
] -%}
{%- set coalesce_rules = {
    'aug_policy_endorsement__brokerage_on_endorsement': ['t0'],
    'aug_policy_endorsement__main_agent_commission_on_endorsement': ['t0'],
    'aug_policy_endorsement__main_agent_service_charge_on_endorsement': ['t0'],
    'aug_policy_endorsement__service_tax_on_endorsement': ['t0'],
    'aug_policy_endorsement__special_discount_on_endorsement': ['t0'],
    'aug_policy_endorsement__sub_agent_service_charge_on_endorsement': ['t0'],
    'aug_policy_endorsement__endorsement_raised_due_to_code': ['t1'],
    'aug_policy_endorsement__endorsement_wording_text': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_aug_policy_endorsement'
) }}
