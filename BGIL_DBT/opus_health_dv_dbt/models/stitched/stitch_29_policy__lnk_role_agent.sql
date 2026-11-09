/* RESHAPED (Option C), ONE STITCH PER SATELLITE, from hcon4 central view 29.
   Batch task 7.1 -- applies the pilot procedure (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_lnk_role_agent
   payload           : 31 output column(s), this satellite's stage hashdiff payload only.
   hub_keys          : the FULL final-SELECT hub-key set of the central view (35), verbatim,
                       so downstream hub/stage layers keep resolving every HUB_*_BK column.
   key_column rule   : each source's HUB_POLICY_BK__* column (spine-hub grain key).
   GRAIN DEVIATIONS (source has no HUB_POLICY key; real join key used, kept so hub_keys exprs resolve):
       t9 (stg_intermediary) key_column=HUB_PARTY_BK__INTERMEDIARY_ID
   SAME-ALIAS DROPS  : none.
   SOURCES OMITTED   : none.
   merge order       : R8 precedence (v2 > legacy > delta3) preserved from the central view COALESCE order.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_dt_premium',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno', 'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'user_id', 'tgt': 'HUB_PARTY_BK__USER_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_PREMIUM'
    },
    {
        'model': 'stg_hcp_prime_rider_dtls',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__BASE_POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'base_policy_ref', 'tgt': 'HUB_POLICY_BK__BASE_POLICY_REF'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PRIME_RIDER_DTLS'
    },
    {
        'model': 'stg_gpg_pol_dtls',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'imd_code', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'lms_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__LMS_NO'},
            {'src_expr': 'company_org_unit', 'tgt': 'HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
            {'src_expr': 'bagic_e_code', 'tgt': 'HUB_PARTY_BK__BAGIC_E_CODE'},
            {'src_expr': 'bagic_rm_e_code', 'tgt': 'HUB_PARTY_BK__BAGIC_RM_E_CODE'},
            {'src_expr': 'imd_code', 'tgt': 'HUB_PARTY_BK__IMD_CODE'},
            {'src_expr': 'sub_imd_code', 'tgt': 'HUB_PARTY_BK__SUB_IMD_CODE'},
            {'src_expr': 'reference_id', 'tgt': 'HUB_POLICY_BK__REFERENCE_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 're_insu', 'tgt': 'HUB_REINSURANCE_TREATY_BK__RE_INSU'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GPG_POL_DTLS'
    },
    {
        'model': 'stg_grp_hlt_maternity_dtls',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'reg_no', 'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product', 'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_MATERNITY_DTLS'
    },
    {
        'model': 'stg_health_webservice_info',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'deal_id', 'tgt': 'HUB_AGREEMENT_BK__DEAL_ID'},
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'loan_accno', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__LOAN_ACCNO'},
            {'src_expr': 'ptransaction_id', 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__PTRANSACTION_ID'},
            {'src_expr': 'branch_code', 'tgt': 'HUB_ORG_UNIT_BK__BRANCH_CODE'},
            {'src_expr': 'dept_code', 'tgt': 'HUB_ORG_UNIT_BK__DEPT_CODE'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HEALTH_WEBSERVICE_INFO'
    },
    {
        'model': 'stg_hg_pol_dtls',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'sub_agent_code', 'tgt': 'agent_code'}
        ],
        'hub_key_columns': [
            {'src_expr': 'cover_code', 'tgt': 'HUB_COVERAGE_BK__COVER_CODE'},
            {'src_expr': 'business_source', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE'},
            {'src_expr': 'company_org_unit', 'tgt': 'HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
            {'src_expr': 'department_code', 'tgt': 'HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'product_4digit_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE'},
            {'src_expr': 'quote_ref_no', 'tgt': 'HUB_PROPOSAL_BK__QUOTE_REF_NO'},
            {'src_expr': 'quote_ref_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_REF_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HG_POL_DTLS'
    },
    {
        'model': 'stg_hm_gmc_ahc',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_GMC_AHC'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__POLICY',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'agent_code', 'tgt': 'agent_code'}
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
        'model': 'stg_intermediary',
        'alias': 't9',
        'key_column': 'HUB_PARTY_BK__INTERMEDIARY_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'spl_inter_code', 'tgt': 'alternate_intermediary_code'},
            {'src': 'intermediary_type', 'tgt': 'agency_type'},
            {'src': 'intermediary_group', 'tgt': 'intermediary_group_code'},
            {'src': 'license_no', 'tgt': 'insurer_issued_licence_number'},
            {'src': 'irda_intermediary_code', 'tgt': 'irdai_intermediary_registration_code'},
            {'src': 'irda_license_no', 'tgt': 'irdai_agent_licence_number'},
            {'src': 'tds_rate_ind', 'tgt': 'special_tds_rate_applicable_indicator'},
            {'src': 'spl_tds_rate', 'tgt': 'special_tds_rate'},
            {'src': 'status', 'tgt': 'active_indicator'},
            {'src': 'system_date', 'tgt': 'appointment_date'},
            {'src': 'subimd_yn', 'tgt': 'sub_intermediary_indicator'},
            {'src': 'new_imd_type', 'tgt': 'revised_intermediary_type_code'},
            {'src': 'license_expiry_date', 'tgt': 'licence_expiry_date'},
            {'src': 'license_issue_date', 'tgt': 'licence_issue_date'},
            {'src': 'license_type', 'tgt': 'licence_category'},
            {'src': 'block_for_receipt', 'tgt': 'premium_receipt_collection_blocked_indicator'},
            {'src': 'logo_filename', 'tgt': 'co_branding_logo_file_reference'},
            {'src': 'isactive_logo', 'tgt': 'co_branding_logo_active_indicator'},
            {'src': 'type_of_comm_arr', 'tgt': 'commission_arrangement_type'},
            {'src': 'green_channel_imd', 'tgt': 'green_channel_indicator'},
            {'src': 'sub_channel_code', 'tgt': 'sub_channel_code'},
            {'src': 'sub_chn_eff_date', 'tgt': 'sub_channel_effective_date'},
            {'src': 'fin_sub_channel_code', 'tgt': 'financial_reporting_sub_channel_code'},
            {'src': 'nature_of_agreement', 'tgt': 'appointment_agreement_nature'},
            {'src': 'nature_of_agreement_other', 'tgt': 'appointment_agreement_nature_other_description'},
            {'src': 'it_return_2yr', 'tgt': 'income_tax_return_filed_two_years_indicator'},
            {'src': 'flagging', 'tgt': 'intermediary_code_standing'},
            {'src': 'remarks_code', 'tgt': 'record_remark_code'},
            {'src': 'type_of_change', 'tgt': 'last_amendment_reason_code'},
            {'src': 'website_link', 'tgt': 'intermediary_website_url'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(BUSINESS_CHANNEL),'')", 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL'},
            {'src_expr': "nullif(trim(NEW_BC),'')", 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC'},
            {'src_expr': "nullif(trim(INTERMEDIARY_ID),'')", 'tgt': 'HUB_PARTY_BK__INTERMEDIARY_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_INTERMEDIARY'
    }
] -%}

{%- set output_columns = [
    'agent_code',
    'alternate_intermediary_code',
    'agency_type',
    'intermediary_group_code',
    'insurer_issued_licence_number',
    'irdai_intermediary_registration_code',
    'irdai_agent_licence_number',
    'special_tds_rate_applicable_indicator',
    'special_tds_rate',
    'active_indicator',
    'appointment_date',
    'sub_intermediary_indicator',
    'revised_intermediary_type_code',
    'licence_expiry_date',
    'licence_issue_date',
    'licence_category',
    'premium_receipt_collection_blocked_indicator',
    'co_branding_logo_file_reference',
    'co_branding_logo_active_indicator',
    'commission_arrangement_type',
    'green_channel_indicator',
    'sub_channel_code',
    'sub_channel_effective_date',
    'financial_reporting_sub_channel_code',
    'appointment_agreement_nature',
    'appointment_agreement_nature_other_description',
    'income_tax_return_filed_two_years_indicator',
    'intermediary_code_standing',
    'record_remark_code',
    'last_amendment_reason_code',
    'intermediary_website_url'
] -%}

{%- set coalesce_rules = {
    'agent_code': ['t5', 't8'],
    'alternate_intermediary_code': ['t9'],
    'agency_type': ['t9'],
    'intermediary_group_code': ['t9'],
    'insurer_issued_licence_number': ['t9'],
    'irdai_intermediary_registration_code': ['t9'],
    'irdai_agent_licence_number': ['t9'],
    'special_tds_rate_applicable_indicator': ['t9'],
    'special_tds_rate': ['t9'],
    'active_indicator': ['t9'],
    'appointment_date': ['t9'],
    'sub_intermediary_indicator': ['t9'],
    'revised_intermediary_type_code': ['t9'],
    'licence_expiry_date': ['t9'],
    'licence_issue_date': ['t9'],
    'licence_category': ['t9'],
    'premium_receipt_collection_blocked_indicator': ['t9'],
    'co_branding_logo_file_reference': ['t9'],
    'co_branding_logo_active_indicator': ['t9'],
    'commission_arrangement_type': ['t9'],
    'green_channel_indicator': ['t9'],
    'sub_channel_code': ['t9'],
    'sub_channel_effective_date': ['t9'],
    'financial_reporting_sub_channel_code': ['t9'],
    'appointment_agreement_nature': ['t9'],
    'appointment_agreement_nature_other_description': ['t9'],
    'income_tax_return_filed_two_years_indicator': ['t9'],
    'intermediary_code_standing': ['t9'],
    'record_remark_code': ['t9'],
    'last_amendment_reason_code': ['t9'],
    'intermediary_website_url': ['t9']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't4.HUB_AGREEMENT_BK__DEAL_ID'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t2.HUB_ASSESSMENT_BK__SCRUTINY_NO, t4.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t7.HUB_CLAIM_BK__CLID, t8.HUB_CLAIM_BK__BJAZ_CLAIM_ID)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 'coalesce(t0.HUB_COVERAGE_BK__HCP_SEQNO, t5.HUB_COVERAGE_BK__COVER_CODE)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t2.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t4.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t7.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t8.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t2.HUB_FINANCIAL_ACCOUNT_BK__LMS_NO, t4.HUB_FINANCIAL_ACCOUNT_BK__LOAN_ACCNO, t7.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t4.HUB_FINANCIAL_TRANSACTION_BK__PTRANSACTION_ID, t7.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t8.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t7.HUB_LOSS_EVENT_BK__CLAIM_NO, t8.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 't2.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__USER_ID, t5.HUB_PARTY_BK__PART_ID, t7.HUB_PARTY_BK__HOSPITAL_ID, t9.HUB_PARTY_BK__INTERMEDIARY_ID)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t7.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t8.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__BASE_POLICY_REF, t2.HUB_POLICY_BK__REFERENCE_ID, t3.HUB_POLICY_BK__REG_NO, t4.HUB_POLICY_BK__POLICY_REF, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__POLICY_NO, t7.HUB_POLICY_BK__POLICY, t8.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PRODUCT_CODE, t1.HUB_PRODUCT_BK__PRODUCT_CODE, t2.HUB_PRODUCT_BK__PRODUCT_CODE, t3.HUB_PRODUCT_BK__PRODUCT, t4.HUB_PRODUCT_BK__PRODUCT_CODE, t5.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 't5.HUB_PROPOSAL_BK__QUOTE_REF_NO'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t3.HUB_QUOTE_BK__QUOTE_SUB_NO, t5.HUB_QUOTE_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_REINSURANCE_TREATY_BK', 'expr': 't2.HUB_REINSURANCE_TREATY_BK__RE_INSU'},
    {'name': 'T2__HUB_PARTY_BK__BAGIC_E_CODE', 'expr': 't2.HUB_PARTY_BK__BAGIC_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__BAGIC_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__BAGIC_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__IMD_CODE', 'expr': 't2.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T2__HUB_PARTY_BK__SUB_IMD_CODE', 'expr': 't2.HUB_PARTY_BK__SUB_IMD_CODE'},
    {'name': 'T4__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't4.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T4__HUB_ORG_UNIT_BK__DEPT_CODE', 'expr': 't4.HUB_ORG_UNIT_BK__DEPT_CODE'},
    {'name': 'T5__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't5.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T5__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't5.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T7__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't7.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T7__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't7.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T7__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't7.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T7__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't7.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T7__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't7.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T8__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't8.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T8__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't8.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T8__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't8.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T8__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't8.HUB_PARTY_BK__HOSPITAL_CODE'},
    {'name': 'T9__HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL', 'expr': 't9.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL'},
    {'name': 'T9__HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC', 'expr': 't9.HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_lnk_role_agent'
) }}
