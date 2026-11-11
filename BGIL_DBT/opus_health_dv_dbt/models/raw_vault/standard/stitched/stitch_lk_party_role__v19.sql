{{ config(materialized='view') }}
-- This part feeds LNK_PARTY_ROLE only. Original precedence comments are kept below (from stitch_v19_party).
-- CENTRAL VIEW v19_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GP_HOSPITAL_CASH (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HDFC_SEC_FHPP (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_LNK_ROLE_NOMINEE_BENEFICIARY
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_gp_hospital_cash') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hc_part_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
-- depends_on: {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't0',
      'key_column': "pd_premium_payer_id || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't1',
      'key_column': "pd_premium_payer_id || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't2',
      'key_column': "pd_premium_payer_id || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't3',
      'key_column': "pd_premium_payer_id || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_bandhan_medi_clam',
      'alias': 't4',
      'key_column': "customer_id || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BANDHAN_MEDI_CLAM',
      'columns': [
        {'src': 'customer_id', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't5',
      'key_column': "member_no || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'member_no', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gp_hospital_cash',
      'alias': 't6',
      'key_column': "user_id || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GP_HOSPITAL_CASH',
      'columns': [
        {'src': 'user_id', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't7',
      'key_column': "member_no || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': 'member_no', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hc_part_extn',
      'alias': 't8',
      'key_column': "part_id || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HC_PART_EXTN',
      'columns': [
        {'src': 'part_id', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hdfc_sec_fhpp',
      'alias': 't9',
      'key_column': "client_id || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HDFC_SEC_FHPP',
      'columns': [
        {'src': 'client_id', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hlt_ensure_mem_dtls',
      'alias': 't10',
      'key_column': "member_no || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HLT_ENSURE_MEM_DTLS',
      'columns': [
        {'src': 'member_no', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ihg_mem_dtls_extn',
      'alias': 't11',
      'key_column': "member_no || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_IHG_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'member_no', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_sh_mem_dtls_extn',
      'alias': 't12',
      'key_column': "member_no || '|' || 'NOMINEE_BENEFICIARY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_SH_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'member_no', 'tgt': 'party_bk'},
        {'src': "'NOMINEE_BENEFICIARY'", 'tgt': 'role_type_code'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_bk',
    'role_type_code'
] -%}
{%- set coalesce_rules = {
    'party_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12'],
    'role_type_code': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_role_lk',
    target_sat='lnk_party_role'
) }}
