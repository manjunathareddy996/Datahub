/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Batch task 5.1. Procedure: the stitch_01 pilot's 9-step REUSABLE PROCEDURE.
   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_policy_certificate
   GRAIN DEVIATIONS (source has no spine-hub key; keyed on its real join col):
     - t23 (stg_ecard_membr_del_dtls): no HUB_POLICY key; key_column=HUB_PARTY_BK__EMP_CODE (real join key)
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_dt_mem',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'mem_status', 'tgt': 'member_status'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno', 'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_MEM'
    },
    {
        'model': 'stg_hcp_dt_mem_cov',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'mem_add_flag', 'tgt': 'joining_type'},
            {'src': 'mem_status', 'tgt': 'member_status'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno', 'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_MEM_COV'
    },
    {
        'model': 'stg_hcp_dt_pol_cov',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'mem_add_flag', 'tgt': 'joining_type'},
            {'src': 'mem_status', 'tgt': 'member_status'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno', 'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_POL_COV'
    },
    {
        'model': 'stg_bgil_gmc_final_instl_data',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'annual_er_cntr', 'tgt': 'annual_employer_contribution_amount'},
            {'src': 'eligible_days', 'tgt': 'eligible_coverage_days'},
            {'src': 'final_payable', 'tgt': 'final_payable_amount'},
            {'src': 'annual_premium', 'tgt': 'member_premium'},
            {'src': 'sum_inusred', 'tgt': 'member_sum_insured'},
            {'src': 'prorata_er_cntr', 'tgt': 'pro_rata_employer_contribution_amount'},
            {'src': 'prorata_premium', 'tgt': 'pro_rata_member_premium'},
            {'src': 'dwh_relationship', 'tgt': 'relationship_to_primary'}
        ],
        'hub_key_columns': [
            {'src_expr': 'emp_code', 'tgt': 'HUB_PARTY_BK__EMP_CODE'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BGIL_GMC_FINAL_INSTL_DATA'
    },
    {
        'model': 'stg_card_dtls',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'card_no', 'tgt': 'HUB_DOCUMENT_BK__CARD_NO'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_CARD_DTLS'
    },
    {
        'model': 'stg_ec_mem_dtls_extn',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'effetive_date', 'tgt': 'coverage_start_date'},
            {'src': 'premium', 'tgt': 'member_premium'},
            {'src': 'status', 'tgt': 'member_status'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_generic_loader_log_table',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partnerid', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode', 'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc', 'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'pmasterpolicynumber', 'tgt': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER'},
            {'src_expr': 'planid', 'tgt': 'HUB_PRODUCT_BK__PLANID'},
            {'src_expr': 'schemecode', 'tgt': 'HUB_PRODUCT_BK__SCHEMECODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GENERIC_LOADER_LOG_TABLE'
    },
    {
        'model': 'stg_gp_hospital_cash',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__MASTER_POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'imd_code', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 's_account_number', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER'},
            {'src_expr': 'user_id', 'tgt': 'HUB_PARTY_BK__USER_ID'},
            {'src_expr': 'master_policy_no', 'tgt': 'HUB_POLICY_BK__MASTER_POLICY_NO'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 'kgc_proposal_number', 'tgt': 'HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER'},
            {'src_expr': 'reference_id', 'tgt': 'HUB_PROPOSAL_BK__REFERENCE_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GP_HOSPITAL_CASH'
    },
    {
        'model': 'stg_hat_id_mem_detls',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'join_date', 'tgt': 'enrolment_date'},
            {'src': 'premium', 'tgt': 'member_premium'},
            {'src': 'status', 'tgt': 'member_status'},
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HAT_ID_MEM_DETLS'
    },
    {
        'model': 'stg_hcf_member_dtls',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'to_date', 'tgt': 'coverage_end_date'},
            {'src': 'from_date', 'tgt': 'coverage_start_date'},
            {'src': 'premium', 'tgt': 'member_premium'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_hc_part_extn',
        'alias': 't10',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'premium', 'tgt': 'member_premium'},
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_hdfc_sec_fhpp',
        'alias': 't11',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'imd_code', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 's_account_number', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER'},
            {'src_expr': 'client_id', 'tgt': 'HUB_PARTY_BK__CLIENT_ID'},
            {'src_expr': 'reference_id', 'tgt': 'HUB_POLICY_BK__REFERENCE_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 'ba_lead_no', 'tgt': 'HUB_PROPOSAL_BK__BA_LEAD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HDFC_SEC_FHPP'
    },
    {
        'model': 'stg_hlt_ensure_mem_dtls',
        'alias': 't12',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HLT_ENSURE_MEM_DTLS'
    },
    {
        'model': 'stg_hm_coinsu_clm_dtls',
        'alias': 't13',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'ldr_pid', 'tgt': 'HUB_PARTY_BK__LDR_PID'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'prod_cd', 'tgt': 'HUB_PRODUCT_BK__PROD_CD'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_COINSU_CLM_DTLS'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't14',
        'key_column': 'HUB_POLICY_BK__POLICY',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'premium', 'tgt': 'member_premium'}
        ],
        'hub_key_columns': [
            {'src_expr': 'clid', 'tgt': 'HUB_CLAIM_BK__CLID'},
            {'src_expr': 'imd_code', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'bank_ac_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
            {'src_expr': 'utr_no', 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__UTR_NO'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode', 'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc', 'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'claim_no', 'tgt': 'HUB_LOSS_EVENT_BK__CLAIM_NO'},
            {'src_expr': 'hospital_id', 'tgt': 'HUB_PARTY_BK__HOSPITAL_ID'},
            {'src_expr': 'cheque_no', 'tgt': 'HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
            {'src_expr': 'policy', 'tgt': 'HUB_POLICY_BK__POLICY'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HCM_EXTRACT'
    },
    {
        'model': 'stg_hm_inward_dtls',
        'alias': 't15',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'certificate_no', 'tgt': 'certificate_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'inward_id', 'tgt': 'HUB_DOCUMENT_BK__INWARD_ID'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode', 'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc', 'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'claim_id', 'tgt': 'HUB_LOSS_EVENT_BK__CLAIM_ID'},
            {'src_expr': 'courier_id', 'tgt': 'HUB_PARTY_BK__COURIER_ID'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_INWARD_DTLS'
    },
    {
        'model': 'stg_hm_member_dtls',
        'alias': 't16',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'premium', 'tgt': 'member_premium'},
            {'src': 'member_status', 'tgt': 'member_status'},
            {'src': 'suminsured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'bank_ac_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
            {'src_expr': 'member_id', 'tgt': 'HUB_PARTY_BK__MEMBER_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_hm_orphan_reg',
        'alias': 't17',
        'key_column': 'HUB_POLICY_BK__POLICY_NUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'suminsured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode', 'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc', 'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'policy_number', 'tgt': 'HUB_POLICY_BK__POLICY_NUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_ORPHAN_REG'
    },
    {
        'model': 'stg_ihg_mem_dtls_extn',
        'alias': 't18',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'effetive_date', 'tgt': 'coverage_start_date'},
            {'src': 'premium', 'tgt': 'member_premium'},
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_IHG_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_illness_bases_extn',
        'alias': 't19',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ILLNESS_BASES_EXTN'
    },
    {
        'model': 'stg_pmsby_data_web_service',
        'alias': 't20',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'doj', 'tgt': 'enrolment_date'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(USER_TRANS_KEY_NO),'')", 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO'},
            {'src_expr': "md5(normalise(upper(nullif(trim( coalesce(ADDRESS_1,'') || ' ' || coalesce(ADDRESS_2,'') || ' ' || coalesce(PINCODE,'') ),''))))", 'tgt': 'HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(POLICY_REF),''),'') || '|NOMINEE|' || coalesce(nullif(trim(NOMINEENAME),''),''), '|NOMINEE|'))))", 'tgt': 'HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME'},
            {'src_expr': "nullif(trim(CUST_ID),'')", 'tgt': 'HUB_PARTY_BK__CUST_ID'},
            {'src_expr': "nullif(trim(POLICY_REF),'')", 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': "nullif('CUSTID:' || nullif(trim(CUST_ID),''), 'CUSTID:')", 'tgt': 'HUB_RISK_OBJECT_BK__CUSTID_CUST_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_PMSBY_DATA_WEB_SERVICE'
    },
    {
        'model': 'stg_sh_mem_dtls_extn',
        'alias': 't21',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'effetive_date', 'tgt': 'coverage_start_date'},
            {'src': 'premium', 'tgt': 'member_premium'},
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't22',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'sum_insured', 'tgt': 'member_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'bjaz_claim_id', 'tgt': 'HUB_CLAIM_BK__BJAZ_CLAIM_ID'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'tpa_trans_key', 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY'},
            {'src_expr': 'tpa_claim_no', 'tgt': 'HUB_LOSS_EVENT_BK__TPA_CLAIM_NO'},
            {'src_expr': 'controlling_office', 'tgt': 'HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
            {'src_expr': 'operating_office', 'tgt': 'HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
            {'src_expr': 'customer_id', 'tgt': 'HUB_PARTY_BK__CUSTOMER_ID'},
            {'src_expr': 'hospital_code', 'tgt': 'HUB_PARTY_BK__HOSPITAL_CODE'},
            {'src_expr': 'cheque_no', 'tgt': 'HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_TPA_CLAIM_DETAILS_WS'
    },
    {
        'model': 'stg_ecard_membr_del_dtls',
        'alias': 't23',
        'key_column': 'HUB_PARTY_BK__EMP_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'natrl_reason', 'tgt': 'exit_reason'}
        ],
        'hub_key_columns': [
            {'src_expr': 'emp_code', 'tgt': 'HUB_PARTY_BK__EMP_CODE'},
            {'src_expr': 'quote_ref', 'tgt': 'HUB_QUOTE_BK__QUOTE_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ECARD_MEMBR_DEL_DTLS'
    }
] -%}

{%- set output_columns = [
    'annual_employer_contribution_amount', 'certificate_number', 'coverage_end_date', 'coverage_start_date', 'eligible_coverage_days', 'enrolment_date', 'exit_reason', 'final_payable_amount', 'joining_type', 'member_premium', 'member_status', 'member_sum_insured', 'pro_rata_employer_contribution_amount', 'pro_rata_member_premium', 'relationship_to_primary'
] -%}

{%- set coalesce_rules = {
    'annual_employer_contribution_amount': ['t3'],
    'certificate_number': ['t15'],
    'coverage_end_date': ['t9'],
    'coverage_start_date': ['t5', 't9', 't18', 't21'],
    'eligible_coverage_days': ['t3'],
    'enrolment_date': ['t20', 't8'],
    'exit_reason': ['t23'],
    'final_payable_amount': ['t3'],
    'joining_type': ['t1', 't2'],
    'member_premium': ['t3', 't5', 't8', 't9', 't10', 't14', 't16', 't18', 't21'],
    'member_status': ['t0', 't1', 't2', 't5', 't8', 't16'],
    'member_sum_insured': ['t3', 't4', 't6', 't7', 't8', 't10', 't11', 't12', 't13', 't16', 't17', 't18', 't19', 't21', 't22'],
    'pro_rata_employer_contribution_amount': ['t3'],
    'pro_rata_member_premium': ['t3'],
    'relationship_to_primary': ['t3']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t13.HUB_CLAIM_BK__CLAIM_ID, t14.HUB_CLAIM_BK__CLID, t15.HUB_CLAIM_BK__CLAIM_ID, t17.HUB_CLAIM_BK__CLAIM_ID, t22.HUB_CLAIM_BK__BJAZ_CLAIM_ID)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 'coalesce(t0.HUB_COVERAGE_BK__HCP_SEQNO, t1.HUB_COVERAGE_BK__HCP_SEQNO, t2.HUB_COVERAGE_BK__HCP_SEQNO)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t4.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID, t7.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t9.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t11.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t12.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t14.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t16.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t18.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t20.HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO, t21.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t22.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t4.HUB_DOCUMENT_BK__CARD_NO, t5.HUB_DOCUMENT_BK__MEDICAL_REPORT, t15.HUB_DOCUMENT_BK__INWARD_ID, t18.HUB_DOCUMENT_BK__MEDICAL_REPORT, t21.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t7.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER, t11.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER, t14.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO, t16.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t14.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t22.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't20.HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t14.HUB_LOSS_EVENT_BK__CLAIM_NO, t15.HUB_LOSS_EVENT_BK__CLAIM_ID, t22.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__PART_ID, t1.HUB_PARTY_BK__PART_ID, t2.HUB_PARTY_BK__PART_ID, t3.HUB_PARTY_BK__EMP_CODE, t5.HUB_PARTY_BK__MEMBER_NO, t7.HUB_PARTY_BK__USER_ID, t8.HUB_PARTY_BK__MEMBER_NO, t9.HUB_PARTY_BK__MEMBER_NO, t10.HUB_PARTY_BK__PART_ID, t11.HUB_PARTY_BK__CLIENT_ID, t12.HUB_PARTY_BK__MEMBER_NO, t13.HUB_PARTY_BK__LDR_PID, t14.HUB_PARTY_BK__HOSPITAL_ID, t15.HUB_PARTY_BK__COURIER_ID, t16.HUB_PARTY_BK__MEMBER_ID, t18.HUB_PARTY_BK__MEMBER_NO, t21.HUB_PARTY_BK__MEMBER_NO, t23.HUB_PARTY_BK__EMP_CODE)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t14.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t22.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__CONTRACT_ID, t2.HUB_POLICY_BK__CONTRACT_ID, t3.HUB_POLICY_BK__POLICY_NO, t4.HUB_POLICY_BK__POLICY_REF, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__PMASTERPOLICYNUMBER, t7.HUB_POLICY_BK__MASTER_POLICY_NO, t8.HUB_POLICY_BK__CONTRACT_ID, t9.HUB_POLICY_BK__CONTRACT_ID, t10.HUB_POLICY_BK__CONTRACT_ID, t11.HUB_POLICY_BK__REFERENCE_ID, t12.HUB_POLICY_BK__CONTRACT_ID, t13.HUB_POLICY_BK__POLICY_REF, t14.HUB_POLICY_BK__POLICY, t15.HUB_POLICY_BK__POLICY_REF, t16.HUB_POLICY_BK__CONTRACT_ID, t17.HUB_POLICY_BK__POLICY_NUMBER, t18.HUB_POLICY_BK__CONTRACT_ID, t19.HUB_POLICY_BK__CONTRACT_ID, t20.HUB_POLICY_BK__POLICY_REF, t21.HUB_POLICY_BK__CONTRACT_ID, t22.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t7.HUB_PRODUCT_BK__PRODUCT_CODE, t11.HUB_PRODUCT_BK__PRODUCT_CODE, t13.HUB_PRODUCT_BK__PROD_CD, t16.HUB_PRODUCT_BK__PRODUCT_CODE)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 't11.HUB_PROPOSAL_BK__BA_LEAD_NO'},
    {'name': 'HUB_QUOTE_BK', 'expr': 't23.HUB_QUOTE_BK__QUOTE_REF'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t5.HUB_RISK_OBJECT_BK__MEMBER_NO, t9.HUB_RISK_OBJECT_BK__MEMBER_NO, t20.HUB_RISK_OBJECT_BK__CUSTID_CUST_ID)'},
    {'name': 'T6__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't6.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T6__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't6.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T6__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't6.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T6__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't6.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T6__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't6.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T6__HUB_PRODUCT_BK__PLANID', 'expr': 't6.HUB_PRODUCT_BK__PLANID'},
    {'name': 'T6__HUB_PRODUCT_BK__SCHEMECODE', 'expr': 't6.HUB_PRODUCT_BK__SCHEMECODE'},
    {'name': 'T7__HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER', 'expr': 't7.HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER'},
    {'name': 'T7__HUB_PROPOSAL_BK__REFERENCE_ID', 'expr': 't7.HUB_PROPOSAL_BK__REFERENCE_ID'},
    {'name': 'T14__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't14.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T14__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't14.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T14__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't14.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T14__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't14.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T14__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't14.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T15__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't15.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T15__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't15.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T15__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't15.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T15__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't15.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T15__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't15.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T17__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't17.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T17__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't17.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T17__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't17.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T17__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't17.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T17__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't17.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T20__HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME', 'expr': 't20.HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME'},
    {'name': 'T20__HUB_PARTY_BK__CUST_ID', 'expr': 't20.HUB_PARTY_BK__CUST_ID'},
    {'name': 'T22__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't22.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T22__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't22.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T22__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't22.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T22__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't22.HUB_PARTY_BK__HOSPITAL_CODE'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_policy_certificate'
) }}
