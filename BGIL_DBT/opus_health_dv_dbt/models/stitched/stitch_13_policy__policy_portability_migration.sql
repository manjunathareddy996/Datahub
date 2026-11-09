/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Procedure: the 9-step REUSABLE RESHAPE PROCEDURE documented in the pilot
   stitch_01_policy__policy_header.sql (task 4.1). Applied here by task 6.1.

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk'); satellite: SAT_POLICY_PORTABILITY_MIGRATION
   target_sat        : sat_policy_portability_migration  (header "SAT_POLICY_PORTABILITY_MIGRATION"
                       == stage_13 "SAT_POLICY_PORTABILITY_MIGRATION_HASHDIFF" == filename tail).
   key_column per src: each source's HUB_POLICY_BK__* column (the HUB_POLICY-grain key).
     - 13 of 15 sources carry a HUB_POLICY_BK__* column -> used directly as key_column.
     - t13 (BJAZ_GRP_HLT_DTLS): carries HUB_POLICY_BK__POLICY_NO; key_column=HUB_POLICY_BK__POLICY_NO
       even though the central view's FULL OUTER joined t13 on HUB_ASSESSMENT_BK__SCRUTINY_NO
       (t13 is NOT in the HUB_POLICY_BK spine coalesce). Grain-aligned choice per rule 4.
     - t14 (BJAZ_SCR_HLTH_PORTABLE_DTLS): carries NO HUB_POLICY key; the central view joined
       it on HUB_ASSESSMENT_BK__SCRUTINY_NO. DOCUMENTED GRAIN DEVIATION: key_column=
       HUB_ASSESSMENT_BK__SCRUTINY_NO (its real join key). Kept as a source so the family-1
       hub_keys exprs referencing t14.* resolve.
   PAYLOAD same-alias collisions (macro emits ONE col per alias per tgt):
     - previous_policy_expiry_date: kept t3.con_exp_date; dropped-secondary t3.perv_pol_exp_date
     - previous_policy_number     : kept t3.con_policy_ref; dropped-secondary t3.prev_policy_dtls
                                     kept t9.previous_policy_no; dropped-secondary t9.prev_policy_no
   merge order       : R8 precedence (v2 > legacy > delta3) preserved as the central
                       view's documented COALESCE order, transcribed verbatim per attr.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_port_wordings',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'port_reason',          'tgt': 'portability_reason'},
            {'src': 'prev_insurer',         'tgt': 'previous_insurer_name'},
            {'src': 'prev_policy_exp_date', 'tgt': 'previous_policy_expiry_date'},
            {'src': 'prev_policy_no',       'tgt': 'previous_policy_number'},
            {'src': 'prev_si',              'tgt': 'previous_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'partner_id',  'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PORT_WORDINGS'
    },
    {
        'model': 'stg_hcp_prod_8428_gpg_loader',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_first_policy_inception_date', 'tgt': 'first_policy_inception_date'},
            {'src': 'md_prev_comp_address',           'tgt': 'previous_insurer_address'},
            {'src': 'md_prev_comp_name',              'tgt': 'previous_insurer_name'},
            {'src': 'md_prev_expiry_date',            'tgt': 'previous_policy_expiry_date'},
            {'src': 'md_prev_policy_number',          'tgt': 'previous_policy_number'},
            {'src': 'md_prev_sum_insured',            'tgt': 'previous_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',          'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',               'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'mlac_emi_pc_loan_account_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO'},
            {'src_expr': 'pd_location_code',            'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',          'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',            'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',         'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',               'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',             'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
            {'src_expr': 'md_seq_no',                   'tgt': 'HUB_RISK_OBJECT_BK__MD_SEQ_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8428_GPG_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8439_clh_loader',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_first_policy_inception_date', 'tgt': 'first_policy_inception_date'},
            {'src': 'md_prev_comp_name',              'tgt': 'previous_insurer_name'},
            {'src': 'md_prev_expiry_date',            'tgt': 'previous_policy_expiry_date'},
            {'src': 'md_prev_policy_number',          'tgt': 'previous_policy_number'},
            {'src': 'md_prev_sum_insured',            'tgt': 'previous_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number', 'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',      'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'plc_loan_acc_no',    'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO'},
            {'src_expr': 'pd_location_code',   'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',   'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id','tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',      'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',    'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8439_CLH_LOADER'
    },
    {
        'model': 'stg_ec_mem_dtls_extn',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'con_deductable',    'tgt': 'previous_policy_deductible'},
            {'src': 'con_exp_date',      'tgt': 'previous_policy_expiry_date'},
            {'src': 'con_policy_ref',    'tgt': 'previous_policy_number'},
            {'src': 'first_policy_ref',  'tgt': 'first_policy_reference'},
            {'src': 'prev_company_name', 'tgt': 'previous_insurer_name'},
            {'src': 'prev_sum_insured',  'tgt': 'previous_sum_insured'},
            {'src': 'pre_pol_ncb_per',   'tgt': 'cumulative_bonus_ported'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no',      'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id',    'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no',      'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_gpg_pol_dtls',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'prev_policy_branch_address', 'tgt': 'previous_insurer_branch_address'},
            {'src': 'prev_policy_comp_name',      'tgt': 'previous_insurer_name'},
            {'src': 'prev_policy_expiry',         'tgt': 'previous_policy_expiry_date'},
            {'src': 'prev_pol_no',                'tgt': 'previous_policy_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',      'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'imd_code',         'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'lms_no',           'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__LMS_NO'},
            {'src_expr': 'company_org_unit', 'tgt': 'HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
            {'src_expr': 'bagic_e_code',     'tgt': 'HUB_PARTY_BK__BAGIC_E_CODE'},
            {'src_expr': 'bagic_rm_e_code',  'tgt': 'HUB_PARTY_BK__BAGIC_RM_E_CODE'},
            {'src_expr': 'imd_code',         'tgt': 'HUB_PARTY_BK__IMD_CODE'},
            {'src_expr': 'sub_imd_code',     'tgt': 'HUB_PARTY_BK__SUB_IMD_CODE'},
            {'src_expr': 'reference_id',     'tgt': 'HUB_POLICY_BK__REFERENCE_ID'},
            {'src_expr': 'product_code',     'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 're_insu',          'tgt': 'HUB_REINSURANCE_TREATY_BK__RE_INSU'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GPG_POL_DTLS'
    },
    {
        'model': 'stg_hat_id_mem_detls',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'prev_policy_details', 'tgt': 'previous_policy_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'member_no',   'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HAT_ID_MEM_DETLS'
    },
    {
        'model': 'stg_hcf_member_dtls',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'previous_si',      'tgt': 'previous_sum_insured'},
            {'src': 'prev_policy_since','tgt': 'previous_policy_inception_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',  'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no',   'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no',   'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_hc_part_extn',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'first_policy_ref', 'tgt': 'previous_policy_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'part_id',     'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_hg_pol_dtls',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'perv_pol_exp_date',   'tgt': 'previous_policy_expiry_date'},
            {'src': 'pol_benefit_tran_yn', 'tgt': 'portability_indicator'},
            {'src': 'prev_policy_no',      'tgt': 'previous_policy_number'},
            {'src': 'prev_sum_insured',    'tgt': 'previous_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'cover_code',          'tgt': 'HUB_COVERAGE_BK__COVER_CODE'},
            {'src_expr': 'business_source',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE'},
            {'src_expr': 'company_org_unit',    'tgt': 'HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
            {'src_expr': 'department_code',     'tgt': 'HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
            {'src_expr': 'part_id',             'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id',         'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'product_4digit_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE'},
            {'src_expr': 'quote_ref_no',        'tgt': 'HUB_PROPOSAL_BK__QUOTE_REF_NO'},
            {'src_expr': 'quote_ref_no',        'tgt': 'HUB_QUOTE_BK__QUOTE_REF_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HG_POL_DTLS'
    },
    {
        'model': 'stg_hlt_ensure_mem_dtls',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'first_policy_number',       'tgt': 'first_policy_number'},
            {'src': 'first_pol_inception_date',  'tgt': 'first_policy_inception_date'},
            {'src': 'previous_company_name',     'tgt': 'previous_insurer_name'},
            {'src': 'previous_cum_amount',       'tgt': 'ported_cumulative_bonus_amount'},
            {'src': 'previous_cum_bonus',        'tgt': 'cumulative_bonus_ported'},
            {'src': 'previous_from_date',        'tgt': 'previous_policy_start_date'},
            {'src': 'previous_policy_no',        'tgt': 'previous_policy_number'},
            {'src': 'previous_since_noof_years', 'tgt': 'continuity_period_granted'},
            {'src': 'previous_sum_insured',      'tgt': 'previous_sum_insured'},
            {'src': 'previous_to_date',          'tgt': 'previous_policy_expiry_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',  'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no',   'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HLT_ENSURE_MEM_DTLS'
    },
    {
        'model': 'stg_ihg_mem_dtls_extn',
        'alias': 't10',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'prev_policy_dtls', 'tgt': 'previous_policy_number'},
            {'src': 'prev_sum_insured', 'tgt': 'previous_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no',      'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id',    'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_IHG_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_policy_bases_extn',
        'alias': 't11',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'prev_insurer_name',       'tgt': 'previous_insurer_name'},
            {'src': 'prev_policy_expiry_date', 'tgt': 'previous_policy_expiry_date'},
            {'src': 'prev_policy_no',          'tgt': 'previous_policy_number'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('TXN:' || nullif(trim(TRANSACTION_ID),''), 'TXN:')", 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID'},
            {'src_expr': "md5(normalise(upper(nullif(trim(MAILING_PINCODE),''))))", 'tgt': 'HUB_LOCATION_BK__MAILING_PINCODE'},
            {'src_expr': "md5(normalise(upper(nullif(trim(PREV_INSURER_ADD),''))))", 'tgt': 'HUB_LOCATION_BK__PREV_INSURER_ADD'},
            {'src_expr': "nullif(trim(DEPARTMENT_CODE),'')", 'tgt': 'HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(PRODUCT_4DIGIT_CODE),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT_PRODUCT_4DIGIT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_POLICY_BASES_EXTN'
    },
    {
        'model': 'stg_sh_mem_dtls_extn',
        'alias': 't12',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'first_policy_ref', 'tgt': 'first_original_policy_reference'},
            {'src': 'prev_policy_dtls', 'tgt': 'previous_policy_number'},
            {'src': 'prev_sum_insured', 'tgt': 'previous_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no',      'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id',    'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_grp_hlt_dtls',
        'alias': 't13',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pre_insurer_name', 'tgt': 'previous_insurer_name'},
            {'src': 'prv_policy_no',    'tgt': 'previous_policy_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',   'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'branch',        'tgt': 'HUB_ORG_UNIT_BK__BRANCH'},
            {'src_expr': 'department',    'tgt': 'HUB_ORG_UNIT_BK__DEPARTMENT'},
            {'src_expr': 'policy_no',     'tgt': 'HUB_POLICY_BK__POLICY_NO'},
            {'src_expr': 'prev_pol_ref',  'tgt': 'HUB_POLICY_BK__PREV_POL_REF'},
            {'src_expr': 'reg_no',        'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product',       'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_ref_no',  'tgt': 'HUB_PROPOSAL_BK__QUOTE_REF_NO'},
            {'src_expr': 'quote_sub_no',  'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_DTLS'
    },
    {
        'model': 'stg_scr_hlth_portable_dtls',
        'alias': 't14',
        'key_column': 'HUB_ASSESSMENT_BK__SCRUTINY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'portability',       'tgt': 'portability_indicator'},
            {'src': 'prev_insurer_name', 'tgt': 'previous_insurer_name'},
            {'src': 'prev_policy_no',    'tgt': 'previous_policy_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',       'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'request_no',        'tgt': 'HUB_CASE_BK__REQUEST_NO'},
            {'src_expr': 'member_identifier', 'tgt': 'HUB_PARTY_BK__MEMBER_IDENTIFIER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_SCR_HLTH_PORTABLE_DTLS'
    }
] -%}

{%- set output_columns = [
    'previous_insurer_name',
    'previous_sum_insured',
    'previous_policy_number',
    'previous_policy_expiry_date',
    'portability_reason',
    'first_policy_inception_date',
    'previous_insurer_address',
    'cumulative_bonus_ported',
    'previous_policy_deductible',
    'first_policy_reference',
    'previous_insurer_branch_address',
    'previous_policy_inception_date',
    'portability_indicator',
    'previous_policy_start_date',
    'ported_cumulative_bonus_amount',
    'continuity_period_granted',
    'first_policy_number',
    'first_original_policy_reference'
] -%}

{#-- coalesce_rules: precedence order transcribed from the central view's final-SELECT
     payload COALESCEs. Single-alias rules emit a bare column reference (macro behaviour).
     Same-alias collisions represented once -- see header dropped-secondary note. --#}
{%- set coalesce_rules = {
    'previous_insurer_name':           ['t0', 't1', 't2', 't3', 't4', 't13', 't9', 't14', 't11'],
    'previous_sum_insured':            ['t0', 't1', 't2', 't3', 't6', 't8', 't9', 't10', 't12'],
    'previous_policy_number':          ['t0', 't1', 't2', 't3', 't4', 't13', 't5', 't7', 't8', 't9', 't10', 't14', 't12', 't11'],
    'previous_policy_expiry_date':     ['t0', 't1', 't2', 't3', 't4', 't8', 't9', 't11'],
    'portability_reason':              ['t0'],
    'first_policy_inception_date':     ['t1', 't2', 't9'],
    'previous_insurer_address':        ['t1'],
    'cumulative_bonus_ported':         ['t3', 't9'],
    'previous_policy_deductible':      ['t3'],
    'first_policy_reference':          ['t3'],
    'previous_insurer_branch_address': ['t4'],
    'previous_policy_inception_date':  ['t6'],
    'portability_indicator':           ['t8', 't14'],
    'previous_policy_start_date':      ['t9'],
    'ported_cumulative_bonus_amount':  ['t9'],
    'continuity_period_granted':       ['t9'],
    'first_policy_number':             ['t9'],
    'first_original_policy_reference': ['t12']
} %}

{#-- hub_keys: transcribed VERBATIM from the central view's final SELECT.
     Family 1 = merged-spine BKs (coalesce over alias.tgt). Family 2 = auxiliary
     per-source BKs (single alias.tgt, name prefixed TN__). Order preserved. --#}
{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__SCRUTINY_NO, t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t4.HUB_ASSESSMENT_BK__SCRUTINY_NO, t13.HUB_ASSESSMENT_BK__SCRUTINY_NO, t14.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CASE_BK', 'expr': 't14.HUB_CASE_BK__REQUEST_NO'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 't8.HUB_COVERAGE_BK__COVER_CODE'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t6.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t8.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t9.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t10.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t12.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t3.HUB_DOCUMENT_BK__MEDICAL_REPORT, t10.HUB_DOCUMENT_BK__MEDICAL_REPORT, t12.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t1.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t2.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t4.HUB_FINANCIAL_ACCOUNT_BK__LMS_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 't11.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t4.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT, t11.HUB_ORG_UNIT_BK__DEPARTMENT_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t3.HUB_PARTY_BK__MEMBER_NO, t5.HUB_PARTY_BK__MEMBER_NO, t6.HUB_PARTY_BK__MEMBER_NO, t7.HUB_PARTY_BK__PART_ID, t8.HUB_PARTY_BK__PART_ID, t9.HUB_PARTY_BK__MEMBER_NO, t10.HUB_PARTY_BK__MEMBER_NO, t12.HUB_PARTY_BK__MEMBER_NO, t14.HUB_PARTY_BK__MEMBER_IDENTIFIER)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__CONTRACT_ID, t4.HUB_POLICY_BK__REFERENCE_ID, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__CONTRACT_ID, t7.HUB_POLICY_BK__CONTRACT_ID, t8.HUB_POLICY_BK__CONTRACT_ID, t9.HUB_POLICY_BK__CONTRACT_ID, t10.HUB_POLICY_BK__CONTRACT_ID, t11.HUB_POLICY_BK__CONTRACT_ID, t12.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t4.HUB_PRODUCT_BK__PRODUCT_CODE, t8.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t11.HUB_PRODUCT_BK__PRODUCT_PRODUCT_4DIGIT_CODE, t13.HUB_PRODUCT_BK__PRODUCT)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t8.HUB_PROPOSAL_BK__QUOTE_REF_NO, t13.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t8.HUB_QUOTE_BK__QUOTE_REF_NO, t13.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_REINSURANCE_TREATY_BK', 'expr': 't4.HUB_REINSURANCE_TREATY_BK__RE_INSU'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t1.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t3.HUB_RISK_OBJECT_BK__MEMBER_NO, t6.HUB_RISK_OBJECT_BK__MEMBER_NO)'},
    {'name': 'T1__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't1.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T2__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't2.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T4__HUB_PARTY_BK__BAGIC_E_CODE', 'expr': 't4.HUB_PARTY_BK__BAGIC_E_CODE'},
    {'name': 'T4__HUB_PARTY_BK__BAGIC_RM_E_CODE', 'expr': 't4.HUB_PARTY_BK__BAGIC_RM_E_CODE'},
    {'name': 'T4__HUB_PARTY_BK__IMD_CODE', 'expr': 't4.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T4__HUB_PARTY_BK__SUB_IMD_CODE', 'expr': 't4.HUB_PARTY_BK__SUB_IMD_CODE'},
    {'name': 'T8__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't8.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T8__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't8.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T11__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't11.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T11__HUB_LOCATION_BK__PREV_INSURER_ADD', 'expr': 't11.HUB_LOCATION_BK__PREV_INSURER_ADD'},
    {'name': 'T13__HUB_ORG_UNIT_BK__BRANCH', 'expr': 't13.HUB_ORG_UNIT_BK__BRANCH'},
    {'name': 'T13__HUB_ORG_UNIT_BK__DEPARTMENT', 'expr': 't13.HUB_ORG_UNIT_BK__DEPARTMENT'},
    {'name': 'T13__HUB_POLICY_BK__POLICY_NO', 'expr': 't13.HUB_POLICY_BK__POLICY_NO'},
    {'name': 'T13__HUB_POLICY_BK__PREV_POL_REF', 'expr': 't13.HUB_POLICY_BK__PREV_POL_REF'},
    {'name': 'T13__HUB_POLICY_BK__REG_NO', 'expr': 't13.HUB_POLICY_BK__REG_NO'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_policy_portability_migration'
) }}
