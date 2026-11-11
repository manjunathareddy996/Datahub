{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_DISCOUNT_LOADING_APPLIED only. Original precedence comments are kept below (from stitch_v27_policy).
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
-- depends_on: {{ ref('stg_health__ba_hcp_dt_premium') }}
-- depends_on: {{ ref('stg_health__ba_hcp_pol_mst') }}
-- depends_on: {{ ref('stg_health__bjaz_health_webservice_info') }}
-- depends_on: {{ ref('stg_health__ba_ccp_sub_mater_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_summary') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'ADDITIONAL_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'ADDITIONAL_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'additional_loading', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'LOADING_FAMILY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'LOADING_FAMILY'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'reason_for_loading', 'tgt': 'policy_discount_loading_applied__justification'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'OTHER_DISCOUNT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'OTHER_DISCOUNT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'other_discount', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't3',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'DISCOUNT_FAMILY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'DISCOUNT_FAMILY'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'reason_for_discount', 'tgt': 'policy_discount_loading_applied__justification'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't4',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'SPECIAL_DISCOUNT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'SPECIAL_DISCOUNT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'special_discount', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't5',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'SPECIAL_DISC'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'SPECIAL_DISC'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'special_disc', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't6',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'UW_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'UW_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'uw_load_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'uw_load_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't7',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'COMMERCIAL_DISC'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'COMMERCIAL_DISC'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'commercial_disc_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'commercial_disc_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_dt_premium',
      'alias': 't8',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_PREMIUM',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'coalesce(additional_load_amt, addon_cov_disc_amt, cd_amt, claim_free_renewal_disc_amt, direct_cust_disc_amt, disc_in_lieu_agency_comm_amt, emp_disc_amt, family_disc_amt, good_health_disc_amt, loading_amt, long_term_policy_disc_amt, online_disc_amt, sp_disc_amt, uw_loading_amt, voluntary_deduct_amt)', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'coalesce(additional_load_rate, addon_cov_disc_rate, cd_rate, claim_free_renewal_disc_rate, direct_cust_disc_rate, disc_in_lieu_agency_comm_rate, emp_disc_rate, family_disc_rate, good_health_disc_rate, loading_rate, long_term_policy_disc, online_disc_rate, sp_disc_rate, uw_loading_rate, voluntary_deduct_rate)', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_pol_mst',
      'alias': 't9',
      'key_column': "contract_id || '|' || 'CTO_CEO_DISCOUNT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_POL_MST',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': "'CTO_CEO_DISCOUNT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'cto_ceo_discount', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_pol_mst',
      'alias': 't10',
      'key_column': "contract_id || '|' || 'CTO_CEO_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_POL_MST',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': "'CTO_CEO_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'cto_ceo_loading', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_pol_mst',
      'alias': 't11',
      'key_column': "contract_id || '|' || 'CLAIM_DISCOUNT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_POL_MST',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': "'CLAIM_DISCOUNT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'claim_discount', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_pol_mst',
      'alias': 't12',
      'key_column': "contract_id || '|' || 'CLAIM_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_POL_MST',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': "'CLAIM_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'claim_loading', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_health_webservice_info',
      'alias': 't13',
      'key_column': "policy_ref || '|' || 'GRID_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HEALTH_WEBSERVICE_INFO',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': "'GRID_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'grid_load', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'grid_load_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_health_webservice_info',
      'alias': 't14',
      'key_column': "policy_ref || '|' || 'UW_LOAD'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HEALTH_WEBSERVICE_INFO',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': "'UW_LOAD'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'uw_load_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'uw_load_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_health_webservice_info',
      'alias': 't15',
      'key_column': "policy_ref || '|' || 'OTHER_DISCOUNT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HEALTH_WEBSERVICE_INFO',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': "'OTHER_DISCOUNT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'other_discount', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_health_webservice_info',
      'alias': 't16',
      'key_column': "policy_ref || '|' || 'DISCOUNT_FAMILY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HEALTH_WEBSERVICE_INFO',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': "'DISCOUNT_FAMILY'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'family_discount', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_health_webservice_info',
      'alias': 't17',
      'key_column': "policy_ref || '|' || 'UW_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HEALTH_WEBSERVICE_INFO',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': "'UW_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'uw_loading_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'uw_loading_per', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_health_webservice_info',
      'alias': 't18',
      'key_column': "policy_ref || '|' || 'COMMERCIAL_DISC'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HEALTH_WEBSERVICE_INFO',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': "'COMMERCIAL_DISC'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'commercial_discount', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'commercial_discount_per', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_health_webservice_info',
      'alias': 't19',
      'key_column': "policy_ref || '|' || 'MEMBER_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HEALTH_WEBSERVICE_INFO',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': "'MEMBER_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'member_loading', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't20',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'FAB_DISCOUNT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'FAB_DISCOUNT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'fab_cd_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'fab_cd_per', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't21',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'FAB_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'FAB_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'fab_load_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'fab_load_per', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't22',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'FAC_DISCOUNT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'FAC_DISCOUNT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'fac_cd_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'fac_cd_per', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't23',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'FAC_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'FAC_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'fac_load_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'fac_load_per', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't24',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'BRC_DISCOUNT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'BRC_DISCOUNT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'brc_cd_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'brc_cd_per', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't25',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'BRC_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'BRC_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'brc_load_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'brc_load_per', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't26',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'BRJ_DISCOUNT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'BRJ_DISCOUNT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'brj_cd_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'brj_cd_per', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't27',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'BRJ_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'BRJ_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'brj_load_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'brj_load_per', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't28',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'TERRORISM_SURCHARGE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'TERRORISM_SURCHARGE'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'terr_surcharge', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't29',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'ADDITIONAL_DISCOUNT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'ADDITIONAL_DISCOUNT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'add_disc_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'add_disc_reason', 'tgt': 'policy_discount_loading_applied__justification'},
        {'src': 'add_disc_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't30',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'ADDITIONAL_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'ADDITIONAL_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'add_load_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'add_load_reason', 'tgt': 'policy_discount_loading_applied__justification'},
        {'src': 'add_load_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't31',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'ADDITIONAL_LOADING_ADJ'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'ADDITIONAL_LOADING_ADJ'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'adj_add_load_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't32',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'COMMERCIAL_DISC'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'COMMERCIAL_DISC'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'commercial_disc_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'commercial_disc_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't33',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'COMMERCIAL_DISC_ADJ'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'COMMERCIAL_DISC_ADJ'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'adj_cm_disc_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't34',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'LONG_TERM_DISC'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'LONG_TERM_DISC'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'lterm_disc_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'lterm_disc_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't35',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'MPMP_DISC'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'MPMP_DISC'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'mpmp_disc_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'mpmp_disc_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't36',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'RENEWAL_DISC'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'RENEWAL_DISC'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'renewal_disc_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'renewal_disc_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't37',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'SPECIAL_DISCOUNT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'SPECIAL_DISCOUNT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'special_disc_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'special_disc_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't38',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'UW_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'UW_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'uw_load_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'uw_load_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't39',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'UW_LOADING_ADJ'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'UW_LOADING_ADJ'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'adj_uw_load_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't40',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'SERVICE_CHARGE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'SERVICE_CHARGE'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'service_charge_amt', 'tgt': 'policy_discount_loading_applied__amount_applied'},
        {'src': 'service_charge_rate', 'tgt': 'policy_discount_loading_applied__percentage_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't41',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'TERRORISM_SURCHARGE_ENDORSEMENT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'TERRORISM_SURCHARGE_ENDORSEMENT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'endorse_terr_surcharge', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't42',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'TERRORISM_SURCHARGE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'TERRORISM_SURCHARGE'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'terr_surcharge', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't43',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'SPECIAL_DISCOUNT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'SPECIAL_DISCOUNT'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'special_disc', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_pol_dtls',
      'alias': 't44',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'UW_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_POL_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'UW_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'uw_load', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_pol_dtls',
      'alias': 't45',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'CI_LOADING'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_POL_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'CI_LOADING'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'ci_load', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_pol_dtls',
      'alias': 't46',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'COMMERCIAL_DISC'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_POL_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'COMMERCIAL_DISC'", 'tgt': 'policy_discount_loading_applied__item_code_ck'},
        {'src': 'comm_disc', 'tgt': 'policy_discount_loading_applied__amount_applied'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'policy_discount_loading_applied__item_code_ck',
    'policy_discount_loading_applied__amount_applied',
    'policy_discount_loading_applied__justification',
    'policy_discount_loading_applied__percentage_applied'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't31', 't32', 't33', 't34', 't35', 't36', 't37', 't38', 't39', 't40', 't41', 't42', 't43', 't44', 't45', 't46'],
    'policy_discount_loading_applied__item_code_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't31', 't32', 't33', 't34', 't35', 't36', 't37', 't38', 't39', 't40', 't41', 't42', 't43', 't44', 't45', 't46'],
    'policy_discount_loading_applied__amount_applied': ['t0', 't2', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't31', 't32', 't33', 't34', 't35', 't36', 't37', 't38', 't39', 't40', 't41', 't42', 't43', 't44', 't45', 't46'],
    'policy_discount_loading_applied__justification': ['t1', 't3', 't29', 't30'],
    'policy_discount_loading_applied__percentage_applied': ['t6', 't7', 't8', 't13', 't14', 't17', 't18', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't29', 't30', 't32', 't34', 't35', 't36', 't37', 't38', 't40']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_discount_loading_applied_pk',
    target_sat='sat_policy_discount_loading_applied'
) }}
