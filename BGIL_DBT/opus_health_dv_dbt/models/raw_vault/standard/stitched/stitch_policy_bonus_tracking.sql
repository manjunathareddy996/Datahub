{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_BONUS_TRACKING only. Original precedence comments are kept below (from stitch_v14_org_unit).
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
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_dt_premium',
      'alias': 't0',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_PREMIUM',
      'columns': [
        {'src': 'cumulative_bonus_amt', 'tgt': 'policy_bonus_tracking__bonus_amount'},
        {'src': 'cumulative_bonus_rate', 'tgt': 'policy_bonus_tracking__cumulative_bonus_percentage'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't1',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'plc_cb_amount', 'tgt': 'policy_bonus_tracking__bonus_amount'},
        {'src': 'plc_cb_per', 'tgt': 'policy_bonus_tracking__cumulative_bonus_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't2',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': 'cumulative_amt', 'tgt': 'policy_bonus_tracking__bonus_amount'},
        {'src': 'cumulative_bnouz_per', 'tgt': 'policy_bonus_tracking__cumulative_bonus_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't3',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'cumm_bonus', 'tgt': 'policy_bonus_tracking__bonus_amount'},
        {'src': 'cumm_bonus_per', 'tgt': 'policy_bonus_tracking__cumulative_bonus_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ihg_mem_dtls_extn',
      'alias': 't4',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_IHG_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'cumm_bonus', 'tgt': 'policy_bonus_tracking__bonus_amount'},
        {'src': 'cumm_bonus_per', 'tgt': 'policy_bonus_tracking__cumulative_bonus_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_sh_mem_dtls_extn',
      'alias': 't5',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_SH_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'cumm_bonus', 'tgt': 'policy_bonus_tracking__bonus_amount'},
        {'src': 'cumm_bonus_per', 'tgt': 'policy_bonus_tracking__cumulative_bonus_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't6',
      'key_column': 'policy_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'bonus', 'tgt': 'policy_bonus_tracking__bonus_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't7',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': 'ncb_rate', 'tgt': 'policy_bonus_tracking__ncb_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_pol_dtls',
      'alias': 't8',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_POL_DTLS',
      'columns': [
        {'src': 'cb_amt', 'tgt': 'policy_bonus_tracking__bonus_amount'},
        {'src': 'cb_per', 'tgt': 'policy_bonus_tracking__cumulative_bonus_percentage'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bonus_tracking__bonus_amount',
    'policy_bonus_tracking__cumulative_bonus_percentage',
    'policy_bonus_tracking__ncb_percentage'
] -%}
{%- set coalesce_rules = {
    'policy_bonus_tracking__bonus_amount': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't8'],
    'policy_bonus_tracking__cumulative_bonus_percentage': ['t0', 't1', 't2', 't3', 't4', 't5', 't8'],
    'policy_bonus_tracking__ncb_percentage': ['t7']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_policy_bonus_tracking'
) }}
