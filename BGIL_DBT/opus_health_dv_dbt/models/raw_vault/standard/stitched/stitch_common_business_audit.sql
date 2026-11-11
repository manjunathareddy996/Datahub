{{ config(materialized='view') }}
-- This part feeds SAT_COMMON_BUSINESS_AUDIT only. Original precedence comments are kept below (from stitch_v24_policy).
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
-- depends_on: {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(policy_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': 'record_date', 'tgt': 'common_business_audit__created_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't1',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': 'approved_date', 'tgt': 'common_business_audit__approval_date'}
      ]
    }
] -%}
{%- set output_columns = [
    'common_business_audit__created_date',
    'common_business_audit__approval_date'
] -%}
{%- set coalesce_rules = {
    'common_business_audit__created_date': ['t0'],
    'common_business_audit__approval_date': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_common_business_audit'
) }}
