{{ config(materialized='view') }}
-- This part feeds LNK_PARTY_ROLE only. Original precedence comments are kept below (from stitch_v17_party).
-- CENTRAL VIEW v17_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_MEMBER_HLTH_DTLS (opus_health_v2)
--   BA_HCP_PORT_WORDINGS (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_PORTABILITY_MIGRATION
--   SAT_LNK_ROLE_EMPLOYEE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_ASSESSMENT_PARTY
--   LNK_CHANNEL_ORG_UNIT
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_ORG_UNIT
--   LNK_POLICY_CESSION
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_TREATY_PARTY
--   LNK_TREATY_PRODUCT
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_gpg_pol_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_gpg_pol_dtls',
      'alias': 't0',
      'key_column': "bagic_e_code || '|' || 'EMPLOYEE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GPG_POL_DTLS',
      'columns': [
        {'src': 'bagic_e_code', 'tgt': 'party_bk'},
        {'src': "'EMPLOYEE'", 'tgt': 'role_type_code'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_bk',
    'role_type_code'
] -%}
{%- set coalesce_rules = {
    'party_bk': ['t0'],
    'role_type_code': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_role_lk',
    target_sat='lnk_party_role'
) }}
