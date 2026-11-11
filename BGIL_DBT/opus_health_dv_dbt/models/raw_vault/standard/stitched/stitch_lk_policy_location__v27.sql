{{ config(materialized='view') }}
-- This part feeds LNK_POLICY_LOCATION only. Original precedence comments are kept below (from stitch_v27_policy).
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
-- depends_on: {{ ref('stg_health__ba_hcp_pol_mst') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_pol_mst',
      'alias': 't0',
      'key_column': "child_loc_code || '|' || contract_id",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_POL_MST',
      'columns': [
        {'src': 'child_loc_code', 'tgt': 'location_bk'},
        {'src': 'contract_id', 'tgt': 'policy_bk'}
      ]
    }
] -%}
{%- set output_columns = [
    'location_bk',
    'policy_bk'
] -%}
{%- set coalesce_rules = {
    'location_bk': ['t0'],
    'policy_bk': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_location_lk',
    target_sat='lnk_policy_location'
) }}
