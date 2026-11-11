{{ config(materialized='view') }}
-- This part feeds SAT_AUG_POLICY_RENEWAL only. Original precedence comments are kept below (from stitch_v26_policy).
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
-- depends_on: {{ ref('stg_health__bjaz_ctngy_gc_control') }}
-- depends_on: {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
-- depends_on: {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_gc_control',
      'alias': 't0',
      'key_column': "nullif(trim(policy_ref),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_GC_CONTROL',
      'columns': [
        {'src': 'isrenew', 'tgt': 'aug_policy_renewal__renewal_business_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't1',
      'key_column': "nullif(trim(policy_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': 'previous_date_of_expiry', 'tgt': 'aug_policy_renewal__preceding_policy_expiry_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't2',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': 'first_policy_ref', 'tgt': 'aug_policy_renewal__first_policy_reference_in_continuity_chain'},
        {'src': 'prv_si', 'tgt': 'aug_policy_renewal__previous_year_sum_insured_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't3',
      'key_column': "nullif(trim(policy_ref),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': 'rnw_flag', 'tgt': 'aug_policy_renewal__renewal_business_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ihg_mem_dtls_extn',
      'alias': 't4',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_IHG_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'first_policy_ref', 'tgt': 'aug_policy_renewal__first_policy_reference'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_policy_renewal__renewal_business_indicator',
    'aug_policy_renewal__preceding_policy_expiry_date',
    'aug_policy_renewal__first_policy_reference_in_continuity_chain',
    'aug_policy_renewal__previous_year_sum_insured_amount',
    'aug_policy_renewal__first_policy_reference'
] -%}
{%- set coalesce_rules = {
    'aug_policy_renewal__renewal_business_indicator': ['t0', 't3'],
    'aug_policy_renewal__preceding_policy_expiry_date': ['t1'],
    'aug_policy_renewal__first_policy_reference_in_continuity_chain': ['t2'],
    'aug_policy_renewal__previous_year_sum_insured_amount': ['t2'],
    'aug_policy_renewal__first_policy_reference': ['t4']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_aug_policy_renewal'
) }}
