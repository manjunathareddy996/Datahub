/* RESHAPED (Option C) from central view 30 into the partner thin form.
   Procedure: the pilot's 9-step REUSABLE RESHAPE PROCEDURE
   (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_party_group_household
     Central view 30 feeds 2 satellites (SAT_PARTY_GROUP_HOUSEHOLD, SAT_QUOTE_HEADER);
     this reshape carries ONLY the SAT_PARTY_GROUP_HOUSEHOLD payload (filename tail +
     stage_30 SAT_PARTY_GROUP_HOUSEHOLD_HASHDIFF: RELATIONSHIP_COMPOSITION, MEMBER_COUNT).
   key_column per src: each source's HUB_POLICY_BK__* column (HUB_POLICY grain).
     - t9 (BJAZ_GRP_HLT_DTLS): carries NO HUB_POLICY key. The central view joined it on
       HUB_ASSESSMENT_BK__SCRUTINY_NO. DOCUMENTED GRAIN DEVIATION: key_column=
       HUB_ASSESSMENT_BK__SCRUTINY_NO (its real join key). Kept as a source only so the
       family-1 hub_keys exprs referencing t9.* resolve.
   same-alias drops  : none.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_dt_premium',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_combo',      'tgt': 'relationship_composition'},
            {'src': 'total_member_nos',  'tgt': 'member_count'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno',    'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'user_id',      'tgt': 'HUB_PARTY_BK__USER_ID'},
            {'src_expr': 'contract_id',  'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_PREMIUM'
    },
    {
        'model': 'stg_hcp_prod_8432_ecp_loader',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_family_mem_combination', 'tgt': 'relationship_composition'}
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
            {'src': 'md_family_mem_combination', 'tgt': 'relationship_composition'}
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
        'model': 'stg_ecard_pol_dtls_config',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'quote_ref',  'tgt': 'HUB_QUOTE_BK__QUOTE_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ECARD_POL_DTLS_CONFIG'
    },
    {
        'model': 'stg_enroll_scr_dtls',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(SCRUTINY_NO),'')",  'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')",  'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif(trim(QUOTATION_NO),'')", 'tgt': 'HUB_QUOTE_BK__QUOTATION_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_ENROLL_SCR_DTLS'
    },
    {
        'model': 'stg_grp_hlt_coverage_dtls',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(reg_no),'')", 'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(product),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': "nullif(trim(quote_no),'')", 'tgt': 'HUB_QUOTE_BK__QUOTE_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_GRP_HLT_COVERAGE_DTLS'
    },
    {
        'model': 'stg_grp_hlt_mem_dtls',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(trim(COVERAGE),''))))", 'tgt': 'HUB_COVERAGE_BK__COVERAGE'},
            {'src_expr': "nullif(trim(REG_NO),'')", 'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(PRODUCT),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': "nullif(trim(QUOTE_NO),'')", 'tgt': 'HUB_QUOTE_BK__QUOTE_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_GRP_HLT_MEM_DTLS'
    },
    {
        'model': 'stg_hg_pol_dtls',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'total_mem_cnt', 'tgt': 'member_count'}
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
        'model': 'stg_ws_family_dtls_bandhan',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'familycombination', 'tgt': 'relationship_composition'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pmasterpolicynumber', 'tgt': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_WS_FAMILY_DTLS_BANDHAN'
    },
    {
        'model': 'stg_grp_hlt_dtls',
        'alias': 't9',
        'key_column': 'HUB_ASSESSMENT_BK__SCRUTINY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
    'relationship_composition',
    'member_count'
] -%}

{%- set coalesce_rules = {
    'relationship_composition': ['t0', 't1', 't2', 't8'],
    'member_count':             ['t0', 't7']
} %}

{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t4.HUB_ASSESSMENT_BK__SCRUTINY_NO, t9.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 'coalesce(t0.HUB_COVERAGE_BK__HCP_SEQNO, t6.HUB_COVERAGE_BK__COVERAGE, t7.HUB_COVERAGE_BK__COVER_CODE)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t1.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t2.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__USER_ID, t7.HUB_PARTY_BK__PART_ID)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__POLICY_REF, t4.HUB_POLICY_BK__CONTRACT_ID, t5.HUB_POLICY_BK__REG_NO, t6.HUB_POLICY_BK__REG_NO, t7.HUB_POLICY_BK__CONTRACT_ID, t8.HUB_POLICY_BK__PMASTERPOLICYNUMBER)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PRODUCT_CODE, t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t5.HUB_PRODUCT_BK__PRODUCT, t6.HUB_PRODUCT_BK__PRODUCT, t7.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t9.HUB_PRODUCT_BK__PRODUCT)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t7.HUB_PROPOSAL_BK__QUOTE_REF_NO, t9.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t3.HUB_QUOTE_BK__QUOTE_REF, t4.HUB_QUOTE_BK__QUOTATION_NO, t5.HUB_QUOTE_BK__QUOTE_NO, t6.HUB_QUOTE_BK__QUOTE_NO, t7.HUB_QUOTE_BK__QUOTE_REF_NO, t9.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 't2.HUB_RISK_OBJECT_BK__MD_SEQ_NO'},
    {'name': 'T1__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't1.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T2__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't2.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T7__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't7.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T7__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't7.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T9__HUB_ORG_UNIT_BK__BRANCH', 'expr': 't9.HUB_ORG_UNIT_BK__BRANCH'},
    {'name': 'T9__HUB_ORG_UNIT_BK__DEPARTMENT', 'expr': 't9.HUB_ORG_UNIT_BK__DEPARTMENT'},
    {'name': 'T9__HUB_POLICY_BK__POLICY_NO', 'expr': 't9.HUB_POLICY_BK__POLICY_NO'},
    {'name': 'T9__HUB_POLICY_BK__PREV_POL_REF', 'expr': 't9.HUB_POLICY_BK__PREV_POL_REF'},
    {'name': 'T9__HUB_POLICY_BK__REG_NO', 'expr': 't9.HUB_POLICY_BK__REG_NO'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_party_group_household'
) }}
