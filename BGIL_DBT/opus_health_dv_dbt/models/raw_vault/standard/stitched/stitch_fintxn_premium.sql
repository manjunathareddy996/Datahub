{{ config(materialized='view') }}
-- This part feeds SAT_FINTXN_PREMIUM only. Original precedence comments are kept below (from stitch_v31_product).
-- CENTRAL VIEW v31_product -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_COVERS_EXT (opus_health_v2)
--   BJAZ_CTNGY_SCHEME_NR_PARMS (opus_health_v2)
--   BJAZ_CTNGY_SCHEME_PLANS (opus_health_v2)
--   BA_HCP_DT_MEM (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_MATERNITY_DTLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HCS_PLANSI_MAPP (opus_health_legacy_v4)
--   BJAZ_HEALTH_WEBSERVICE_INFO (opus_health_legacy_v4)
--   BA_CCP_SUB_MATER_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_PRODUCT_CAPTURE_PARAMETER
--   SAT_AUG_PRODUCT_DISTRIBUTION_RULES
--   SAT_AUG_PRODUCT_ISSUANCE_OUTPUT_RULE
--   SAT_AUG_PRODUCT_RATING_STRUCTURE
--   SAT_AUG_RISK_OBJECT_INSURABLE_INTEREST
--   SAT_FINTXN_COMMISSION
--   SAT_FINTXN_HEADER
--   SAT_FINTXN_PREMIUM
--   SAT_FINTXN_RECON_INSTRUMENT
--   SAT_FIN_RECEIPT
--   SAT_POLICY_CLAUSE_ATTACHED
--   SAT_POLICY_PREMIUM_HEAD
--   SAT_POLICY_RENEWAL
--   SAT_PRODUCT_DISTRIBUTION_RULES
--   SAT_PRODUCT_HEALTH_MEMBERSHIP_RULES
--   SAT_PRODUCT_TERMS
--   SAT_PRODUCT_VERSION
--   SAT_PROPOSAL_UNDERWRITING
--   SAT_QUOTE_RATING
--   SAT_RISK_OBJECT_INSURABLE_INTEREST
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_AGREEMENT_CHANNEL
--   LNK_AGREEMENT_PRODUCT
--   LNK_CHANNEL_ORG_UNIT
--   LNK_FINTXN_ACCOUNT
--   LNK_FINTXN_POLICY
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_health_webservice_info') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_health_webservice_info',
      'alias': 't0',
      'key_column': 'ptransaction_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HEALTH_WEBSERVICE_INFO',
      'columns': [
        {'src': 'payment_mode', 'tgt': 'fintxn_premium__collection_mode'}
      ]
    }
] -%}
{%- set output_columns = [
    'fintxn_premium__collection_mode'
] -%}
{%- set coalesce_rules = {
    'fintxn_premium__collection_mode': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='financial_transaction_bk',
    target_sat='sat_fintxn_premium'
) }}
