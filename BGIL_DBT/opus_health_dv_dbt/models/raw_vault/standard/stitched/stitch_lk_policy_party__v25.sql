{{ config(materialized='view') }}
-- This part feeds LNK_POLICY_PARTY only. Original precedence comments are kept below (from stitch_v25_policy).
-- CENTRAL VIEW v25_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_COVERS_EXT (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BA_HCP_DT_POL_COV (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_MATERNITY_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_COVERAGE_DTLS (opus_health_delta3)
--   BJAZ_STARPKG_COVER_DTLS (opus_health_delta3)
--   OCP_POLICY_COVERS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_COVERAGE_SCHEDULE
--   SAT_POLICY_COVERAGE_SCHEDULE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_PARTY
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__ba_hcp_dt_pol_cov') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_dt_pol_cov',
      'alias': 't0',
      'key_column': "part_id || '|' || contract_id",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_POL_COV',
      'columns': [
        {'src': 'part_id', 'tgt': 'party_bk'},
        {'src': 'contract_id', 'tgt': 'policy_bk'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_bk',
    'policy_bk'
] -%}
{%- set coalesce_rules = {
    'party_bk': ['t0'],
    'policy_bk': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_party_lk',
    target_sat='lnk_policy_party'
) }}
