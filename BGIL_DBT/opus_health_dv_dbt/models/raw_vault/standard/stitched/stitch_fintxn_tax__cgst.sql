{{ config(materialized='view') }}
-- This part feeds SAT_FINTXN_TAX only. Original precedence comments are kept below (from stitch_v26_policy).
-- CENTRAL VIEW v26_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_GC_CONTROL (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_POL_MST (opus_health_legacy_v4)
--   BA_HCP_PORT_WORDINGS (opus_health_legacy_v4)
--   BA_HCP_PRIME_RIDER_DTLS (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_CARD_DTLS (opus_health_legacy_v4)
--   BJAZ_ECARD_POL_DTLS_CONFIG (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_EHH_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GENERIC_LOADER_LOG_TABLE (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GP_HOSPITAL_CASH (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_MATERNITY_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HDFC_SEC_FHPP (opus_health_legacy_v4)
--   BJAZ_HEALTH_WEBSERVICE_INFO (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_ILLNESS_BASES_EXTN (opus_health_legacy_v4)
--   BJAZ_PMJAY_PRMBOOK_DTLS (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_WS_FAMILY_DTLS_BANDHAN (opus_health_legacy_v4)
--   BA_CCP_SUB_MATER_DTLS (opus_health_delta3)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_POLICY_SUMMARY (opus_health_delta3)
--   BJAZ_RISK_TRANS_DTLS (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_DELIVERY
--   SAT_AUG_POLICY_RENEWAL
--   SAT_FINTXN_TAX
--   SAT_POLICY_COINSURANCE
--   SAT_POLICY_GROUP
--   SAT_POLICY_HEADER
--   SAT_POLICY_LIFECYCLE
--   SAT_POLICY_REFUND_DETAIL
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
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
        {'src': 'central_gst', 'tgt': 'fintxn_tax__cgst_amount'},
        {'src': "'CGST'", 'tgt': 'fintxn_tax__tax_type_ck'}
      ]
    }
] -%}
{%- set output_columns = [
    'fintxn_tax__cgst_amount',
    'fintxn_tax__tax_type_ck'
] -%}
{%- set coalesce_rules = {
    'fintxn_tax__cgst_amount': ['t0'],
    'fintxn_tax__tax_type_ck': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='financial_transaction_bk',
    target_sat='sat_fintxn_tax'
) }}
