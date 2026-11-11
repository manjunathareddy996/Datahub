{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_HEADER only. Original precedence comments are kept below (from stitch_v26_policy).
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
-- depends_on: {{ ref('stg_health__ba_hcp_pol_mst') }}
-- depends_on: {{ ref('stg_health__ba_hcp_port_wordings') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prime_rider_dtls') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bgil_gmc_final_instl_data') }}
-- depends_on: {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
-- depends_on: {{ ref('stg_health__bjaz_card_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ecard_pol_dtls_config') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_generic_loader_log_table') }}
-- depends_on: {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_gp_hospital_cash') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hc_part_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
-- depends_on: {{ ref('stg_health__bjaz_health_webservice_info') }}
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_orphan_reg') }}
-- depends_on: {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_illness_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_pmjay_prmbook_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
-- depends_on: {{ ref('stg_health__bjaz_ws_family_dtls_bandhan') }}
-- depends_on: {{ ref('stg_health__ba_ccp_sub_mater_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_gmc_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_summary') }}
-- depends_on: {{ ref('stg_health__bjaz_risk_trans_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_gc_control',
      'alias': 't0',
      'key_column': "nullif(trim(policy_ref),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_GC_CONTROL',
      'columns': [
        {'src': 'location_code', 'tgt': 'policy_header__issuing_org_unit_code'},
        {'src': 'master_contract_id', 'tgt': 'policy_header__policy_reference_number'},
        {'src': 'remarks', 'tgt': 'policy_header__policy_remarks'},
        {'src': 'premium_payer_id', 'tgt': 'policy_header__premium_payer_reference'},
        {'src': 'product_code', 'tgt': 'policy_header__product_reference'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't1',
      'key_column': "nullif(trim(policy_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': 'hat_ref_no', 'tgt': 'policy_header__policy_reference_number'},
        {'src': 'remarks', 'tgt': 'policy_header__policy_remarks'},
        {'src': 'policy_type', 'tgt': 'policy_header__policy_type'},
        {'src': 'product_name', 'tgt': 'policy_header__product_reference'},
        {'src': 'si_type', 'tgt': 'policy_header__sum_insured_basis'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't2',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': 'co_insurance', 'tgt': 'policy_header__co_insurance_indicator'},
        {'src': 'buiseness_source', 'tgt': 'policy_header__issuing_channel_reference'},
        {'src': 'branch', 'tgt': 'policy_header__issuing_org_unit_code'},
        {'src': 'line_of_buiseness', 'tgt': 'policy_header__line_of_business'},
        {'src': 'policy_period', 'tgt': 'policy_header__policy_term_days'},
        {'src': 'product_code', 'tgt': 'policy_header__product_reference'},
        {'src': 'policy_effective_till', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'policy_effective_from', 'tgt': 'policy_header__risk_inception_date'},
        {'src': 'rural_yn', 'tgt': 'policy_header__rural_sector_policy_indicator'},
        {'src': 'total_sum_insured', 'tgt': 'policy_header__sum_insured_total'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't3',
      'key_column': "nullif(trim(policy_ref),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': 'issued_date', 'tgt': 'policy_header__issue_date'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_pol_mst',
      'alias': 't4',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_POL_MST',
      'columns': [
        {'src': 'policy_status', 'tgt': 'policy_header__policy_status'},
        {'src': 'policy_end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'policy_start_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_port_wordings',
      'alias': 't5',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PORT_WORDINGS',
      'columns': [
        {'src': 'inception_date', 'tgt': 'policy_header__risk_inception_date'},
        {'src': 'top_indicator', 'tgt': 'policy_header__top_up_policy_indicator'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prime_rider_dtls',
      'alias': 't6',
      'key_column': 'base_policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PRIME_RIDER_DTLS',
      'columns': [
        {'src': 'policy_period', 'tgt': 'policy_header__policy_term'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't7',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pd_policy_period', 'tgt': 'policy_header__policy_term'},
        {'src': 'pd_risk_inception_date', 'tgt': 'policy_header__risk_inception_date'},
        {'src': 'pd_risk_inception_time_hhmm', 'tgt': 'policy_header__risk_start_time'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't8',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'pd_policy_period', 'tgt': 'policy_header__policy_term'},
        {'src': 'pd_risk_end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'pd_risk_inception_date', 'tgt': 'policy_header__risk_inception_date'},
        {'src': 'pd_risk_inception_time_hhmm', 'tgt': 'policy_header__risk_start_time'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't9',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'pd_policy_period', 'tgt': 'policy_header__policy_term'},
        {'src': 'pd_risk_end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'pd_risk_inception_date', 'tgt': 'policy_header__risk_inception_date'},
        {'src': 'pd_risk_inception_time_hhmm', 'tgt': 'policy_header__risk_start_time'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't10',
      'key_column': 'pol_serial_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pd_master_policy_number', 'tgt': 'policy_header__master_policy_reference'},
        {'src': 'pd_policy_period', 'tgt': 'policy_header__policy_term'},
        {'src': 'pd_risk_inception_date', 'tgt': 'policy_header__risk_inception_date'},
        {'src': 'pd_risk_inception_time_hhmm', 'tgt': 'policy_header__risk_start_time'}
      ]
    },
    {
      'model': 'stg_health__bgil_gmc_final_instl_data',
      'alias': 't11',
      'key_column': 'policy_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BGIL_GMC_FINAL_INSTL_DATA',
      'columns': [
        {'src': 'policy_expiry_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'policy_start_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_bandhan_medi_clam',
      'alias': 't12',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BANDHAN_MEDI_CLAM',
      'columns': [
        {'src': 'no_of_years', 'tgt': 'policy_header__policy_term'},
        {'src': 'term_end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'term_start_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_card_dtls',
      'alias': 't13',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CARD_DTLS',
      'columns': [
        {'src': 'status', 'tgt': 'policy_header__policy_status'},
        {'src': 'policy_type', 'tgt': 'policy_header__policy_type'},
        {'src': 'expiry_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'eff_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ecard_pol_dtls_config',
      'alias': 't14',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ECARD_POL_DTLS_CONFIG',
      'columns': [
        {'src': 'policy_status', 'tgt': 'policy_header__policy_status'},
        {'src': 'policy_type', 'tgt': 'policy_header__policy_type'},
        {'src': 'risk_expiry_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'risk_inception_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't15',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'expiry_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'inception_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ehh_pol_dtls',
      'alias': 't16',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EHH_POL_DTLS',
      'columns': [
        {'src': 'referenc_id', 'tgt': 'policy_header__policy_number'},
        {'src': 'pol_period', 'tgt': 'policy_header__policy_term'},
        {'src': 'term_end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'term_start_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_generic_loader_log_table',
      'alias': 't17',
      'key_column': 'pmasterpolicynumber',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GENERIC_LOADER_LOG_TABLE',
      'columns': [
        {'src': 'policyissuedate', 'tgt': 'policy_header__issue_date'},
        {'src': 'premiumpayerid', 'tgt': 'policy_header__premium_payer_reference'},
        {'src': 'ptodate', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'pstartdate', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gpg_pol_dtls',
      'alias': 't18',
      'key_column': 'reference_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GPG_POL_DTLS',
      'columns': [
        {'src': 'policy_period', 'tgt': 'policy_header__policy_term'},
        {'src': 'policy_type', 'tgt': 'policy_header__policy_type'},
        {'src': 'risk_expiry_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'risk_inception_date', 'tgt': 'policy_header__risk_inception_date'},
        {'src': 'risk_inception_time', 'tgt': 'policy_header__risk_start_time'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gp_hospital_cash',
      'alias': 't19',
      'key_column': 'master_policy_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GP_HOSPITAL_CASH',
      'columns': [
        {'src': 'no_of_years', 'tgt': 'policy_header__policy_term'},
        {'src': 'term_end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'term_start_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't20',
      'key_column': 'reg_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'policy_period', 'tgt': 'policy_header__policy_term'},
        {'src': 'policy_type', 'tgt': 'policy_header__policy_type'},
        {'src': 'expiry_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'effective_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't21',
      'key_column': 'reg_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'remarks_branch_ho', 'tgt': 'policy_header__policy_remarks'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hc_part_extn',
      'alias': 't22',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HC_PART_EXTN',
      'columns': [
        {'src': 'inception_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hdfc_sec_fhpp',
      'alias': 't23',
      'key_column': 'reference_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HDFC_SEC_FHPP',
      'columns': [
        {'src': 'no_of_years', 'tgt': 'policy_header__policy_term'},
        {'src': 'no_of_days', 'tgt': 'policy_header__policy_term_days'},
        {'src': 'term_end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'term_start_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_health_webservice_info',
      'alias': 't24',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HEALTH_WEBSERVICE_INFO',
      'columns': [
        {'src': 'policy_period', 'tgt': 'policy_header__policy_term'},
        {'src': 'term_end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'term_start_date', 'tgt': 'policy_header__risk_inception_date'},
        {'src': 'si_flag', 'tgt': 'policy_header__sum_insured_basis'},
        {'src': 'tot_plan_si', 'tgt': 'policy_header__sum_insured_total'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't25',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'pol_period', 'tgt': 'policy_header__policy_term'},
        {'src': 'policy_type', 'tgt': 'policy_header__policy_type'},
        {'src': 'term_end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'term_start_date', 'tgt': 'policy_header__risk_inception_date'},
        {'src': 'total_sum_insured', 'tgt': 'policy_header__sum_insured_total'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_coinsu_clm_dtls',
      'alias': 't26',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_COINSU_CLM_DTLS',
      'columns': [
        {'src': 'valid_upto_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'comncmnt_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't27',
      'key_column': 'policy',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'red', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'rid', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't28',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'term_end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'term_start_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_orphan_reg',
      'alias': 't29',
      'key_column': 'policy_number',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_ORPHAN_REG',
      'columns': [
        {'src': 'end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'start_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ihg_mem_dtls_extn',
      'alias': 't30',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_IHG_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'expiry_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'inception_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_illness_bases_extn',
      'alias': 't31',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ILLNESS_BASES_EXTN',
      'columns': [
        {'src': 'covernote_date', 'tgt': 'policy_header__cover_note_date'},
        {'src': 'covernote_no', 'tgt': 'policy_header__cover_note_reference'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmjay_prmbook_dtls',
      'alias': 't32',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMJAY_PRMBOOK_DTLS',
      'columns': [
        {'src': 'business_flg', 'tgt': 'policy_header__first_year_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_sh_mem_dtls_extn',
      'alias': 't33',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_SH_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'period_of_insurance', 'tgt': 'policy_header__policy_term'},
        {'src': 'expiry_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'inception_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't34',
      'key_column': 'policy_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'policy_type', 'tgt': 'policy_header__policy_type'},
        {'src': 'policy_upto', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'policy_from', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ws_family_dtls_bandhan',
      'alias': 't35',
      'key_column': 'pmasterpolicynumber',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_WS_FAMILY_DTLS_BANDHAN',
      'columns': [
        {'src': 'plan_name', 'tgt': 'policy_header__product_reference'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't36',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': 'remarks', 'tgt': 'policy_header__policy_remarks'},
        {'src': 'policy_period', 'tgt': 'policy_header__policy_term'},
        {'src': 'risk_expiry_time', 'tgt': 'policy_header__risk_end_time'},
        {'src': 'risk_expiry_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'risk_inception_date', 'tgt': 'policy_header__risk_inception_date'},
        {'src': 'risk_inception_time', 'tgt': 'policy_header__risk_start_time'},
        {'src': 'sum_insured', 'tgt': 'policy_header__sum_insured_total'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gmc_bases_extn',
      'alias': 't37',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GMC_BASES_EXTN',
      'columns': [
        {'src': 'inception_date', 'tgt': 'policy_header__risk_inception_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't38',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': 'covernote_date', 'tgt': 'policy_header__cover_note_date'},
        {'src': 'covernote_no', 'tgt': 'policy_header__cover_note_reference'},
        {'src': 'multi_year_flag', 'tgt': 'policy_header__multi_year_indicator'},
        {'src': 'policy_period', 'tgt': 'policy_header__policy_term'},
        {'src': 'term_start_time', 'tgt': 'policy_header__risk_start_time'},
        {'src': 'sum_insured', 'tgt': 'policy_header__sum_insured_total'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't39',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': 'covernote_date', 'tgt': 'policy_header__cover_note_date'},
        {'src': 'covernote_no', 'tgt': 'policy_header__cover_note_reference'},
        {'src': 'coins_flag', 'tgt': 'policy_header__co_insurance_indicator'},
        {'src': 'policy_issue_date', 'tgt': 'policy_header__issue_date'},
        {'src': 'policy_ref', 'tgt': 'policy_header__policy_reference_number'},
        {'src': 'policy_status', 'tgt': 'policy_header__policy_status'},
        {'src': 'term_end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'term_start_date', 'tgt': 'policy_header__risk_inception_date'},
        {'src': 'rural_flag', 'tgt': 'policy_header__rural_sector_policy_indicator'},
        {'src': 'sum_insured', 'tgt': 'policy_header__sum_insured_total'}
      ]
    },
    {
      'model': 'stg_health__bjaz_risk_trans_dtls',
      'alias': 't40',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_RISK_TRANS_DTLS',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_header__policy_reference_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_pol_dtls',
      'alias': 't41',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_POL_DTLS',
      'columns': [
        {'src': 'pol_eff_years', 'tgt': 'policy_header__policy_term'},
        {'src': 'pol_eff_end_date', 'tgt': 'policy_header__risk_expiry_date'},
        {'src': 'pol_eff_start_date', 'tgt': 'policy_header__risk_inception_date'},
        {'src': 'pol_eff_time', 'tgt': 'policy_header__risk_start_time'},
        {'src': 'total_si', 'tgt': 'policy_header__sum_insured_total'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_header__issuing_org_unit_code',
    'policy_header__policy_reference_number',
    'policy_header__policy_remarks',
    'policy_header__premium_payer_reference',
    'policy_header__product_reference',
    'policy_header__policy_type',
    'policy_header__sum_insured_basis',
    'policy_header__co_insurance_indicator',
    'policy_header__issuing_channel_reference',
    'policy_header__line_of_business',
    'policy_header__policy_term_days',
    'policy_header__risk_expiry_date',
    'policy_header__risk_inception_date',
    'policy_header__rural_sector_policy_indicator',
    'policy_header__sum_insured_total',
    'policy_header__issue_date',
    'policy_header__policy_status',
    'policy_header__top_up_policy_indicator',
    'policy_header__policy_term',
    'policy_header__risk_start_time',
    'policy_header__master_policy_reference',
    'policy_header__policy_number',
    'policy_header__cover_note_date',
    'policy_header__cover_note_reference',
    'policy_header__first_year_indicator',
    'policy_header__risk_end_time',
    'policy_header__multi_year_indicator'
] -%}
{%- set coalesce_rules = {
    'policy_header__issuing_org_unit_code': ['t0', 't2'],
    'policy_header__policy_reference_number': ['t0', 't1', 't39', 't40'],
    'policy_header__policy_remarks': ['t0', 't1', 't21', 't36'],
    'policy_header__premium_payer_reference': ['t0', 't17'],
    'policy_header__product_reference': ['t0', 't1', 't2', 't35'],
    'policy_header__policy_type': ['t1', 't13', 't14', 't18', 't20', 't25', 't34'],
    'policy_header__sum_insured_basis': ['t1', 't24'],
    'policy_header__co_insurance_indicator': ['t2', 't39'],
    'policy_header__issuing_channel_reference': ['t2'],
    'policy_header__line_of_business': ['t2'],
    'policy_header__policy_term_days': ['t2', 't23'],
    'policy_header__risk_expiry_date': ['t2', 't4', 't8', 't9', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't33', 't34', 't36', 't39', 't41'],
    'policy_header__risk_inception_date': ['t2', 't4', 't5', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't33', 't34', 't36', 't37', 't39', 't41'],
    'policy_header__rural_sector_policy_indicator': ['t2', 't39'],
    'policy_header__sum_insured_total': ['t2', 't24', 't25', 't36', 't38', 't39', 't41'],
    'policy_header__issue_date': ['t3', 't17', 't39'],
    'policy_header__policy_status': ['t4', 't13', 't14', 't39'],
    'policy_header__top_up_policy_indicator': ['t5'],
    'policy_header__policy_term': ['t6', 't7', 't8', 't9', 't10', 't12', 't16', 't18', 't19', 't20', 't23', 't24', 't25', 't33', 't36', 't38', 't41'],
    'policy_header__risk_start_time': ['t7', 't8', 't9', 't10', 't18', 't36', 't38', 't41'],
    'policy_header__master_policy_reference': ['t10'],
    'policy_header__policy_number': ['t16'],
    'policy_header__cover_note_date': ['t31', 't38', 't39'],
    'policy_header__cover_note_reference': ['t31', 't38', 't39'],
    'policy_header__first_year_indicator': ['t32'],
    'policy_header__risk_end_time': ['t36'],
    'policy_header__multi_year_indicator': ['t38']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_policy_header'
) }}
