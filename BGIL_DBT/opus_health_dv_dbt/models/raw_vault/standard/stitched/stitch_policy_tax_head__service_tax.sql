{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_TAX_HEAD only. Original precedence comments are kept below (from stitch_v27_policy).
-- CENTRAL VIEW v27_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_DT_PREMIUM (opus_health_legacy_v4)
--   BA_HCP_POL_MST (opus_health_legacy_v4)
--   BA_HCP_PRIME_RIDER_DTLS (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_EHH_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GENERIC_LOADER_LOG_TABLE (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GP_HOSPITAL_CASH (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_MATERNITY_DTLS (opus_health_legacy_v4)
--   BJAZ_HDFC_SEC_FHPP (opus_health_legacy_v4)
--   BJAZ_HEALTH_WEBSERVICE_INFO (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BA_CCP_SUB_MATER_DTLS (opus_health_delta3)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_POLICY_SUMMARY (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_DISCOUNT_LOADING_APPLIED
--   SAT_AUG_POLICY_PREMIUM_SUMMARY
--   SAT_PARTY_GROUP_HOUSEHOLD
--   SAT_POLICY_DISCOUNT_LOADING_APPLIED
--   SAT_POLICY_INTERMEDIARY_SPLIT
--   SAT_POLICY_PREMIUM_SUMMARY
--   SAT_POLICY_TAX_BREAKUP
--   SAT_POLICY_TAX_HEAD
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_LOCATION
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_LOCATION
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_generic_loader_log_table') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
-- depends_on: {{ ref('stg_health__ba_ccp_sub_mater_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_summary') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': 'service_tax', 'tgt': 'policy_tax_head__tax_amount'},
        {'src': "'SERVICE_TAX'", 'tgt': 'policy_tax_head__tax_head_code_ck'}
      ]
    },
    {
      'model': 'stg_health__bjaz_generic_loader_log_table',
      'alias': 't1',
      'key_column': 'pmasterpolicynumber',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GENERIC_LOADER_LOG_TABLE',
      'columns': [
        {'src': 'pservicetax', 'tgt': 'policy_tax_head__tax_amount'},
        {'src': "'SERVICE_TAX'", 'tgt': 'policy_tax_head__tax_head_code_ck'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't2',
      'key_column': 'reg_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'sertax_amt', 'tgt': 'policy_tax_head__tax_amount'},
        {'src': "'SERVICE_TAX'", 'tgt': 'policy_tax_head__tax_head_code_ck'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't3',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': 'ser_tax', 'tgt': 'policy_tax_head__tax_amount'},
        {'src': "'SERVICE_TAX'", 'tgt': 'policy_tax_head__tax_head_code_ck'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't4',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': 'service_tax_amt', 'tgt': 'policy_tax_head__tax_amount'},
        {'src': "'SERVICE_TAX'", 'tgt': 'policy_tax_head__tax_head_code_ck'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't5',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': 'service_tax', 'tgt': 'policy_tax_head__tax_amount'},
        {'src': "'SERVICE_TAX'", 'tgt': 'policy_tax_head__tax_head_code_ck'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_tax_head__tax_amount',
    'policy_tax_head__tax_head_code_ck'
] -%}
{%- set coalesce_rules = {
    'policy_tax_head__tax_amount': ['t0', 't1', 't2', 't3', 't4', 't5'],
    'policy_tax_head__tax_head_code_ck': ['t0', 't1', 't2', 't3', 't4', 't5']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_policy_tax_head'
) }}
