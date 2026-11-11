{{ config(materialized='view') }}
-- This part feeds SAT_PARTY_IDENTIFICATION only. Original precedence comments are kept below (from stitch_v16_party).
-- CENTRAL VIEW v16_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_INTERMEDIARY (opus_health_v2)
--   BJAZ_NEFT_PARTNER_DTLS (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER_EXTN (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_POLICY_SUMMARY (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_PARTY_CONSENT_MANDATE
--   SAT_AUG_PARTY_IDENTIFICATION
--   SAT_AUG_PARTY_PAYOUT_PROFILE
--   SAT_COMMON_CLASSIFICATION
--   SAT_LNK_PARTY_ROLE_CORE
--   SAT_LNK_ROLE_AGENT
--   SAT_PARTY_CONSENT_MANDATE
--   SAT_PARTY_HIERARCHY
--   SAT_PARTY_IDENTIFICATION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_CHANNEL
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_preauth_request') }}
-- depends_on: {{ ref('stg_health__bjaz_intermediary') }}
-- depends_on: {{ ref('stg_health__bjaz_neft_partner_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_inward_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_claim_details') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_summary') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_preauth_request',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif('HEALTHCARD:' || nullif(trim(insured_card_no),''), 'HEALTHCARD:'))) || '|' || 'EMPLOYEE_ID'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_REQUEST',
      'columns': [
        {'src': "nullif('HEALTHCARD:' || nullif(trim(insured_card_no),''), 'HEALTHCARD:')", 'tgt': 'party_bk'},
        {'src': "'EMPLOYEE_ID'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'emp_id', 'tgt': 'party_identification__identification_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_intermediary',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(intermediary_id),''))) || '|' || 'PAN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_INTERMEDIARY',
      'columns': [
        {'src': "nullif(trim(intermediary_id),'')", 'tgt': 'party_bk'},
        {'src': "'PAN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pan_number', 'tgt': 'party_identification__pan_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_intermediary',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(intermediary_id),''))) || '|' || 'GSTIN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_INTERMEDIARY',
      'columns': [
        {'src': "nullif(trim(intermediary_id),'')", 'tgt': 'party_bk'},
        {'src': "'GSTIN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'gst_no', 'tgt': 'party_identification__gstin'},
        {'src': 'gst_status', 'tgt': 'party_identification__gst_registration_status'}
      ]
    },
    {
      'model': 'stg_health__bjaz_neft_partner_dtls',
      'alias': 't3',
      'key_column': "trim(to_varchar(nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:'))) || '|' || 'SUPPLIER_ID'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_NEFT_PARTNER_DTLS',
      'columns': [
        {'src': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')", 'tgt': 'party_bk'},
        {'src': "'SUPPLIER_ID'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'supplier_id', 'tgt': 'party_identification__identification_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't4',
      'key_column': "trim(to_varchar(nullif(trim(cust_id),''))) || '|' || 'AADHAAR'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': "nullif(trim(cust_id),'')", 'tgt': 'party_bk'},
        {'src': "'AADHAAR'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'aadharno', 'tgt': 'party_identification__aadhaar_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't5',
      'key_column': "trim(to_varchar(nullif(trim(cust_id),''))) || '|' || 'PAN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': "nullif(trim(cust_id),'')", 'tgt': 'party_bk'},
        {'src': "'PAN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pancardno', 'tgt': 'party_identification__pan_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't6',
      'key_column': "pd_premium_payer_id || '|' || 'BANK_CUSTOMER_ID'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'BANK_CUSTOMER_ID'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_bank_ref_no2_bank_cust_id', 'tgt': 'party_identification__identification_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't7',
      'key_column': "pd_premium_payer_id || '|' || 'PAN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'PAN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_pan_no', 'tgt': 'party_identification__pan_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't8',
      'key_column': "pd_premium_payer_id || '|' || 'AADHAAR'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'AADHAAR'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_adhar_card_no', 'tgt': 'party_identification__aadhaar_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't9',
      'key_column': "pd_premium_payer_id || '|' || 'EIA'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'EIA'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_electronic_insur_account_no', 'tgt': 'party_identification__eia_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't10',
      'key_column': "pd_premium_payer_id || '|' || 'GSTIN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'GSTIN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'gstin_uin', 'tgt': 'party_identification__gstin'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't11',
      'key_column': "pd_premium_payer_id || '|' || 'PAN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'PAN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_pan_no', 'tgt': 'party_identification__pan_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't12',
      'key_column': "pd_premium_payer_id || '|' || 'AADHAAR'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'AADHAAR'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_adhar_card_no', 'tgt': 'party_identification__aadhaar_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't13',
      'key_column': "pd_premium_payer_id || '|' || 'EIA'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'EIA'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_electronic_insur_account_no', 'tgt': 'party_identification__eia_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't14',
      'key_column': "pd_premium_payer_id || '|' || 'GSTIN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'GSTIN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'gstin_uin', 'tgt': 'party_identification__gstin'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't15',
      'key_column': "pd_premium_payer_id || '|' || 'PAN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'PAN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_pan_no', 'tgt': 'party_identification__pan_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't16',
      'key_column': "pd_premium_payer_id || '|' || 'AADHAAR'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'AADHAAR'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_adhar_card_no', 'tgt': 'party_identification__aadhaar_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't17',
      'key_column': "pd_premium_payer_id || '|' || 'EIA'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'EIA'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_electronic_insur_account_no', 'tgt': 'party_identification__eia_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't18',
      'key_column': "pd_premium_payer_id || '|' || 'GSTIN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'GSTIN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'gstin_uin', 'tgt': 'party_identification__gstin'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't19',
      'key_column': "pd_premium_payer_id || '|' || 'PAN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'PAN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_pan_no', 'tgt': 'party_identification__pan_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't20',
      'key_column': "pd_premium_payer_id || '|' || 'AADHAAR'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'AADHAAR'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_a_card_no', 'tgt': 'party_identification__aadhaar_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't21',
      'key_column': "pd_premium_payer_id || '|' || 'EIA'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'EIA'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pd_electronic_insur_account_no', 'tgt': 'party_identification__eia_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't22',
      'key_column': "pd_premium_payer_id || '|' || 'GSTIN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'GSTIN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'gstin_uin', 'tgt': 'party_identification__gstin'}
      ]
    },
    {
      'model': 'stg_health__bjaz_bandhan_medi_clam',
      'alias': 't23',
      'key_column': "customer_id || '|' || 'PAN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BANDHAN_MEDI_CLAM',
      'columns': [
        {'src': 'customer_id', 'tgt': 'party_bk'},
        {'src': "'PAN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pan_no', 'tgt': 'party_identification__pan_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_bandhan_medi_clam',
      'alias': 't24',
      'key_column': "customer_id || '|' || 'AADHAAR'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BANDHAN_MEDI_CLAM',
      'columns': [
        {'src': 'customer_id', 'tgt': 'party_bk'},
        {'src': "'AADHAAR'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'aadhaar_number', 'tgt': 'party_identification__aadhaar_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_bandhan_medi_clam',
      'alias': 't25',
      'key_column': "customer_id || '|' || 'GSTIN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BANDHAN_MEDI_CLAM',
      'columns': [
        {'src': 'customer_id', 'tgt': 'party_bk'},
        {'src': "'GSTIN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'gst_reg_no', 'tgt': 'party_identification__gstin'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't26',
      'key_column': "member_no || '|' || 'AGE_PROOF'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'member_no', 'tgt': 'party_bk'},
        {'src': "'AGE_PROOF'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'age_proof', 'tgt': 'party_identification__age_proof_type'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gpg_pol_dtls',
      'alias': 't27',
      'key_column': "bagic_e_code || '|' || 'GSTIN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GPG_POL_DTLS',
      'columns': [
        {'src': 'bagic_e_code', 'tgt': 'party_bk'},
        {'src': "'GSTIN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'partner_gstn', 'tgt': 'party_identification__gstin'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't28',
      'key_column': "part_id || '|' || 'AADHAAR'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'part_id', 'tgt': 'party_bk'},
        {'src': "'AADHAAR'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'aadhaar_no', 'tgt': 'party_identification__aadhaar_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't29',
      'key_column': "part_id || '|' || 'PAN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'part_id', 'tgt': 'party_bk'},
        {'src': "'PAN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pan_number', 'tgt': 'party_identification__pan_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't30',
      'key_column': "part_id || '|' || 'GSTIN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'part_id', 'tgt': 'party_bk'},
        {'src': "'GSTIN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'partner_gstn', 'tgt': 'party_identification__gstin'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hlt_ensure_mem_dtls',
      'alias': 't31',
      'key_column': "member_no || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HLT_ENSURE_MEM_DTLS',
      'columns': [
        {'src': 'member_no', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'age_proof_yn', 'tgt': 'party_identification__age_proof_type'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't32',
      'key_column': "hospital_id || '|' || 'HEALTH_CARD'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'hospital_id', 'tgt': 'party_bk'},
        {'src': "'HEALTH_CARD'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'id_card', 'tgt': 'party_identification__identification_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't33',
      'key_column': "hospital_id || '|' || 'PAN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'hospital_id', 'tgt': 'party_bk'},
        {'src': "'PAN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pan_no', 'tgt': 'party_identification__pan_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master',
      'alias': 't34',
      'key_column': "hosid || '|' || 'SERVICE_TAX_REG'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': "'SERVICE_TAX_REG'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'stax_reg_no', 'tgt': 'party_identification__identification_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't35',
      'key_column': "hosid || '|' || 'TAN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': "'TAN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'tan_no', 'tgt': 'party_identification__tan_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't36',
      'key_column': "hosid || '|' || 'IRDA_ID'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': "'IRDA_ID'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'irda_unique_id', 'tgt': 'party_identification__identification_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't37',
      'key_column': "hosid || '|' || 'ROHINI'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': "'ROHINI'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'rohini_code', 'tgt': 'party_identification__identification_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_inward_dtls',
      'alias': 't38',
      'key_column': "courier_id || '|' || 'PASSPORT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_INWARD_DTLS',
      'columns': [
        {'src': 'courier_id', 'tgt': 'party_bk'},
        {'src': "'PASSPORT'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'passport_no', 'tgt': 'party_identification__passport_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ihg_mem_dtls_extn',
      'alias': 't39',
      'key_column': "member_no || '|' || 'AGE_PROOF'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_IHG_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'member_no', 'tgt': 'party_bk'},
        {'src': "'AGE_PROOF'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'age_proof', 'tgt': 'party_identification__age_proof_type'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_claim_details',
      'alias': 't40',
      'key_column': "payer_code || '|' || 'IRDA_ID'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_CLAIM_DETAILS',
      'columns': [
        {'src': 'payer_code', 'tgt': 'party_bk'},
        {'src': "'IRDA_ID'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'irda_id', 'tgt': 'party_identification__identification_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't41',
      'key_column': "customer_id || '|' || 'PAN'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'customer_id', 'tgt': 'party_bk'},
        {'src': "'PAN'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'pan_no', 'tgt': 'party_identification__pan_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't42',
      'key_column': "trim(to_varchar(nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:'))) || '|' || 'SUPPLIER_ID'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')", 'tgt': 'party_bk'},
        {'src': "'SUPPLIER_ID'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'supp_id', 'tgt': 'party_identification__identification_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't43',
      'key_column': "trim(to_varchar(nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:'))) || '|' || 'WORKSHOP_ID'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')", 'tgt': 'party_bk'},
        {'src': "'WORKSHOP_ID'", 'tgt': 'party_identification__identification_type_code_ck'},
        {'src': 'workshop_id', 'tgt': 'party_identification__identification_number'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_bk',
    'party_identification__identification_type_code_ck',
    'party_identification__identification_number',
    'party_identification__pan_number',
    'party_identification__gstin',
    'party_identification__gst_registration_status',
    'party_identification__aadhaar_number',
    'party_identification__eia_number',
    'party_identification__age_proof_type',
    'party_identification__tan_number',
    'party_identification__passport_number'
] -%}
{%- set coalesce_rules = {
    'party_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't31', 't32', 't33', 't34', 't35', 't36', 't37', 't38', 't39', 't40', 't41', 't42', 't43'],
    'party_identification__identification_type_code_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't31', 't32', 't33', 't34', 't35', 't36', 't37', 't38', 't39', 't40', 't41', 't42', 't43'],
    'party_identification__identification_number': ['t0', 't3', 't6', 't32', 't34', 't36', 't37', 't40', 't42', 't43'],
    'party_identification__pan_number': ['t1', 't5', 't7', 't11', 't15', 't19', 't23', 't29', 't33', 't41'],
    'party_identification__gstin': ['t2', 't10', 't14', 't18', 't22', 't25', 't27', 't30'],
    'party_identification__gst_registration_status': ['t2'],
    'party_identification__aadhaar_number': ['t4', 't8', 't12', 't16', 't20', 't24', 't28'],
    'party_identification__eia_number': ['t9', 't13', 't17', 't21'],
    'party_identification__age_proof_type': ['t26', 't31', 't39'],
    'party_identification__tan_number': ['t35'],
    'party_identification__passport_number': ['t38']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_identification_pk',
    target_sat='sat_party_identification'
) }}
