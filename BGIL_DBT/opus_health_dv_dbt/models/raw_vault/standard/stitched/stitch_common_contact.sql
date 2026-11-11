{{ config(materialized='view') }}
-- This part feeds SAT_COMMON_CONTACT only. Original precedence comments are kept below (from stitch_v15_party).
-- CENTRAL VIEW v15_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_INTERMEDIARY (opus_health_v2)
--   BJAZ_NEFT_PARTNER_DTLS (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_PP_MEM_DTLS (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER_EXTN (opus_health_legacy_v4)
--   BJAZ_HM_HOSP_MASTER_EXTN1 (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_POLICY_SUMMARY (opus_health_delta3)
--   BJAZ_REMEDINET_PATIENT_DETAILS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_COMMON_CONTACT
--   SAT_AUG_PARTY_HEALTH_PROFILE
--   SAT_AUG_PARTY_IDENTITY
--   SAT_AUG_PROVIDER_QUALITY
--   SAT_COMMON_CONTACT
--   SAT_PARTY_BANKING
--   SAT_PARTY_ORGANISATION_PROFILE
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_preauth_request') }}
-- depends_on: {{ ref('stg_health__bjaz_intermediary') }}
-- depends_on: {{ ref('stg_health__bjaz_neft_partner_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
-- depends_on: {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_inward_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_summary') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_patient_details') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif('EMP:' || nullif(trim(rm_code),''), 'EMP:'))) || '|' || 'EMAIL' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': "nullif('EMP:' || nullif(trim(rm_code),''), 'EMP:')", 'tgt': 'party_bk'},
        {'src': "'EMAIL'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'rm_email', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(ph_id),''))) || '|' || 'MOBILE' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': "nullif(trim(ph_id),'')", 'tgt': 'party_bk'},
        {'src': "'MOBILE'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'contact_detail', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(ph_id),''))) || '|' || 'EMAIL_CORPORATE' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': "nullif(trim(ph_id),'')", 'tgt': 'party_bk'},
        {'src': "'EMAIL_CORPORATE'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'corp_email', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't3',
      'key_column': "trim(to_varchar(nullif(trim(ph_id),''))) || '|' || 'EMAIL_AUTO_MAILER' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': "nullif(trim(ph_id),'')", 'tgt': 'party_bk'},
        {'src': "'EMAIL_AUTO_MAILER'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'auto_mailer_email', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_preauth_request',
      'alias': 't4',
      'key_column': "trim(to_varchar(nullif('HEALTHCARD:' || nullif(trim(patient_id_card),''), 'HEALTHCARD:'))) || '|' || 'MOBILE' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_REQUEST',
      'columns': [
        {'src': "nullif('HEALTHCARD:' || nullif(trim(patient_id_card),''), 'HEALTHCARD:')", 'tgt': 'party_bk'},
        {'src': "'MOBILE'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'patient_contact_no', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_preauth_request',
      'alias': 't5',
      'key_column': "trim(to_varchar(nullif('HEALTHCARD:' || nullif(trim(insured_card_no),''), 'HEALTHCARD:'))) || '|' || 'EMAIL' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_REQUEST',
      'columns': [
        {'src': "nullif('HEALTHCARD:' || nullif(trim(insured_card_no),''), 'HEALTHCARD:')", 'tgt': 'party_bk'},
        {'src': "'EMAIL'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'insured_email', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__bjaz_intermediary',
      'alias': 't6',
      'key_column': "trim(to_varchar(nullif(trim(intermediary_id),''))) || '|' || 'EMAIL' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_INTERMEDIARY',
      'columns': [
        {'src': "nullif(trim(intermediary_id),'')", 'tgt': 'party_bk'},
        {'src': "'EMAIL'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'username', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__bjaz_neft_partner_dtls',
      'alias': 't7',
      'key_column': "trim(to_varchar(nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:'))) || '|' || 'MOBILE' || '|' || '1'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_NEFT_PARTNER_DTLS',
      'columns': [
        {'src': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')", 'tgt': 'party_bk'},
        {'src': "'MOBILE'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': "'1'", 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'mobile_no', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_neft_partner_dtls',
      'alias': 't8',
      'key_column': "trim(to_varchar(nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:'))) || '|' || 'EMAIL' || '|' || '1'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_NEFT_PARTNER_DTLS',
      'columns': [
        {'src': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')", 'tgt': 'party_bk'},
        {'src': "'EMAIL'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': "'1'", 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'email_id', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__bjaz_neft_partner_dtls',
      'alias': 't9',
      'key_column': "trim(to_varchar(nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:'))) || '|' || 'EMAIL' || '|' || '2'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_NEFT_PARTNER_DTLS',
      'columns': [
        {'src': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')", 'tgt': 'party_bk'},
        {'src': "'EMAIL'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': "'2'", 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'email_id_2', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__bjaz_neft_partner_dtls',
      'alias': 't10',
      'key_column': "trim(to_varchar(nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:'))) || '|' || 'EMAIL' || '|' || '3'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_NEFT_PARTNER_DTLS',
      'columns': [
        {'src': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')", 'tgt': 'party_bk'},
        {'src': "'EMAIL'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': "'3'", 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'email_id_3', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__bjaz_neft_partner_dtls',
      'alias': 't11',
      'key_column': "trim(to_varchar(nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:'))) || '|' || 'LANDLINE' || '|' || '2'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_NEFT_PARTNER_DTLS',
      'columns': [
        {'src': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')", 'tgt': 'party_bk'},
        {'src': "'LANDLINE'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': "'2'", 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'branch_contact_no_2', 'tgt': 'common_contact__landline_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't12',
      'key_column': "trim(to_varchar(nullif(trim(cust_id),''))) || '|' || 'MOBILE' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': "nullif(trim(cust_id),'')", 'tgt': 'party_bk'},
        {'src': "'MOBILE'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'mobileno', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't13',
      'key_column': "trim(to_varchar(nullif(trim(cust_id),''))) || '|' || 'EMAIL' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': "nullif(trim(cust_id),'')", 'tgt': 'party_bk'},
        {'src': "'EMAIL'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'emailid', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_pp_mem_dtls',
      'alias': 't14',
      'key_column': "alloted_to || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PP_MEM_DTLS',
      'columns': [
        {'src': 'alloted_to', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'dc_teleno', 'tgt': 'common_contact__landline_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't15',
      'key_column': "pd_premium_payer_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'coalesce(pd_agent_email_id, pd_email)', 'tgt': 'common_contact__email_address'},
        {'src': 'pd_fax', 'tgt': 'common_contact__fax_number'},
        {'src': 'pd_telephone', 'tgt': 'common_contact__landline_number'},
        {'src': 'pd_mobile_number', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't16',
      'key_column': "pd_premium_payer_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'coalesce(pd_agent_email_id, pd_email)', 'tgt': 'common_contact__email_address'},
        {'src': 'pd_fax', 'tgt': 'common_contact__fax_number'},
        {'src': 'pd_telephone', 'tgt': 'common_contact__landline_number'},
        {'src': 'pd_mobile_number', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't17',
      'key_column': "pd_premium_payer_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'coalesce(pd_agent_email_id, pd_email)', 'tgt': 'common_contact__email_address'},
        {'src': 'pd_fax', 'tgt': 'common_contact__fax_number'},
        {'src': 'pd_telephone', 'tgt': 'common_contact__landline_number'},
        {'src': 'pd_mobile_number', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't18',
      'key_column': "pd_premium_payer_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'coalesce(pd_agent_email_id, pd_email)', 'tgt': 'common_contact__email_address'},
        {'src': 'pd_fax', 'tgt': 'common_contact__fax_number'},
        {'src': 'pd_telephone', 'tgt': 'common_contact__landline_number'},
        {'src': 'pd_mobile_number', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_bandhan_medi_clam',
      'alias': 't19',
      'key_column': "customer_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BANDHAN_MEDI_CLAM',
      'columns': [
        {'src': 'customer_id', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'm_email', 'tgt': 'common_contact__alternate_email_address'},
        {'src': 'm_mobile', 'tgt': 'common_contact__alternate_mobile_number'},
        {'src': 'p_email', 'tgt': 'common_contact__email_address'},
        {'src': 'mobile', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_id_mem_detls',
      'alias': 't20',
      'key_column': "member_no || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_ID_MEM_DETLS',
      'columns': [
        {'src': 'member_no', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'email_id', 'tgt': 'common_contact__email_address'},
        {'src': 'tel', 'tgt': 'common_contact__landline_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't21',
      'key_column': "part_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'part_id', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'email_cust', 'tgt': 'common_contact__alternate_email_address'},
        {'src': 'email', 'tgt': 'common_contact__email_address'},
        {'src': 'telephone', 'tgt': 'common_contact__landline_number'},
        {'src': 'mobile_no', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't22',
      'key_column': "hospital_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'hospital_id', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'fax', 'tgt': 'common_contact__fax_number'},
        {'src': 'coalesce(phone, telephone)', 'tgt': 'common_contact__landline_number'},
        {'src': 'mobile_no', 'tgt': 'common_contact__mobile_number'},
        {'src': 'std', 'tgt': 'common_contact__std_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master',
      'alias': 't23',
      'key_column': "hosid || '|' || 'STD' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': "'STD'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'std_code', 'tgt': 'common_contact__std_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master',
      'alias': 't24',
      'key_column': "hosid || '|' || 'LANDLINE' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': "'LANDLINE'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'phone_no', 'tgt': 'common_contact__landline_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master',
      'alias': 't25',
      'key_column': "hosid || '|' || 'FAX' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': "'FAX'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'fax_no', 'tgt': 'common_contact__fax_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master',
      'alias': 't26',
      'key_column': "hosid || '|' || 'EMAIL' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': "'EMAIL'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'email', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't27',
      'key_column': "hosid || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'email_fin_dept', 'tgt': 'common_contact__email_address'},
        {'src': 'fax_no2', 'tgt': 'common_contact__fax_number'},
        {'src': 'phone_no2', 'tgt': 'common_contact__landline_number'},
        {'src': 'coalesce(mob_fin_officer, mobile_no)', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hosp_master_extn1',
      'alias': 't28',
      'key_column': "hosid || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSP_MASTER_EXTN1',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'coalesce(adminemail, billingemail, ceoemail, meddiremail, medsupernameemail, mktheademail, tpaemail)', 'tgt': 'common_contact__email_address'},
        {'src': 'coalesce(adminmobileno, billingmobileno, ceomobileno, meddirmob, medsupernamemobno, mktheadmobileno)', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_inward_dtls',
      'alias': 't29',
      'key_column': "courier_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_INWARD_DTLS',
      'columns': [
        {'src': 'courier_id', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'coalesce(caller_email_id, email_id, insured_email_id)', 'tgt': 'common_contact__email_address'},
        {'src': 'coalesce(caller_contact_no, insured_contact_no, mobile_no)', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't30',
      'key_column': "member_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'member_id', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'email_id', 'tgt': 'common_contact__email_address'},
        {'src': 'phone_no', 'tgt': 'common_contact__landline_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_sh_mem_dtls_extn',
      'alias': 't31',
      'key_column': "member_no || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_SH_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'member_no', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'email_id', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't32',
      'key_column': "customer_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'customer_id', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'email_id_1', 'tgt': 'common_contact__email_address'},
        {'src': 'mob_no', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't33',
      'key_column': "trim(to_varchar(nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:'))) || '|' || 'MOBILE | Contact Priority Order = 1' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')", 'tgt': 'party_bk'},
        {'src': "'MOBILE | Contact Priority Order = 1'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'mobile_no', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't34',
      'key_column': "trim(to_varchar(nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:'))) || '|' || 'EMAIL | Contact Priority Order = 1' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')", 'tgt': 'party_bk'},
        {'src': "'EMAIL | Contact Priority Order = 1'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'mailid', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_patient_details',
      'alias': 't35',
      'key_column': "trim(to_varchar(nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:'))) || '|' || 'MOBILE | Contact Priority Order = 1' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_PATIENT_DETAILS',
      'columns': [
        {'src': "nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:')", 'tgt': 'party_bk'},
        {'src': "'MOBILE | Contact Priority Order = 1'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'mobile_no', 'tgt': 'common_contact__mobile_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_patient_details',
      'alias': 't36',
      'key_column': "trim(to_varchar(nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:'))) || '|' || 'LANDLINE | Contact Priority Order = 1' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_PATIENT_DETAILS',
      'columns': [
        {'src': "nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:')", 'tgt': 'party_bk'},
        {'src': "'LANDLINE | Contact Priority Order = 1'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'phone_no', 'tgt': 'common_contact__landline_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_patient_details',
      'alias': 't37',
      'key_column': "trim(to_varchar(nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:'))) || '|' || 'EMAIL | Contact Priority Order = 1' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_PATIENT_DETAILS',
      'columns': [
        {'src': "nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:')", 'tgt': 'party_bk'},
        {'src': "'EMAIL | Contact Priority Order = 1'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'email_id', 'tgt': 'common_contact__email_address'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_patient_details',
      'alias': 't38',
      'key_column': "trim(to_varchar(nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:'))) || '|' || 'FAX | Contact Priority Order = 1' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_PATIENT_DETAILS',
      'columns': [
        {'src': "nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:')", 'tgt': 'party_bk'},
        {'src': "'FAX | Contact Priority Order = 1'", 'tgt': 'common_contact__contact_point_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'common_contact__contact_priority_order_ck'},
        {'src': 'fax_no', 'tgt': 'common_contact__fax_number'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_bk',
    'common_contact__contact_point_type_ck',
    'common_contact__contact_priority_order_ck',
    'common_contact__email_address',
    'common_contact__mobile_number',
    'common_contact__landline_number',
    'common_contact__fax_number',
    'common_contact__alternate_email_address',
    'common_contact__alternate_mobile_number',
    'common_contact__std_code'
] -%}
{%- set coalesce_rules = {
    'party_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't31', 't32', 't33', 't34', 't35', 't36', 't37', 't38'],
    'common_contact__contact_point_type_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't31', 't32', 't33', 't34', 't35', 't36', 't37', 't38'],
    'common_contact__contact_priority_order_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't31', 't32', 't33', 't34', 't35', 't36', 't37', 't38'],
    'common_contact__email_address': ['t0', 't2', 't3', 't5', 't6', 't8', 't9', 't10', 't13', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't26', 't27', 't28', 't29', 't30', 't31', 't32', 't34', 't37'],
    'common_contact__mobile_number': ['t1', 't4', 't7', 't12', 't15', 't16', 't17', 't18', 't19', 't21', 't22', 't27', 't28', 't29', 't32', 't33', 't35'],
    'common_contact__landline_number': ['t11', 't14', 't15', 't16', 't17', 't18', 't20', 't21', 't22', 't24', 't27', 't30', 't36'],
    'common_contact__fax_number': ['t15', 't16', 't17', 't18', 't22', 't25', 't27', 't38'],
    'common_contact__alternate_email_address': ['t19', 't21'],
    'common_contact__alternate_mobile_number': ['t19'],
    'common_contact__std_code': ['t22', 't23']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='common_contact_pk',
    target_sat='sat_common_contact'
) }}
