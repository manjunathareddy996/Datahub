{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_TERMS only. Original precedence comments are kept below (from stitch_v30_policy).
-- CENTRAL VIEW v30_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_GC_CONTROL (opus_health_v2)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_ILLNESS_BASES_EXTN (opus_health_legacy_v4)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_POLICY_TERMS
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_ctngy_gc_control') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_illness_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_gmc_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_gc_control',
      'alias': 't0',
      'key_column': "nullif(trim(policy_ref),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_GC_CONTROL',
      'columns': [
        {'src': 'co_payment', 'tgt': 'policy_terms__co_payment_percentage'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't1',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'plc_special_terms_conditions', 'tgt': 'policy_terms__special_conditions'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't2',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'plc_aggr_deductible', 'tgt': 'policy_terms__deductible_total'},
        {'src': 'plc_special_terms_conditions', 'tgt': 'policy_terms__special_conditions'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't3',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'plc_special_terms_conditions', 'tgt': 'policy_terms__special_conditions'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't4',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'plc_special_terms_conditions', 'tgt': 'policy_terms__special_conditions'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gpg_pol_dtls',
      'alias': 't5',
      'key_column': 'reference_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GPG_POL_DTLS',
      'columns': [
        {'src': 'spcl_terms_cond', 'tgt': 'policy_terms__special_conditions'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't6',
      'key_column': 'reg_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'other_conditions', 'tgt': 'policy_terms__special_conditions'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't7',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'voluntary_co_pay', 'tgt': 'policy_terms__co_payment_percentage'},
        {'src': 'aggregate_deductible', 'tgt': 'policy_terms__deductible_total'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hlt_ensure_mem_dtls',
      'alias': 't8',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HLT_ENSURE_MEM_DTLS',
      'columns': [
        {'src': 'special_condition', 'tgt': 'policy_terms__special_conditions'}
      ]
    },
    {
      'model': 'stg_health__bjaz_illness_bases_extn',
      'alias': 't9',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ILLNESS_BASES_EXTN',
      'columns': [
        {'src': 'special_condition', 'tgt': 'policy_terms__special_conditions'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gmc_bases_extn',
      'alias': 't10',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GMC_BASES_EXTN',
      'columns': [
        {'src': 'sp_conditions', 'tgt': 'policy_terms__special_conditions'},
        {'src': 'warrenties', 'tgt': 'policy_terms__warranty_conditions'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_pol_dtls',
      'alias': 't11',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_POL_DTLS',
      'columns': [
        {'src': 'co_pymt', 'tgt': 'policy_terms__co_payment_percentage'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_terms__co_payment_percentage',
    'policy_terms__special_conditions',
    'policy_terms__deductible_total',
    'policy_terms__warranty_conditions'
] -%}
{%- set coalesce_rules = {
    'policy_terms__co_payment_percentage': ['t0', 't7', 't11'],
    'policy_terms__special_conditions': ['t1', 't2', 't3', 't4', 't5', 't6', 't8', 't9', 't10'],
    'policy_terms__deductible_total': ['t2', 't7'],
    'policy_terms__warranty_conditions': ['t10']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_policy_terms'
) }}
