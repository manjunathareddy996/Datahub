{{ config(materialized='view') }}
-- This part feeds SAT_RISK_PERSON_MEMBER only. Original precedence comments are kept below (from stitch_v03_assessment).
-- CENTRAL VIEW v03_assessment -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PP_MEM_DTLS (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_HM_DOCTOR_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_DOCTOR_MULTI_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_PCS_MULTI_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
--   BJAZ_RISK_IDENTIFIERS_MASTER (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_MEDICAL
--   SAT_AUG_ASSESSMENT_HEADER
--   SAT_AUG_ASSESSMENT_MEDICAL
--   SAT_AUG_ASSESSMENT_RISK_RULE_DEFINITION
--   SAT_RISK_PERSON_MEMBER
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_ASSESSMENT_PARTY
--   LNK_CHANNEL_ORG_UNIT
--   LNK_CLAIM_ASSESSMENT
--   LNK_CLAIM_COVERAGE
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_ORG_UNIT
--   LNK_PARTY_ROLE
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PROPOSAL_ASSESSMENT
--   LNK_PROPOSAL_PARTY
--   LNK_PROPOSAL_POLICY
--   LNK_RISK_OBJECT_ASSESSMENT
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), ''))) || '|' || coalesce(md_seq_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': "nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'md_seq_no', 'tgt': 'risk_person_member__member_sequence_ck'},
        {'src': 'md_relation', 'tgt': 'risk_person_member__relationship_to_proposer'}
      ]
    }
] -%}
{%- set output_columns = [
    'risk_object_bk',
    'risk_person_member__member_sequence_ck',
    'risk_person_member__relationship_to_proposer'
] -%}
{%- set coalesce_rules = {
    'risk_object_bk': ['t0'],
    'risk_person_member__member_sequence_ck': ['t0'],
    'risk_person_member__relationship_to_proposer': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='risk_person_member_pk',
    target_sat='sat_risk_person_member'
) }}
