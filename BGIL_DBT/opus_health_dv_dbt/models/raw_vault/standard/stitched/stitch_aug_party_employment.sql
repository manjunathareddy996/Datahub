{{ config(materialized='view') }}
-- This part feeds SAT_AUG_PARTY_EMPLOYMENT only. Original precedence comments are kept below (from stitch_v14_org_unit).
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
-- depends_on: {{ ref('stg_health__ba_hcp_dt_premium') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_dt_premium',
      'alias': 't0',
      'key_column': 'user_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_PREMIUM',
      'columns': [
        {'src': 'emp_no', 'tgt': 'aug_party_employment__employee_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't1',
      'key_column': 'member_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'monthly_salary', 'tgt': 'aug_party_employment__monthly_salary_amount'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_party_employment__employee_number',
    'aug_party_employment__monthly_salary_amount'
] -%}
{%- set coalesce_rules = {
    'aug_party_employment__employee_number': ['t0'],
    'aug_party_employment__monthly_salary_amount': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_bk',
    target_sat='sat_aug_party_employment'
) }}
