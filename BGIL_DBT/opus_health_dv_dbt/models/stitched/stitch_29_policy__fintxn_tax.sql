/* RESHAPED (Option C), ONE STITCH PER SATELLITE, from hcon4 central view 29.
   Batch task 7.1 -- applies the pilot procedure (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_fintxn_tax
   payload           : 13 output column(s), this satellite's stage hashdiff payload only.
   hub_keys          : the FULL final-SELECT hub-key set of the central view (35), verbatim,
                       so downstream hub/stage layers keep resolving every HUB_*_BK column.
   key_column rule   : each source's HUB_POLICY_BK__* column (spine-hub grain key).
   GRAIN DEVIATIONS (source has no HUB_POLICY key; real join key used, kept so hub_keys exprs resolve):
       t9 (stg_intermediary) key_column=HUB_PARTY_BK__INTERMEDIARY_ID
   SAME-ALIAS DROPS (macro emits one column per alias per attr; secondary raw col dropped):
       service_tax_amount: kept t7.service_tax; dropped service_tax_amount
       cess_amount: kept t0.emi_cess1; dropped emi_cess2, emi_cess3, emi_edu_cess, emi_kkc, emi_ncc, emi_sb_tax
       cess_amount: kept t2.adj_cess1_amt; dropped adj_cess2_amt, adj_cess3_amt, adj_kkc_amt, adj_ncc_amt, adj_swb_amt, cess1_amt, cess2_amt, cess3_amt, kkc, ncc_amt, sb_cess
       cess_amount: kept t3.cess1_amt; dropped cess2_amt, cess3_amt, ncc_amt
       sgst_amount: kept t2.adj_sgst_amt; dropped sgst_amt
       component_tax_amount: kept t2.adj_utgst_amt; dropped utgst_amt
       cgst_amount: kept t2.adj_cgst_amt; dropped cgst_amt
       igst_amount: kept t2.adj_igst_amt; dropped igst_amt
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
        'columns': [
            {'src': 'service_tax_exemption', 'tgt': 'service_tax_exemption_indicator'},
            {'src': 'service_tax_exemption_amt', 'tgt': 'service_tax_exemption_amount'},
            {'src': 'emi_ser_tax', 'tgt': 'service_tax_amount'},
            {'src': 'emi_cess1', 'tgt': 'cess_amount'},
            {'src': 'emi_sgst', 'tgt': 'sgst_amount'},
            {'src': 'emi_utgst', 'tgt': 'component_tax_amount'},
            {'src': 'emi_cgst', 'tgt': 'cgst_amount'},
            {'src': 'emi_igst', 'tgt': 'igst_amount'}
        ],
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
        'columns': [
            {'src': 'sgst_amt', 'tgt': 'sgst_amount'},
            {'src': 'cgst_amt', 'tgt': 'cgst_amount'},
            {'src': 'igst_amt', 'tgt': 'igst_amount'},
            {'src': 'utgst_amt', 'tgt': 'utgst_amount'}
        ],
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
        'columns': [
            {'src': 'service_tax', 'tgt': 'service_tax_amount'},
            {'src': 'adj_cess1_amt', 'tgt': 'cess_amount'},
            {'src': 'adj_sgst_amt', 'tgt': 'sgst_amount'},
            {'src': 'adj_utgst_amt', 'tgt': 'component_tax_amount'},
            {'src': 'adj_cgst_amt', 'tgt': 'cgst_amount'},
            {'src': 'adj_igst_amt', 'tgt': 'igst_amount'},
            {'src': 'tax_code', 'tgt': 'tax_type'}
        ],
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
        'columns': [
            {'src': 'cess1_amt', 'tgt': 'cess_amount'},
            {'src': 'sgst_amt', 'tgt': 'sgst_amount'},
            {'src': 'utgst_amt', 'tgt': 'component_tax_amount'},
            {'src': 'cgst_amt', 'tgt': 'cgst_amount'},
            {'src': 'igst_amt', 'tgt': 'igst_amount'},
            {'src': 'tax_code', 'tgt': 'tax_type'}
        ],
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
        'columns': [
            {'src': 'service_tax_amt', 'tgt': 'service_tax_amount'},
            {'src': 'state_gst', 'tgt': 'sgst_amount'},
            {'src': 'central_gst', 'tgt': 'cgst_amount'},
            {'src': 'i_gst', 'tgt': 'igst_amount'}
        ],
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
            {'src': 'ncc_amt', 'tgt': 'cess_amount'},
            {'src': 'sgst_amt', 'tgt': 'sgst_amount'},
            {'src': 'cgst_amt', 'tgt': 'cgst_amount'},
            {'src': 'igst_amt', 'tgt': 'igst_amount'},
            {'src': 'utgst_amt', 'tgt': 'utgst_amount'}
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
        'columns': [
            {'src': 'service_tax', 'tgt': 'service_tax_amount'},
            {'src': 'tds_rate', 'tgt': 'tds_rate'},
            {'src': 'service_tax_rate', 'tgt': 'service_tax_rate'}
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
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'service_tax_amount', 'tgt': 'service_tax_amount'},
            {'src': 'service_tax_no', 'tgt': 'service_tax_registration_number'}
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
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(BUSINESS_CHANNEL),'')", 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL'},
            {'src_expr': "nullif(trim(NEW_BC),'')", 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC'},
            {'src_expr': "nullif(trim(INTERMEDIARY_ID),'')", 'tgt': 'HUB_PARTY_BK__INTERMEDIARY_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_INTERMEDIARY'
    }
] -%}

{%- set output_columns = [
    'service_tax_exemption_indicator',
    'service_tax_exemption_amount',
    'service_tax_amount',
    'cess_amount',
    'sgst_amount',
    'component_tax_amount',
    'cgst_amount',
    'igst_amount',
    'utgst_amount',
    'tax_type',
    'tds_rate',
    'service_tax_rate',
    'service_tax_registration_number'
] -%}

{%- set coalesce_rules = {
    'service_tax_exemption_indicator': ['t0'],
    'service_tax_exemption_amount': ['t0'],
    'service_tax_amount': ['t0', 't2', 't4', 't7', 't8'],
    'cess_amount': ['t0', 't2', 't3', 't5'],
    'sgst_amount': ['t0', 't1', 't2', 't3', 't4', 't5'],
    'component_tax_amount': ['t0', 't2', 't3'],
    'cgst_amount': ['t0', 't1', 't2', 't3', 't4', 't5'],
    'igst_amount': ['t0', 't1', 't2', 't3', 't4', 't5'],
    'utgst_amount': ['t1', 't5'],
    'tax_type': ['t2', 't3'],
    'tds_rate': ['t7'],
    'service_tax_rate': ['t7'],
    'service_tax_registration_number': ['t8']
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
    target_sat='sat_fintxn_tax'
) }}
