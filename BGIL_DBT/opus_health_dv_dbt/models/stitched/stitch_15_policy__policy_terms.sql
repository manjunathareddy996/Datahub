/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Procedure: the 9-step REUSABLE RESHAPE PROCEDURE documented in the pilot
   stitch_01_policy__policy_header.sql (task 4.1). Applied here by task 6.1.

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk'); satellite: SAT_POLICY_TERMS
   target_sat        : sat_policy_terms  (header "SAT_POLICY_TERMS" ==
                       stage_15 "SAT_POLICY_TERMS_HASHDIFF" == filename tail).
   key_column per src: each source's HUB_POLICY_BK__* column (the HUB_POLICY-grain key).
     - all 12 sources carry a HUB_POLICY_BK__* column -> used directly as key_column.
     - t11 (BJAZ_GRP_HLT_DTLS): carries HUB_POLICY_BK__POLICY_NO; key_column=
       HUB_POLICY_BK__POLICY_NO even though the central view's FULL OUTER joined t11 on
       HUB_ASSESSMENT_BK__SCRUTINY_NO (t11 is NOT in the HUB_POLICY_BK spine coalesce).
       Grain-aligned choice per rule 4.
   PAYLOAD same-alias collisions: none.
   merge order       : R8 precedence (v2 > legacy > delta3) preserved as the central
                       view's documented COALESCE order, transcribed verbatim per attr.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_prod_8428_gpg_loader',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plc_special_terms_conditions', 'tgt': 'special_conditions'}
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
        'model': 'stg_hcp_prod_8432_ecp_loader',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plc_aggr_deductible',          'tgt': 'deductible_total'},
            {'src': 'plc_special_terms_conditions', 'tgt': 'special_conditions'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',      'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',           'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'pd_bank_ref_no1_lac_sac', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC'},
            {'src_expr': 'pd_location_code',        'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',      'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',        'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',     'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',           'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',         'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8432_ECP_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8433_fhc_loader',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plc_special_terms_conditions', 'tgt': 'special_conditions'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',      'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',           'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'pd_bank_ref_no1_lac_sac', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC'},
            {'src_expr': 'pd_location_code',        'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',      'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',        'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',     'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',           'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',         'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
            {'src_expr': 'md_seq_no',               'tgt': 'HUB_RISK_OBJECT_BK__MD_SEQ_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8433_FHC_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8439_clh_loader',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plc_special_terms_conditions', 'tgt': 'special_conditions'}
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
        'model': 'stg_ctngy_gc_control',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'allow_inst_id_yn',        'tgt': 'instalment_identifier_allowed_indicator'},
            {'src': 'backdate',                'tgt': 'backdated_issuance_allowed_indicator'},
            {'src': 'cancel_expired_policy_yn','tgt': 'expired_policy_cancellation_allowed_indicator'},
            {'src': 'cancel_generic_yn',       'tgt': 'generic_cancellation_allowed_indicator'},
            {'src': 'co_payment',              'tgt': 'co_payment_percentage'},
            {'src': 'days_in_advance',         'tgt': 'maximum_advance_issuance_days'},
            {'src': 'longterm',                'tgt': 'long_term_term_allowed_indicator'},
            {'src': 'no_of_days_backdated',    'tgt': 'maximum_backdated_issuance_days'},
            {'src': 'policy_period_days',      'tgt': 'permitted_policy_period_days'},
            {'src': 'policy_period_months',    'tgt': 'permitted_policy_period_months'},
            {'src': 'policy_period_years',     'tgt': 'permitted_policy_period_years'},
            {'src': 'shortterm',               'tgt': 'short_period_term_allowed_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(POLICY_REF),'')", 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(PRODUCT_CODE),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_CTNGY_GC_CONTROL'
    },
    {
        'model': 'stg_gmc_bases_extn',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'clauses',       'tgt': 'attached_clauses_description'},
            {'src': 'exclusions',    'tgt': 'policy_exclusions_description'},
            {'src': 'sp_conditions', 'tgt': 'special_conditions'},
            {'src': 'sp_perils',     'tgt': 'special_perils_covered_description'},
            {'src': 'warrenties',    'tgt': 'warranty_conditions'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(contract_id),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_GMC_BASES_EXTN'
    },
    {
        'model': 'stg_gpg_pol_dtls',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'spcl_terms_cond', 'tgt': 'special_conditions'}
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
        'model': 'stg_hg_pol_dtls',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'aggregate_deductible', 'tgt': 'deductible_total'},
            {'src': 'voluntary_co_pay',     'tgt': 'co_payment_percentage'}
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
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'special_condition', 'tgt': 'special_conditions'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',  'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no',   'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HLT_ENSURE_MEM_DTLS'
    },
    {
        'model': 'stg_illness_bases_extn',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'special_condition', 'tgt': 'special_conditions'}
        ],
        'hub_key_columns': [
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ILLNESS_BASES_EXTN'
    },
    {
        'model': 'stg_starpkg_pol_dtls',
        'alias': 't10',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'co_pymt',         'tgt': 'co_payment_percentage'},
            {'src': 'other_condition', 'tgt': 'other_conditions'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('TXN:' || nullif(trim(TRANSACTION_ID),''), 'TXN:')", 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(PROD_CODE),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT_PROD_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_STARPKG_POL_DTLS'
    },
    {
        'model': 'stg_grp_hlt_dtls',
        'alias': 't11',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'continuity_guideline', 'tgt': 'continuity_guideline'},
            {'src': 'guideline_addition',   'tgt': 'member_addition_guideline'},
            {'src': 'guideline_deletion',   'tgt': 'member_deletion_guideline'},
            {'src': 'other_conditions',     'tgt': 'special_conditions'}
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
    }
] -%}

{%- set output_columns = [
    'special_conditions',
    'deductible_total',
    'continuity_guideline',
    'member_addition_guideline',
    'member_deletion_guideline',
    'co_payment_percentage',
    'long_term_term_allowed_indicator',
    'short_period_term_allowed_indicator',
    'backdated_issuance_allowed_indicator',
    'maximum_advance_issuance_days',
    'instalment_identifier_allowed_indicator',
    'permitted_policy_period_years',
    'permitted_policy_period_months',
    'permitted_policy_period_days',
    'generic_cancellation_allowed_indicator',
    'expired_policy_cancellation_allowed_indicator',
    'maximum_backdated_issuance_days',
    'warranty_conditions',
    'policy_exclusions_description',
    'special_perils_covered_description',
    'attached_clauses_description',
    'other_conditions'
] -%}

{#-- coalesce_rules: precedence order transcribed from the central view's final-SELECT
     payload COALESCEs. Single-alias rules emit a bare column reference (macro behaviour). --#}
{%- set coalesce_rules = {
    'special_conditions':                            ['t0', 't1', 't2', 't3', 't6', 't11', 't8', 't9', 't5'],
    'deductible_total':                              ['t1', 't7'],
    'continuity_guideline':                          ['t11'],
    'member_addition_guideline':                     ['t11'],
    'member_deletion_guideline':                     ['t11'],
    'co_payment_percentage':                         ['t4', 't7', 't10'],
    'long_term_term_allowed_indicator':              ['t4'],
    'short_period_term_allowed_indicator':           ['t4'],
    'backdated_issuance_allowed_indicator':          ['t4'],
    'maximum_advance_issuance_days':                 ['t4'],
    'instalment_identifier_allowed_indicator':       ['t4'],
    'permitted_policy_period_years':                 ['t4'],
    'permitted_policy_period_months':                ['t4'],
    'permitted_policy_period_days':                  ['t4'],
    'generic_cancellation_allowed_indicator':        ['t4'],
    'expired_policy_cancellation_allowed_indicator': ['t4'],
    'maximum_backdated_issuance_days':               ['t4'],
    'warranty_conditions':                           ['t5'],
    'policy_exclusions_description':                 ['t5'],
    'special_perils_covered_description':            ['t5'],
    'attached_clauses_description':                  ['t5'],
    'other_conditions':                              ['t10']
} %}

{#-- hub_keys: transcribed VERBATIM from the central view's final SELECT.
     Family 1 = merged-spine BKs (coalesce over alias.tgt). Family 2 = auxiliary
     per-source BKs (single alias.tgt, name prefixed TN__). Order preserved. --#}
{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t3.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t6.HUB_ASSESSMENT_BK__SCRUTINY_NO, t11.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 't7.HUB_COVERAGE_BK__COVER_CODE'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t7.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t8.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t0.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t1.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t2.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t3.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t6.HUB_FINANCIAL_ACCOUNT_BK__LMS_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 't10.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t0.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t3.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t6.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t7.HUB_PARTY_BK__PART_ID, t8.HUB_PARTY_BK__MEMBER_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__POL_SERIAL_NO, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__POL_SERIAL_NO, t4.HUB_POLICY_BK__POLICY_REF, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__REFERENCE_ID, t7.HUB_POLICY_BK__CONTRACT_ID, t8.HUB_POLICY_BK__CONTRACT_ID, t9.HUB_POLICY_BK__CONTRACT_ID, t10.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t3.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t4.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t6.HUB_PRODUCT_BK__PRODUCT_CODE, t7.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t10.HUB_PRODUCT_BK__PRODUCT_PROD_CODE, t11.HUB_PRODUCT_BK__PRODUCT)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t7.HUB_PROPOSAL_BK__QUOTE_REF_NO, t11.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t7.HUB_QUOTE_BK__QUOTE_REF_NO, t11.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_REINSURANCE_TREATY_BK', 'expr': 't6.HUB_REINSURANCE_TREATY_BK__RE_INSU'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t0.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t2.HUB_RISK_OBJECT_BK__MD_SEQ_NO)'},
    {'name': 'T0__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't0.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T1__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't1.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T2__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't2.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T3__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't3.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T3__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't3.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T3__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't3.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T6__HUB_PARTY_BK__BAGIC_E_CODE', 'expr': 't6.HUB_PARTY_BK__BAGIC_E_CODE'},
    {'name': 'T6__HUB_PARTY_BK__BAGIC_RM_E_CODE', 'expr': 't6.HUB_PARTY_BK__BAGIC_RM_E_CODE'},
    {'name': 'T6__HUB_PARTY_BK__IMD_CODE', 'expr': 't6.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T6__HUB_PARTY_BK__SUB_IMD_CODE', 'expr': 't6.HUB_PARTY_BK__SUB_IMD_CODE'},
    {'name': 'T7__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't7.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T7__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't7.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T11__HUB_ORG_UNIT_BK__BRANCH', 'expr': 't11.HUB_ORG_UNIT_BK__BRANCH'},
    {'name': 'T11__HUB_ORG_UNIT_BK__DEPARTMENT', 'expr': 't11.HUB_ORG_UNIT_BK__DEPARTMENT'},
    {'name': 'T11__HUB_POLICY_BK__POLICY_NO', 'expr': 't11.HUB_POLICY_BK__POLICY_NO'},
    {'name': 'T11__HUB_POLICY_BK__PREV_POL_REF', 'expr': 't11.HUB_POLICY_BK__PREV_POL_REF'},
    {'name': 'T11__HUB_POLICY_BK__REG_NO', 'expr': 't11.HUB_POLICY_BK__REG_NO'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_policy_terms'
) }}
