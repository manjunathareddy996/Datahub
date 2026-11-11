{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_PREMIUM_SUMMARY only. Original precedence comments are kept below (from stitch_v27_policy).
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
-- depends_on: {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
-- depends_on: {{ ref('stg_health__ba_hcp_dt_premium') }}
-- depends_on: {{ ref('stg_health__ba_hcp_pol_mst') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prime_rider_dtls') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bgil_gmc_final_instl_data') }}
-- depends_on: {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
-- depends_on: {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_generic_loader_log_table') }}
-- depends_on: {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_gp_hospital_cash') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
-- depends_on: {{ ref('stg_health__bjaz_health_webservice_info') }}
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__ba_ccp_sub_mater_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_summary') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': 'total_base_premium', 'tgt': 'policy_premium_summary__base_premium'},
        {'src': 'environment_fund', 'tgt': 'policy_premium_summary__environment_relief_fund_amount'},
        {'src': 'final_premium', 'tgt': 'policy_premium_summary__gross_premium'},
        {'src': 'group_discount', 'tgt': 'policy_premium_summary__group_discount_amount'},
        {'src': 'installment_no', 'tgt': 'policy_premium_summary__instalment_count'},
        {'src': 'installment_option_yn', 'tgt': 'policy_premium_summary__instalment_indicator'},
        {'src': 'net_premium', 'tgt': 'policy_premium_summary__net_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't1',
      'key_column': "nullif(trim(policy_ref),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': 'pay_status', 'tgt': 'policy_premium_summary__premium_payment_status'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_dt_premium',
      'alias': 't2',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_PREMIUM',
      'columns': [
        {'src': 'total_prem_on_base_cov_addon', 'tgt': 'policy_premium_summary__add_on_premium'},
        {'src': 'total_prem_on_base_cov', 'tgt': 'policy_premium_summary__base_premium'},
        {'src': 'pol_gross_prem_amt', 'tgt': 'policy_premium_summary__gross_premium'},
        {'src': 'pol_net_prem_amt', 'tgt': 'policy_premium_summary__net_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_pol_mst',
      'alias': 't3',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_POL_MST',
      'columns': [
        {'src': 'group_discount', 'tgt': 'policy_premium_summary__group_discount_amount'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prime_rider_dtls',
      'alias': 't4',
      'key_column': 'base_policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PRIME_RIDER_DTLS',
      'columns': [
        {'src': 'total_final_premium', 'tgt': 'policy_premium_summary__gross_premium'},
        {'src': 'total_net_premium', 'tgt': 'policy_premium_summary__net_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't5',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pd_premium_including_st', 'tgt': 'policy_premium_summary__gross_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't6',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'pd_premium_including_st', 'tgt': 'policy_premium_summary__gross_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't7',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'pd_premium_including_st', 'tgt': 'policy_premium_summary__gross_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't8',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pd_premium_including_st', 'tgt': 'policy_premium_summary__gross_premium'}
      ]
    },
    {
      'model': 'stg_health__bgil_gmc_final_instl_data',
      'alias': 't9',
      'key_column': 'policy_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BGIL_GMC_FINAL_INSTL_DATA',
      'columns': [
        {'src': 'installments', 'tgt': 'policy_premium_summary__instalment_count'}
      ]
    },
    {
      'model': 'stg_health__bjaz_bandhan_medi_clam',
      'alias': 't10',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BANDHAN_MEDI_CLAM',
      'columns': [
        {'src': 'gross_preminum', 'tgt': 'policy_premium_summary__gross_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ehh_pol_dtls',
      'alias': 't11',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EHH_POL_DTLS',
      'columns': [
        {'src': 'gross_premium', 'tgt': 'policy_premium_summary__gross_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_generic_loader_log_table',
      'alias': 't12',
      'key_column': 'pmasterpolicynumber',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GENERIC_LOADER_LOG_TABLE',
      'columns': [
        {'src': 'pgrosspremium', 'tgt': 'policy_premium_summary__gross_premium'},
        {'src': 'ptotalpremium', 'tgt': 'policy_premium_summary__total_premium_collected'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gpg_pol_dtls',
      'alias': 't13',
      'key_column': 'reference_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GPG_POL_DTLS',
      'columns': [
        {'src': 'total_addon_premium', 'tgt': 'policy_premium_summary__add_on_premium'},
        {'src': 'total_base_premium', 'tgt': 'policy_premium_summary__base_premium'},
        {'src': 'final_premium', 'tgt': 'policy_premium_summary__gross_premium'},
        {'src': 'long_term_discount', 'tgt': 'policy_premium_summary__long_term_discount_amount'},
        {'src': 'net_premium', 'tgt': 'policy_premium_summary__net_premium'},
        {'src': 'full_yr_terr_prem', 'tgt': 'policy_premium_summary__terrorism_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gp_hospital_cash',
      'alias': 't14',
      'key_column': 'master_policy_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GP_HOSPITAL_CASH',
      'columns': [
        {'src': 'gross_premium', 'tgt': 'policy_premium_summary__gross_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't15',
      'key_column': 'reg_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'final_prm_ex_stax', 'tgt': 'policy_premium_summary__net_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't16',
      'key_column': 'reg_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'base_premium', 'tgt': 'policy_premium_summary__base_premium'},
        {'src': 'gross_permium', 'tgt': 'policy_premium_summary__gross_premium'},
        {'src': 'total_permium', 'tgt': 'policy_premium_summary__total_premium_collected'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hdfc_sec_fhpp',
      'alias': 't17',
      'key_column': 'reference_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HDFC_SEC_FHPP',
      'columns': [
        {'src': 'gross_premium', 'tgt': 'policy_premium_summary__gross_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_health_webservice_info',
      'alias': 't18',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HEALTH_WEBSERVICE_INFO',
      'columns': [
        {'src': 'add_on_prem', 'tgt': 'policy_premium_summary__add_on_premium'},
        {'src': 'gross_premium', 'tgt': 'policy_premium_summary__gross_premium'},
        {'src': 'net_premium', 'tgt': 'policy_premium_summary__net_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't19',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'gross_premium', 'tgt': 'policy_premium_summary__gross_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't20',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': 'tot_sec_prem', 'tgt': 'policy_premium_summary__base_premium'},
        {'src': 'final_prem', 'tgt': 'policy_premium_summary__gross_premium'},
        {'src': 'long_trm_disc', 'tgt': 'policy_premium_summary__long_term_discount_amount'},
        {'src': 'net_prem', 'tgt': 'policy_premium_summary__net_premium'},
        {'src': 'terr_prem', 'tgt': 'policy_premium_summary__terrorism_premium'},
        {'src': 'amt_collected_cust', 'tgt': 'policy_premium_summary__total_premium_collected'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't21',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': 'gross_premium', 'tgt': 'policy_premium_summary__gross_premium'},
        {'src': 'ncb_amt', 'tgt': 'policy_premium_summary__no_claim_bonus_amount'},
        {'src': 'cust_amt', 'tgt': 'policy_premium_summary__total_premium_collected'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't22',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': 'envr_fund_amt', 'tgt': 'policy_premium_summary__environment_relief_fund_amount'},
        {'src': 'gross_premium', 'tgt': 'policy_premium_summary__gross_premium'},
        {'src': 'net_premium', 'tgt': 'policy_premium_summary__net_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_pol_dtls',
      'alias': 't23',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_POL_DTLS',
      'columns': [
        {'src': 'total_prem', 'tgt': 'policy_premium_summary__gross_premium'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_premium_summary__base_premium',
    'policy_premium_summary__environment_relief_fund_amount',
    'policy_premium_summary__gross_premium',
    'policy_premium_summary__group_discount_amount',
    'policy_premium_summary__instalment_count',
    'policy_premium_summary__instalment_indicator',
    'policy_premium_summary__net_premium',
    'policy_premium_summary__premium_payment_status',
    'policy_premium_summary__add_on_premium',
    'policy_premium_summary__total_premium_collected',
    'policy_premium_summary__long_term_discount_amount',
    'policy_premium_summary__terrorism_premium',
    'policy_premium_summary__no_claim_bonus_amount'
] -%}
{%- set coalesce_rules = {
    'policy_premium_summary__base_premium': ['t0', 't2', 't13', 't16', 't20'],
    'policy_premium_summary__environment_relief_fund_amount': ['t0', 't22'],
    'policy_premium_summary__gross_premium': ['t0', 't2', 't4', 't5', 't6', 't7', 't8', 't10', 't11', 't12', 't13', 't14', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23'],
    'policy_premium_summary__group_discount_amount': ['t0', 't3'],
    'policy_premium_summary__instalment_count': ['t0', 't9'],
    'policy_premium_summary__instalment_indicator': ['t0'],
    'policy_premium_summary__net_premium': ['t0', 't2', 't4', 't13', 't15', 't18', 't20', 't22'],
    'policy_premium_summary__premium_payment_status': ['t1'],
    'policy_premium_summary__add_on_premium': ['t2', 't13', 't18'],
    'policy_premium_summary__total_premium_collected': ['t12', 't16', 't20', 't21'],
    'policy_premium_summary__long_term_discount_amount': ['t13', 't20'],
    'policy_premium_summary__terrorism_premium': ['t13', 't20'],
    'policy_premium_summary__no_claim_bonus_amount': ['t21']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_policy_premium_summary'
) }}
