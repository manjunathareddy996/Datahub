{{ config(materialized='view') }}
-- This part feeds SAT_AUG_POLICY_CONTINGENCY_SCHEME only. Original precedence comments are kept below (from stitch_v22_policy).
-- CENTRAL VIEW v22_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_NR_BASES_EXTN (opus_health_v2)
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BA_HCP_DT_PREMIUM (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_HEALTH_WEBSERVICE_INFO (opus_health_legacy_v4)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_UNDERWRITING
--   SAT_AUG_POLICY_CLASSIFICATION
--   SAT_AUG_POLICY_CONTINGENCY_SCHEME
--   SAT_POLICY_CLASSIFICATION
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_ctngy_nr_bases_extn') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_nr_bases_extn',
      'alias': 't0',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_NR_BASES_EXTN',
      'columns': [
        {'src': 'scheme_code', 'tgt': 'aug_policy_contingency_scheme__scheme_code'},
        {'src': 'scheme_version', 'tgt': 'aug_policy_contingency_scheme__scheme_version'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_policy_contingency_scheme__scheme_code',
    'aug_policy_contingency_scheme__scheme_version'
] -%}
{%- set coalesce_rules = {
    'aug_policy_contingency_scheme__scheme_code': ['t0'],
    'aug_policy_contingency_scheme__scheme_version': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_aug_policy_contingency_scheme'
) }}
