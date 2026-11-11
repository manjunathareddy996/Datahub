{{ config(materialized='view') }}
-- This part feeds SAT_PARTY_FINANCIAL_PROFILE only. Original precedence comments are kept below (from stitch_v21_party).
-- CENTRAL VIEW v21_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_PARTY_FINANCIAL_PROFILE
--   SAT_PARTY_POLICY_HISTORY
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_DOCUMENT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_DOCUMENT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_RISK_OBJECT_DOCUMENT
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't0',
      'key_column': 'pd_premium_payer_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'md_gross_monthly_income', 'tgt': 'party_financial_profile__annual_income'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't1',
      'key_column': 'pd_premium_payer_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'md_gross_monthly_income', 'tgt': 'party_financial_profile__annual_income'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't2',
      'key_column': 'pd_premium_payer_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'md_gross_monthly_income', 'tgt': 'party_financial_profile__annual_income'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't3',
      'key_column': 'pd_premium_payer_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'md_gross_monthly_income', 'tgt': 'party_financial_profile__annual_income'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't4',
      'key_column': 'member_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'gross_income', 'tgt': 'party_financial_profile__annual_income'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't5',
      'key_column': 'member_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': 'monthly_income', 'tgt': 'party_financial_profile__annual_income'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't6',
      'key_column': 'member_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'gross_income', 'tgt': 'party_financial_profile__annual_income'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ihg_mem_dtls_extn',
      'alias': 't7',
      'key_column': 'member_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_IHG_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'gross_income', 'tgt': 'party_financial_profile__annual_income'}
      ]
    },
    {
      'model': 'stg_health__bjaz_sh_mem_dtls_extn',
      'alias': 't8',
      'key_column': 'member_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_SH_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'gross_income', 'tgt': 'party_financial_profile__annual_income'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_financial_profile__annual_income'
] -%}
{%- set coalesce_rules = {
    'party_financial_profile__annual_income': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_bk',
    target_sat='sat_party_financial_profile'
) }}
