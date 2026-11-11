{{ config(materialized='view') }}
-- This part feeds SAT_AUG_POLICY_PORTABILITY_MIGRATION only. Original precedence comments are kept below (from stitch_v17_party).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_member_hlth_dtls') }}
-- depends_on: {{ ref('stg_health__ba_hcp_port_wordings') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_gmc_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': 'first_policy_ref', 'tgt': 'aug_policy_portability_migration__originating_policy_number'},
        {'src': 'prev_policy_dtls', 'tgt': 'aug_policy_portability_migration__previous_policy_detail'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_port_wordings',
      'alias': 't1',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PORT_WORDINGS',
      'columns': [
        {'src': 'port_reason', 'tgt': 'aug_policy_portability_migration__portability_reason'},
        {'src': 'prev_policy_exp_date', 'tgt': 'aug_policy_portability_migration__previous_policy_expiry_date'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't2',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'md_first_policy_inception_date', 'tgt': 'aug_policy_portability_migration__first_policy_inception_date'},
        {'src': 'md_prev_expiry_date', 'tgt': 'aug_policy_portability_migration__previous_policy_expiry_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't3',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'first_policy_ref', 'tgt': 'aug_policy_portability_migration__first_policy_reference'},
        {'src': 'con_deductable', 'tgt': 'aug_policy_portability_migration__previous_policy_deductible'},
        {'src': 'coalesce(con_exp_date, perv_pol_exp_date)', 'tgt': 'aug_policy_portability_migration__previous_policy_expiry_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gpg_pol_dtls',
      'alias': 't4',
      'key_column': 'reference_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GPG_POL_DTLS',
      'columns': [
        {'src': 'prev_policy_branch_address', 'tgt': 'aug_policy_portability_migration__previous_insurer_branch_address'},
        {'src': 'prev_policy_expiry', 'tgt': 'aug_policy_portability_migration__previous_policy_expiry_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't5',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': 'prev_policy_since', 'tgt': 'aug_policy_portability_migration__previous_policy_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't6',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'perv_pol_exp_date', 'tgt': 'aug_policy_portability_migration__previous_policy_expiry_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hlt_ensure_mem_dtls',
      'alias': 't7',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HLT_ENSURE_MEM_DTLS',
      'columns': [
        {'src': 'first_pol_inception_date', 'tgt': 'aug_policy_portability_migration__first_policy_inception_date'},
        {'src': 'first_policy_number', 'tgt': 'aug_policy_portability_migration__first_policy_number'},
        {'src': 'previous_cum_amount', 'tgt': 'aug_policy_portability_migration__ported_cumulative_bonus_amount'},
        {'src': 'previous_to_date', 'tgt': 'aug_policy_portability_migration__previous_policy_expiry_date'},
        {'src': 'previous_from_date', 'tgt': 'aug_policy_portability_migration__previous_policy_start_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_sh_mem_dtls_extn',
      'alias': 't8',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_SH_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'first_policy_ref', 'tgt': 'aug_policy_portability_migration__first_original_policy_reference'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gmc_bases_extn',
      'alias': 't9',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GMC_BASES_EXTN',
      'columns': [
        {'src': 'first_policy_ref', 'tgt': 'aug_policy_portability_migration__first_policy_reference'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't10',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': 'prev_policy_expiry_date', 'tgt': 'aug_policy_portability_migration__previous_policy_expiry_date'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_policy_portability_migration__originating_policy_number',
    'aug_policy_portability_migration__previous_policy_detail',
    'aug_policy_portability_migration__portability_reason',
    'aug_policy_portability_migration__previous_policy_expiry_date',
    'aug_policy_portability_migration__first_policy_inception_date',
    'aug_policy_portability_migration__first_policy_reference',
    'aug_policy_portability_migration__previous_policy_deductible',
    'aug_policy_portability_migration__previous_insurer_branch_address',
    'aug_policy_portability_migration__previous_policy_inception_date',
    'aug_policy_portability_migration__first_policy_number',
    'aug_policy_portability_migration__ported_cumulative_bonus_amount',
    'aug_policy_portability_migration__previous_policy_start_date',
    'aug_policy_portability_migration__first_original_policy_reference'
] -%}
{%- set coalesce_rules = {
    'aug_policy_portability_migration__originating_policy_number': ['t0'],
    'aug_policy_portability_migration__previous_policy_detail': ['t0'],
    'aug_policy_portability_migration__portability_reason': ['t1'],
    'aug_policy_portability_migration__previous_policy_expiry_date': ['t1', 't2', 't3', 't4', 't6', 't7', 't10'],
    'aug_policy_portability_migration__first_policy_inception_date': ['t2', 't7'],
    'aug_policy_portability_migration__first_policy_reference': ['t3', 't9'],
    'aug_policy_portability_migration__previous_policy_deductible': ['t3'],
    'aug_policy_portability_migration__previous_insurer_branch_address': ['t4'],
    'aug_policy_portability_migration__previous_policy_inception_date': ['t5'],
    'aug_policy_portability_migration__first_policy_number': ['t7'],
    'aug_policy_portability_migration__ported_cumulative_bonus_amount': ['t7'],
    'aug_policy_portability_migration__previous_policy_start_date': ['t7'],
    'aug_policy_portability_migration__first_original_policy_reference': ['t8']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_aug_policy_portability_migration'
) }}
