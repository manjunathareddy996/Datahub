{{ config(materialized='view') }}
-- This part feeds SAT_ORG_UNIT_DEFINITION only. Original precedence comments are kept below (from stitch_v14_org_unit).
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
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_branch_master',
      'alias': 't0',
      'key_column': "nullif(trim(branch_code),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BRANCH_MASTER',
      'columns': [
        {'src': 'branch_type', 'tgt': 'org_unit_definition__branch_type'},
        {'src': 'bm_username', 'tgt': 'org_unit_definition__head_reference'},
        {'src': 'branch_name', 'tgt': 'org_unit_definition__org_unit_name'},
        {'src': 'act_inact_status', 'tgt': 'org_unit_definition__org_unit_status'},
        {'src': 'parent_branch_code', 'tgt': 'org_unit_definition__parent_org_unit_reference'},
        {'src': 'print_zone', 'tgt': 'org_unit_definition__zone_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't1',
      'key_column': 'operating_office',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'operating_code', 'tgt': 'org_unit_definition__org_unit_code'},
        {'src': 'coalesce(controlling_office, operating_office)', 'tgt': 'org_unit_definition__org_unit_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't2',
      'key_column': "nullif(trim(department_code),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': 'dm_location', 'tgt': 'org_unit_definition__org_unit_name'}
      ]
    }
] -%}
{%- set output_columns = [
    'org_unit_definition__branch_type',
    'org_unit_definition__head_reference',
    'org_unit_definition__org_unit_name',
    'org_unit_definition__org_unit_status',
    'org_unit_definition__parent_org_unit_reference',
    'org_unit_definition__zone_name',
    'org_unit_definition__org_unit_code'
] -%}
{%- set coalesce_rules = {
    'org_unit_definition__branch_type': ['t0'],
    'org_unit_definition__head_reference': ['t0'],
    'org_unit_definition__org_unit_name': ['t0', 't1', 't2'],
    'org_unit_definition__org_unit_status': ['t0'],
    'org_unit_definition__parent_org_unit_reference': ['t0'],
    'org_unit_definition__zone_name': ['t0'],
    'org_unit_definition__org_unit_code': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='org_unit_bk',
    target_sat='sat_org_unit_definition'
) }}
