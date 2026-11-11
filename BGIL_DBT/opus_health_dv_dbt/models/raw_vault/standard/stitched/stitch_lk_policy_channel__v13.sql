{{ config(materialized='view') }}
-- This part feeds LNK_POLICY_CHANNEL only. Original precedence comments are kept below (from stitch_v13_financial_account).
-- CENTRAL VIEW v13_financial_account -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_EHH_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GP_HOSPITAL_CASH (opus_health_legacy_v4)
--   BJAZ_HDFC_SEC_FHPP (opus_health_legacy_v4)
--   BJAZ_BOT_UTILIZATION_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ACCOUNT_BALANCE
--   SAT_ACCOUNT_DEFINITION
--   SAT_AUG_ACCOUNT_BALANCE
--   SAT_AUG_ACCOUNT_DEFINITION
--   SAT_AUG_CHANNEL_BOT_SERVICE_UTILISATION
--   SAT_AUG_CHANNEL_DEFINITION
--   SAT_CHANNEL_DEFINITION
--   SAT_POLICY_TENURE_SCHEDULE
--   SAT_RISK_OBJECT_CORE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_ASSESSMENT_PARTY
--   LNK_CHANNEL_ORG_UNIT
--   LNK_CLAIM_ASSESSMENT
--   LNK_CLAIM_LOCATION
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_POLICY
--   LNK_ORG_UNIT_LOCATION
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_LOCATION
--   LNK_PARTY_ORG_UNIT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_LOCATION
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PROPOSAL_PARTY
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_PRODUCT
--   LNK_RISK_OBJECT_ASSESSMENT
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
-- depends_on: {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_gp_hospital_cash') }}
-- depends_on: {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't0',
      'key_column': "pd_partner_id || '|' || pol_serial_no",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pd_partner_id', 'tgt': 'distribution_channel_bk'},
        {'src': 'pol_serial_no', 'tgt': 'policy_bk'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't1',
      'key_column': "pd_partner_id || '|' || pol_serial_no",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pd_partner_id', 'tgt': 'distribution_channel_bk'},
        {'src': 'pol_serial_no', 'tgt': 'policy_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_bandhan_medi_clam',
      'alias': 't2',
      'key_column': "partner_id || '|' || policy_ref",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BANDHAN_MEDI_CLAM',
      'columns': [
        {'src': 'partner_id', 'tgt': 'distribution_channel_bk'},
        {'src': 'policy_ref', 'tgt': 'policy_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ehh_pol_dtls',
      'alias': 't3',
      'key_column': "partner_id || '|' || policy_ref",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EHH_POL_DTLS',
      'columns': [
        {'src': 'partner_id', 'tgt': 'distribution_channel_bk'},
        {'src': 'policy_ref', 'tgt': 'policy_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gp_hospital_cash',
      'alias': 't4',
      'key_column': "imd_code || '|' || master_policy_no",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GP_HOSPITAL_CASH',
      'columns': [
        {'src': 'imd_code', 'tgt': 'distribution_channel_bk'},
        {'src': 'master_policy_no', 'tgt': 'policy_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hdfc_sec_fhpp',
      'alias': 't5',
      'key_column': "imd_code || '|' || reference_id",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HDFC_SEC_FHPP',
      'columns': [
        {'src': 'imd_code', 'tgt': 'distribution_channel_bk'},
        {'src': 'reference_id', 'tgt': 'policy_bk'}
      ]
    }
] -%}
{%- set output_columns = [
    'distribution_channel_bk',
    'policy_bk'
] -%}
{%- set coalesce_rules = {
    'distribution_channel_bk': ['t0', 't1', 't2', 't3', 't4', 't5'],
    'policy_bk': ['t0', 't1', 't2', 't3', 't4', 't5']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_channel_lk',
    target_sat='lnk_policy_channel'
) }}
