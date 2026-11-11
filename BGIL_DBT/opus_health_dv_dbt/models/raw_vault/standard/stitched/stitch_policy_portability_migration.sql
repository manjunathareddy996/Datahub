{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_PORTABILITY_MIGRATION only. Original precedence comments are kept below (from stitch_v29_policy).
-- CENTRAL VIEW v29_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PORT_WORDINGS (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_POLICY_PORTABILITY_MIGRATION
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__ba_hcp_port_wordings') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hc_part_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_port_wordings',
      'alias': 't0',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PORT_WORDINGS',
      'columns': [
        {'src': 'prev_insurer', 'tgt': 'policy_portability_migration__previous_insurer_name'},
        {'src': 'prev_policy_no', 'tgt': 'policy_portability_migration__previous_policy_number'},
        {'src': 'prev_si', 'tgt': 'policy_portability_migration__previous_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't1',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'md_prev_comp_name', 'tgt': 'policy_portability_migration__previous_insurer_name'},
        {'src': 'md_prev_policy_number', 'tgt': 'policy_portability_migration__previous_policy_number'},
        {'src': 'md_prev_sum_insured', 'tgt': 'policy_portability_migration__previous_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't2',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'md_prev_comp_name', 'tgt': 'policy_portability_migration__previous_insurer_name'},
        {'src': 'md_prev_policy_number', 'tgt': 'policy_portability_migration__previous_policy_number'},
        {'src': 'md_prev_sum_insured', 'tgt': 'policy_portability_migration__previous_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't3',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'pre_pol_ncb_per', 'tgt': 'policy_portability_migration__cumulative_bonus_ported'},
        {'src': 'prev_company_name', 'tgt': 'policy_portability_migration__previous_insurer_name'},
        {'src': 'prev_policy_dtls', 'tgt': 'policy_portability_migration__previous_policy_number'},
        {'src': 'prev_sum_insured', 'tgt': 'policy_portability_migration__previous_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gpg_pol_dtls',
      'alias': 't4',
      'key_column': 'reference_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GPG_POL_DTLS',
      'columns': [
        {'src': 'prev_policy_comp_name', 'tgt': 'policy_portability_migration__previous_insurer_name'},
        {'src': 'prev_pol_no', 'tgt': 'policy_portability_migration__previous_policy_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't5',
      'key_column': 'reg_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'pre_insurer_name', 'tgt': 'policy_portability_migration__previous_insurer_name'},
        {'src': 'prv_policy_no', 'tgt': 'policy_portability_migration__previous_policy_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_id_mem_detls',
      'alias': 't6',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_ID_MEM_DETLS',
      'columns': [
        {'src': 'prev_policy_details', 'tgt': 'policy_portability_migration__previous_policy_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't7',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': 'previous_si', 'tgt': 'policy_portability_migration__previous_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hc_part_extn',
      'alias': 't8',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HC_PART_EXTN',
      'columns': [
        {'src': 'first_policy_ref', 'tgt': 'policy_portability_migration__previous_policy_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't9',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'pol_benefit_tran_yn', 'tgt': 'policy_portability_migration__portability_indicator'},
        {'src': 'prev_policy_no', 'tgt': 'policy_portability_migration__previous_policy_number'},
        {'src': 'prev_sum_insured', 'tgt': 'policy_portability_migration__previous_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hlt_ensure_mem_dtls',
      'alias': 't10',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HLT_ENSURE_MEM_DTLS',
      'columns': [
        {'src': 'previous_since_noof_years', 'tgt': 'policy_portability_migration__continuity_period_granted'},
        {'src': 'previous_cum_bonus', 'tgt': 'policy_portability_migration__cumulative_bonus_ported'},
        {'src': 'previous_company_name', 'tgt': 'policy_portability_migration__previous_insurer_name'},
        {'src': 'prev_policy_no', 'tgt': 'policy_portability_migration__previous_policy_number'},
        {'src': 'previous_sum_insured', 'tgt': 'policy_portability_migration__previous_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ihg_mem_dtls_extn',
      'alias': 't11',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_IHG_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'prev_policy_dtls', 'tgt': 'policy_portability_migration__previous_policy_number'},
        {'src': 'prev_sum_insured', 'tgt': 'policy_portability_migration__previous_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_sh_mem_dtls_extn',
      'alias': 't12',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_SH_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'prev_policy_dtls', 'tgt': 'policy_portability_migration__previous_policy_number'},
        {'src': 'prev_sum_insured', 'tgt': 'policy_portability_migration__previous_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't13',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': 'prev_insurer_name', 'tgt': 'policy_portability_migration__previous_insurer_name'},
        {'src': 'prev_policy_no', 'tgt': 'policy_portability_migration__previous_policy_number'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_portability_migration__previous_insurer_name',
    'policy_portability_migration__previous_policy_number',
    'policy_portability_migration__previous_sum_insured',
    'policy_portability_migration__cumulative_bonus_ported',
    'policy_portability_migration__portability_indicator',
    'policy_portability_migration__continuity_period_granted'
] -%}
{%- set coalesce_rules = {
    'policy_portability_migration__previous_insurer_name': ['t0', 't1', 't2', 't3', 't4', 't5', 't10', 't13'],
    'policy_portability_migration__previous_policy_number': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't8', 't9', 't10', 't11', 't12', 't13'],
    'policy_portability_migration__previous_sum_insured': ['t0', 't1', 't2', 't3', 't7', 't9', 't10', 't11', 't12'],
    'policy_portability_migration__cumulative_bonus_ported': ['t3', 't10'],
    'policy_portability_migration__portability_indicator': ['t9'],
    'policy_portability_migration__continuity_period_granted': ['t10']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_policy_portability_migration'
) }}
