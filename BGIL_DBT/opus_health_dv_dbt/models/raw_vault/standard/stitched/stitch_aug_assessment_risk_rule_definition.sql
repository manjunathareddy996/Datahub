{{ config(materialized='view') }}
-- This part feeds SAT_AUG_ASSESSMENT_RISK_RULE_DEFINITION only. Original precedence comments are kept below (from stitch_v03_assessment).
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
-- depends_on: {{ ref('stg_health__bjaz_risk_identifiers_master') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_risk_identifiers_master',
      'alias': 't0',
      'key_column': "nullif('RISKRULE:' || nullif(trim(risk_id),''), 'RISKRULE:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_RISK_IDENTIFIERS_MASTER',
      'columns': [
        {'src': 'category_code', 'tgt': 'aug_assessment_risk_rule_definition__risk_category_code'},
        {'src': 'risk_identifier', 'tgt': 'aug_assessment_risk_rule_definition__risk_rule_name'},
        {'src': 'subcategory_code', 'tgt': 'aug_assessment_risk_rule_definition__risk_sub_category_code'},
        {'src': 'risk_score', 'tgt': 'aug_assessment_risk_rule_definition__rule_contribution_score'},
        {'src': 'developed_by', 'tgt': 'aug_assessment_risk_rule_definition__rule_developed_by_user_reference'},
        {'src': 'start_date', 'tgt': 'aug_assessment_risk_rule_definition__rule_effective_from_date'},
        {'src': 'expiry_date', 'tgt': 'aug_assessment_risk_rule_definition__rule_effective_to_date'},
        {'src': 'updated_by', 'tgt': 'aug_assessment_risk_rule_definition__rule_last_maintained_by_user_reference'},
        {'src': 'updated_on', 'tgt': 'aug_assessment_risk_rule_definition__rule_last_maintained_timestamp'},
        {'src': 'module_id', 'tgt': 'aug_assessment_risk_rule_definition__rule_module_identifier'},
        {'src': 'trigger_logic', 'tgt': 'aug_assessment_risk_rule_definition__rule_trigger_expression'},
        {'src': 'trigger_type', 'tgt': 'aug_assessment_risk_rule_definition__rule_trigger_type'},
        {'src': 'version_no', 'tgt': 'aug_assessment_risk_rule_definition__rule_version_number'},
        {'src': 'risk_susp_fraud_desc', 'tgt': 'aug_assessment_risk_rule_definition__suspected_fraud_scenario_description'},
        {'src': 'risk_susp_fraud_id', 'tgt': 'aug_assessment_risk_rule_definition__suspected_fraud_scenario_reference'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_assessment_risk_rule_definition__risk_category_code',
    'aug_assessment_risk_rule_definition__risk_rule_name',
    'aug_assessment_risk_rule_definition__risk_sub_category_code',
    'aug_assessment_risk_rule_definition__rule_contribution_score',
    'aug_assessment_risk_rule_definition__rule_developed_by_user_reference',
    'aug_assessment_risk_rule_definition__rule_effective_from_date',
    'aug_assessment_risk_rule_definition__rule_effective_to_date',
    'aug_assessment_risk_rule_definition__rule_last_maintained_by_user_reference',
    'aug_assessment_risk_rule_definition__rule_last_maintained_timestamp',
    'aug_assessment_risk_rule_definition__rule_module_identifier',
    'aug_assessment_risk_rule_definition__rule_trigger_expression',
    'aug_assessment_risk_rule_definition__rule_trigger_type',
    'aug_assessment_risk_rule_definition__rule_version_number',
    'aug_assessment_risk_rule_definition__suspected_fraud_scenario_description',
    'aug_assessment_risk_rule_definition__suspected_fraud_scenario_reference'
] -%}
{%- set coalesce_rules = {
    'aug_assessment_risk_rule_definition__risk_category_code': ['t0'],
    'aug_assessment_risk_rule_definition__risk_rule_name': ['t0'],
    'aug_assessment_risk_rule_definition__risk_sub_category_code': ['t0'],
    'aug_assessment_risk_rule_definition__rule_contribution_score': ['t0'],
    'aug_assessment_risk_rule_definition__rule_developed_by_user_reference': ['t0'],
    'aug_assessment_risk_rule_definition__rule_effective_from_date': ['t0'],
    'aug_assessment_risk_rule_definition__rule_effective_to_date': ['t0'],
    'aug_assessment_risk_rule_definition__rule_last_maintained_by_user_reference': ['t0'],
    'aug_assessment_risk_rule_definition__rule_last_maintained_timestamp': ['t0'],
    'aug_assessment_risk_rule_definition__rule_module_identifier': ['t0'],
    'aug_assessment_risk_rule_definition__rule_trigger_expression': ['t0'],
    'aug_assessment_risk_rule_definition__rule_trigger_type': ['t0'],
    'aug_assessment_risk_rule_definition__rule_version_number': ['t0'],
    'aug_assessment_risk_rule_definition__suspected_fraud_scenario_description': ['t0'],
    'aug_assessment_risk_rule_definition__suspected_fraud_scenario_reference': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='assessment_bk',
    target_sat='sat_aug_assessment_risk_rule_definition'
) }}
