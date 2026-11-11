{{ config(materialized='view') }}
-- This part feeds LNK_POLICY_ENDORSEMENT only. Original precedence comments are kept below (from stitch_v23_policy).
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
-- depends_on: {{ ref('stg_health__bjaz_pmjay_prmbook_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_pmjay_prmbook_dtls',
      'alias': 't0',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMJAY_PRMBOOK_DTLS',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_endorsement_lk',
    target_sat='lnk_policy_endorsement'
) }}
