{{ config(materialized='view') }}
-- This part feeds SAT_AUG_ORG_UNIT_DEFINITION only. Original precedence comments are kept below (from stitch_v14_org_unit).
-- CENTRAL VIEW v14_org_unit -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_BRANCH_MASTER (opus_health_v2)
--   BA_HCP_DT_PREMIUM (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_ORG_UNIT_CONTACT
--   SAT_AUG_ORG_UNIT_DEFINITION
--   SAT_AUG_PARTY_EMPLOYMENT
--   SAT_ORG_UNIT_DEFINITION
--   SAT_ORG_UNIT_LICENCE
--   SAT_POLICY_BONUS_TRACKING
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_branch_master') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_branch_master',
      'alias': 't0',
      'key_column': "nullif(trim(branch_code),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BRANCH_MASTER',
      'columns': [
        {'src': 'account_category_code', 'tgt': 'aug_org_unit_definition__accounting_category_code'},
        {'src': 'nearest_dm_branch', 'tgt': 'aug_org_unit_definition__nearest_controlling_org_unit_reference'},
        {'src': 'reason_for_act_deact', 'tgt': 'aug_org_unit_definition__org_unit_status_reason'},
        {'src': 'register_flag', 'tgt': 'aug_org_unit_definition__registration_indicator'},
        {'src': 'record_date', 'tgt': 'aug_org_unit_definition__source_record_date'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_org_unit_definition__accounting_category_code',
    'aug_org_unit_definition__nearest_controlling_org_unit_reference',
    'aug_org_unit_definition__org_unit_status_reason',
    'aug_org_unit_definition__registration_indicator',
    'aug_org_unit_definition__source_record_date'
] -%}
{%- set coalesce_rules = {
    'aug_org_unit_definition__accounting_category_code': ['t0'],
    'aug_org_unit_definition__nearest_controlling_org_unit_reference': ['t0'],
    'aug_org_unit_definition__org_unit_status_reason': ['t0'],
    'aug_org_unit_definition__registration_indicator': ['t0'],
    'aug_org_unit_definition__source_record_date': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='org_unit_bk',
    target_sat='sat_aug_org_unit_definition'
) }}
