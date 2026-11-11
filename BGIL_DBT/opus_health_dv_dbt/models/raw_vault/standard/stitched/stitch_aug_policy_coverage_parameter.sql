{{ config(materialized='view') }}
-- This part feeds SAT_AUG_POLICY_COVERAGE_PARAMETER only. Original precedence comments are kept below (from stitch_v24_policy).
-- CENTRAL VIEW v24_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_BASES_EXTN (opus_health_v2)
--   BJAZ_CTNGY_COVERS_EXT (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_PORT_WORDINGS (opus_health_legacy_v4)
--   BJAZ_ECARD_POL_DTLS_CONFIG (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BA_CCP_INSURED_DETAILS (opus_health_delta3)
--   BA_CCP_SUB_MATER_DTLS (opus_health_delta3)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_GRP_HLT_COVERAGE_DTLS (opus_health_delta3)
--   BJAZ_GRP_HLT_MEM_DTLS (opus_health_delta3)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_POLICY_SUMMARY (opus_health_delta3)
--   BJAZ_STARPKG_COVER_DTLS (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
--   BJAZ_VERSIONS_EXTN (opus_health_delta3)
--   OCP_INTERESTED_PARTIES (opus_health_delta3)
--   OCP_POLICY_COVERS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_COINSURANCE
--   SAT_AUG_POLICY_COVERAGE_PARAMETER
--   SAT_AUG_POLICY_GROUP_RELATION_ELIGIBILITY
--   SAT_AUG_POLICY_HEADER
--   SAT_AUG_POLICY_LIFECYCLE
--   SAT_AUG_POLICY_TAX_BREAKUP
--   SAT_COMMON_BUSINESS_AUDIT
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_PRODUCT
--   LNK_PRODUCT_COVERAGE
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_ctngy_bases_extn') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_bases_extn',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(param_ref, '~') || '|' || coalesce(plan_id, '~') || '|' || coalesce(section_id, '~') || '|' || coalesce(cvr_code, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'param_ref', 'tgt': 'aug_policy_coverage_parameter__parameter_reference_ck'},
        {'src': 'plan_id', 'tgt': 'aug_policy_coverage_parameter__plan_reference_ck'},
        {'src': 'section_id', 'tgt': 'aug_policy_coverage_parameter__section_reference_ck'},
        {'src': 'cvr_code', 'tgt': 'aug_policy_coverage_parameter__coverage_reference_ck'},
        {'src': 'param_id', 'tgt': 'aug_policy_coverage_parameter__parameter_definition_reference'},
        {'src': 'param_ref', 'tgt': 'aug_policy_coverage_parameter__parameter_reference'},
        {'src': 'param_val', 'tgt': 'aug_policy_coverage_parameter__parameter_value'},
        {'src': 'plan_id', 'tgt': 'aug_policy_coverage_parameter__plan_reference'},
        {'src': 'section_id', 'tgt': 'aug_policy_coverage_parameter__section_reference'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'aug_policy_coverage_parameter__parameter_reference_ck',
    'aug_policy_coverage_parameter__plan_reference_ck',
    'aug_policy_coverage_parameter__section_reference_ck',
    'aug_policy_coverage_parameter__coverage_reference_ck',
    'aug_policy_coverage_parameter__parameter_definition_reference',
    'aug_policy_coverage_parameter__parameter_reference',
    'aug_policy_coverage_parameter__parameter_value',
    'aug_policy_coverage_parameter__plan_reference',
    'aug_policy_coverage_parameter__section_reference'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0'],
    'aug_policy_coverage_parameter__parameter_reference_ck': ['t0'],
    'aug_policy_coverage_parameter__plan_reference_ck': ['t0'],
    'aug_policy_coverage_parameter__section_reference_ck': ['t0'],
    'aug_policy_coverage_parameter__coverage_reference_ck': ['t0'],
    'aug_policy_coverage_parameter__parameter_definition_reference': ['t0'],
    'aug_policy_coverage_parameter__parameter_reference': ['t0'],
    'aug_policy_coverage_parameter__parameter_value': ['t0'],
    'aug_policy_coverage_parameter__plan_reference': ['t0'],
    'aug_policy_coverage_parameter__section_reference': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='aug_policy_coverage_parameter_pk',
    target_sat='sat_aug_policy_coverage_parameter'
) }}
