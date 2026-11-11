{{ config(materialized='view') }}
-- This part feeds SAT_PARTY_BANKING only. Original precedence comments are kept below (from stitch_v15_party).
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
-- depends_on: {{ ref('stg_health__bjaz_neft_partner_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
-- depends_on: {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_neft_partner_dtls',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:'))) || '|' || coalesce(re_entered_acc_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_NEFT_PARTNER_DTLS',
      'columns': [
        {'src': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')", 'tgt': 'party_bk'},
        {'src': 're_entered_acc_no', 'tgt': 'party_banking__account_number_masked_ck'},
        {'src': 're_entered_acc_no', 'tgt': 'party_banking__account_number_masked'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(cust_id),''))) || '|' || coalesce(bankaccountno, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': "nullif(trim(cust_id),'')", 'tgt': 'party_bk'},
        {'src': 'bankaccountno', 'tgt': 'party_banking__account_number_masked_ck'},
        {'src': 'bankaccountno', 'tgt': 'party_banking__account_number_masked'},
        {'src': 'bank_name', 'tgt': 'party_banking__bank_name'},
        {'src': 'bankifsc', 'tgt': 'party_banking__ifsc_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_bandhan_medi_clam',
      'alias': 't2',
      'key_column': "customer_id || '|' || coalesce(account_number, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BANDHAN_MEDI_CLAM',
      'columns': [
        {'src': 'customer_id', 'tgt': 'party_bk'},
        {'src': 'account_number', 'tgt': 'party_banking__account_number_masked_ck'},
        {'src': 'account_number', 'tgt': 'party_banking__account_number_masked'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't3',
      'key_column': "hospital_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'hospital_id', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'party_banking__account_number_masked_ck'},
        {'src': 'coalesce(account_no, bank_ac_no)', 'tgt': 'party_banking__account_number_masked'},
        {'src': 'bank_name', 'tgt': 'party_banking__bank_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master_extn',
      'alias': 't4',
      'key_column': "hosid || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER_EXTN',
      'columns': [
        {'src': 'hosid', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'party_banking__account_number_masked_ck'},
        {'src': 'name_bank_account', 'tgt': 'party_banking__account_holder_name'},
        {'src': 'account_no', 'tgt': 'party_banking__account_number_masked'},
        {'src': 'account_type', 'tgt': 'party_banking__account_type'},
        {'src': 'bank_name', 'tgt': 'party_banking__bank_name'},
        {'src': 'ifsc_code_neft', 'tgt': 'party_banking__ifsc_code'},
        {'src': 'br_micr_code', 'tgt': 'party_banking__micr_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't5',
      'key_column': "member_id || '|' || coalesce(bank_ac_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'member_id', 'tgt': 'party_bk'},
        {'src': 'bank_ac_no', 'tgt': 'party_banking__account_number_masked_ck'},
        {'src': 'bank_name', 'tgt': 'party_banking__bank_name'},
        {'src': 'micr_code', 'tgt': 'party_banking__micr_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't6',
      'key_column': "customer_id || '|' || coalesce(account_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'customer_id', 'tgt': 'party_bk'},
        {'src': 'account_no', 'tgt': 'party_banking__account_number_masked_ck'},
        {'src': 'account_no', 'tgt': 'party_banking__account_number_masked'},
        {'src': 'neft_bank_status', 'tgt': 'party_banking__account_status'},
        {'src': 'account_type', 'tgt': 'party_banking__account_type'},
        {'src': 'bank_name', 'tgt': 'party_banking__bank_name'},
        {'src': 'branch_ifsc_code', 'tgt': 'party_banking__ifsc_code'},
        {'src': 'branch_micr_code', 'tgt': 'party_banking__micr_code'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_bk',
    'party_banking__account_number_masked_ck',
    'party_banking__account_number_masked',
    'party_banking__bank_name',
    'party_banking__ifsc_code',
    'party_banking__account_holder_name',
    'party_banking__account_type',
    'party_banking__micr_code',
    'party_banking__account_status'
] -%}
{%- set coalesce_rules = {
    'party_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6'],
    'party_banking__account_number_masked_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6'],
    'party_banking__account_number_masked': ['t0', 't1', 't2', 't3', 't4', 't6'],
    'party_banking__bank_name': ['t1', 't3', 't4', 't5', 't6'],
    'party_banking__ifsc_code': ['t1', 't4', 't6'],
    'party_banking__account_holder_name': ['t4'],
    'party_banking__account_type': ['t4', 't6'],
    'party_banking__micr_code': ['t4', 't5', 't6'],
    'party_banking__account_status': ['t6']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_banking_pk',
    target_sat='sat_party_banking'
) }}
