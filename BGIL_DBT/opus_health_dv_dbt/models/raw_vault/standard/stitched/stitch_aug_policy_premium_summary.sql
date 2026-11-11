{{ config(materialized='view') }}
-- This part feeds SAT_AUG_POLICY_PREMIUM_SUMMARY only. Original precedence comments are kept below (from stitch_v27_policy).
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
-- depends_on: {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_summary') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': 'base_premium', 'tgt': 'aug_policy_premium_summary__base_premium_before_adjustment'},
        {'src': 'premium_with_commm', 'tgt': 'aug_policy_premium_summary__premium_inclusive_of_commission_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gpg_pol_dtls',
      'alias': 't1',
      'key_column': 'reference_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GPG_POL_DTLS',
      'columns': [
        {'src': 'full_yr_net_prem', 'tgt': 'aug_policy_premium_summary__full_year_net_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't2',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': 'full_yr_net_prem', 'tgt': 'aug_policy_premium_summary__full_year_net_premium'},
        {'src': 'full_yr_terr_prem', 'tgt': 'aug_policy_premium_summary__full_year_terrorism_premium'},
        {'src': 'maxexp_netrate', 'tgt': 'aug_policy_premium_summary__maximum_exposure_net_rate'},
        {'src': 'maxexp_stdrate', 'tgt': 'aug_policy_premium_summary__maximum_exposure_standard_rate'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't3',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': 'receipt_dtls', 'tgt': 'aug_policy_premium_summary__receipt_details_text'},
        {'src': 'recpt_type', 'tgt': 'aug_policy_premium_summary__receipt_type'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_policy_premium_summary__base_premium_before_adjustment',
    'aug_policy_premium_summary__premium_inclusive_of_commission_amount',
    'aug_policy_premium_summary__full_year_net_premium',
    'aug_policy_premium_summary__full_year_terrorism_premium',
    'aug_policy_premium_summary__maximum_exposure_net_rate',
    'aug_policy_premium_summary__maximum_exposure_standard_rate',
    'aug_policy_premium_summary__receipt_details_text',
    'aug_policy_premium_summary__receipt_type'
] -%}
{%- set coalesce_rules = {
    'aug_policy_premium_summary__base_premium_before_adjustment': ['t0'],
    'aug_policy_premium_summary__premium_inclusive_of_commission_amount': ['t0'],
    'aug_policy_premium_summary__full_year_net_premium': ['t1', 't2'],
    'aug_policy_premium_summary__full_year_terrorism_premium': ['t2'],
    'aug_policy_premium_summary__maximum_exposure_net_rate': ['t2'],
    'aug_policy_premium_summary__maximum_exposure_standard_rate': ['t2'],
    'aug_policy_premium_summary__receipt_details_text': ['t3'],
    'aug_policy_premium_summary__receipt_type': ['t3']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_aug_policy_premium_summary'
) }}
