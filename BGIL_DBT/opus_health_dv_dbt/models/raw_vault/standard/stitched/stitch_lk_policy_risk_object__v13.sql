{{ config(materialized='view') }}
-- This part feeds LNK_POLICY_RISK_OBJECT only. Original precedence comments are kept below (from stitch_v13_financial_account).
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

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't0',
      'key_column': "pol_serial_no || '|' || md_seq_no",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pol_serial_no', 'tgt': 'policy_bk'},
        {'src': 'md_seq_no', 'tgt': 'risk_object_bk'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'risk_object_bk'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0'],
    'risk_object_bk': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_risk_object_lk',
    target_sat='lnk_policy_risk_object'
) }}
