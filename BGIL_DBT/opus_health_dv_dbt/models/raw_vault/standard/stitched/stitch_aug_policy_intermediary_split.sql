{{ config(materialized='view') }}
-- This part feeds SAT_AUG_POLICY_INTERMEDIARY_SPLIT only. Original precedence comments are kept below (from stitch_v23_policy).
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
-- depends_on: {{ ref('stg_health__bjaz_policy_summary') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't0',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': 'brokerage_amt', 'tgt': 'aug_policy_intermediary_split__brokerage_amount'},
        {'src': 'dealer_code', 'tgt': 'aug_policy_intermediary_split__dealer_code'},
        {'src': 'main_agent_sc_amt', 'tgt': 'aug_policy_intermediary_split__service_charge_amount'},
        {'src': 'main_agent_sc_rate', 'tgt': 'aug_policy_intermediary_split__service_charge_rate'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't1',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': 'dealer_code', 'tgt': 'aug_policy_intermediary_split__dealer_code'},
        {'src': 'main_agent_sc_amt', 'tgt': 'aug_policy_intermediary_split__service_charge_amount'},
        {'src': 'main_agent_sc_rate', 'tgt': 'aug_policy_intermediary_split__service_charge_rate'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_policy_intermediary_split__brokerage_amount',
    'aug_policy_intermediary_split__dealer_code',
    'aug_policy_intermediary_split__service_charge_amount',
    'aug_policy_intermediary_split__service_charge_rate'
] -%}
{%- set coalesce_rules = {
    'aug_policy_intermediary_split__brokerage_amount': ['t0'],
    'aug_policy_intermediary_split__dealer_code': ['t0', 't1'],
    'aug_policy_intermediary_split__service_charge_amount': ['t0', 't1'],
    'aug_policy_intermediary_split__service_charge_rate': ['t0', 't1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_aug_policy_intermediary_split'
) }}
