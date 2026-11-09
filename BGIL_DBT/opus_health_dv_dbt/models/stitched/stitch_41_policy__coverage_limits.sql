/* RESHAPED (Option C) from hcon4 central view 41 into the partner thin form.
   Procedure: the reusable 8-step reshape established by the pilot (stitch_01).

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_coverage_limits  (filename tail; stage_41 reads src.* and
                       computes 4 hashdiffs, so output_columns carries ALL family-3
                       payload attrs of the central view).
   key_column per src:
     t0 HUB_POLICY_BK__CONTRACT_ID, t1 HUB_POLICY_BK__CONTRACT_ID,
     t2 HUB_POLICY_BK__POLICY_REF, t3 HUB_POLICY_BK__MASTER_POLICY_NO,
     t4 HUB_POLICY_BK__REG_NO, t5 HUB_POLICY_BK__CONTRACT_ID,
     t6 HUB_POLICY_BK__POLICY_REF, t8 HUB_POLICY_BK__POLICY_NO.
   GRAIN DEVIATIONS (source carries NO HUB_POLICY key; keep real join key per rule 4 so
   its hub_keys[].expr terms still resolve):
     t7 (stg_ctngy_scheme_plans): key_column=HUB_PARTY_BK__PARTNER_PARTNER_ID
         (central view joined t7 on this to coalesce(t1.PART_ID,t2.CUSTOMER_ID,...)).
     t9 (stg_starpkg_cov_prem_mst): key_column=HUB_COVERAGE_BK__COVER_CODE
         (central view joined t9 on this to t1.HUB_COVERAGE_BK__HCP_SEQNO).
   same-alias payload collisions (kept FIRST in central-view COALESCE order):
     NET_HEAD_PREMIUM : kept t5.adon_premium (dropped t5.float_premium);
                        kept t0.acc_prem (dropped t0.ci_prem, t0.emi_prem, t0.sec1_prem,
                        t0.sec2_burgcontent_prem, t0.sec2_burgjwel_prem,
                        t0.sec2_firebuild_prem, t0.sec2_firecontent_prem).
   merge order : R8 precedence transcribed verbatim per attr.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_ba_ccp_sub_mater_dtls',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'acc_prem', 'tgt': 'net_head_premium'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('LOANACC:' || nullif(trim(LOAN_ACC_NUMBER),''), 'LOANACC:')", 'tgt': 'HUB_RISK_OBJECT_BK__LOANACC_LOAN_ACC_NUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BA_CCP_SUB_MATER_DTLS'
    },
    {
        'model': 'stg_hcp_dt_mem',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'prem_base_cover', 'tgt': 'base_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno',   'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'part_id',     'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_MEM'
    },
    {
        'model': 'stg_bandhan_medi_clam',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'number_of_days',  'tgt': 'indemnity_period'},
            {'src': 'per_day_benifit', 'tgt': 'per_day_benefit_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',   'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'reference_id',  'tgt': 'HUB_CLAIM_BK__REFERENCE_ID'},
            {'src_expr': 'partner_id',    'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'customer_id',   'tgt': 'HUB_PARTY_BK__CUSTOMER_ID'},
            {'src_expr': 'policy_ref',    'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'plan_id',       'tgt': 'HUB_PRODUCT_BK__PLAN_ID'},
            {'src_expr': 'product_code',  'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_BANDHAN_MEDI_CLAM'
    },
    {
        'model': 'stg_gp_hospital_cash',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__MASTER_POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'no_of_days', 'tgt': 'indemnity_period'}
        ],
        'hub_key_columns': [
            {'src_expr': 'imd_code',            'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 's_account_number',    'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER'},
            {'src_expr': 'user_id',             'tgt': 'HUB_PARTY_BK__USER_ID'},
            {'src_expr': 'master_policy_no',    'tgt': 'HUB_POLICY_BK__MASTER_POLICY_NO'},
            {'src_expr': 'product_code',        'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 'kgc_proposal_number', 'tgt': 'HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER'},
            {'src_expr': 'reference_id',        'tgt': 'HUB_PROPOSAL_BK__REFERENCE_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GP_HOSPITAL_CASH'
    },
    {
        'model': 'stg_grp_hlt_maternity_dtls',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'prime_rider_base_prem', 'tgt': 'base_amount'},
            {'src': 'co_payment_per',        'tgt': 'co_payment_percentage'},
            {'src': 'family_definition',     'tgt': 'family_definition'},
            {'src': 'permium_co_buffer',     'tgt': 'net_head_premium'}
        ],
        'hub_key_columns': [
            {'src_expr': 'reg_no',       'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product',      'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_MATERNITY_DTLS'
    },
    {
        'model': 'stg_hcf_member_dtls',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'adon_premium', 'tgt': 'net_head_premium'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no',  'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id','tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no',  'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_health_webservice_info',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'surg_cover_base_prem', 'tgt': 'base_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': 'deal_id',         'tgt': 'HUB_AGREEMENT_BK__DEAL_ID'},
            {'src_expr': 'scrutiny_no',     'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'partner_id',      'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'loan_accno',      'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__LOAN_ACCNO'},
            {'src_expr': 'ptransaction_id', 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__PTRANSACTION_ID'},
            {'src_expr': 'branch_code',     'tgt': 'HUB_ORG_UNIT_BK__BRANCH_CODE'},
            {'src_expr': 'dept_code',       'tgt': 'HUB_ORG_UNIT_BK__DEPT_CODE'},
            {'src_expr': 'policy_ref',      'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'product_code',    'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HEALTH_WEBSERVICE_INFO'
    },
    {
        'model': 'stg_ctngy_scheme_plans',
        'alias': 't7',
        'key_column': 'HUB_PARTY_BK__PARTNER_PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'any_one_cvr_mand',       'tgt': 'at_least_one_coverage_mandatory_indicator'},
            {'src': 'imd_code',               'tgt': 'authorised_channels'},
            {'src': 'sub_imd_code',           'tgt': 'authorised_sub_intermediary_code_set'},
            {'src': 'backdate_imd_code',      'tgt': 'backdating_authorised_intermediary_code_set'},
            {'src': 'generic_sms_imds',       'tgt': 'generic_sms_intermediary_code_set'},
            {'src': 'imd_backdate_valyn',     'tgt': 'intermediary_backdating_validation_required_indicator'},
            {'src': 'imd_validate',           'tgt': 'intermediary_code_validation_required_indicator'},
            {'src': 'block_multiple_cvr_mand','tgt': 'multiple_mandatory_coverage_selection_blocked_indicator'},
            {'src': 'days_in_advance',        'tgt': 'new_business_advance_issuance_days'},
            {'src': 'nb_blocked_yn',          'tgt': 'new_business_blocked_indicator'},
            {'src': 'specific_sms_imds',      'tgt': 'plan_specific_sms_intermediary_code_set'},
            {'src': 'aport_blocked',          'tgt': 'port_in_blocked_indicator'},
            {'src': 'isrenew',                'tgt': 'renewability_type'},
            {'src': 'rnw_days_in_advance',    'tgt': 'renewal_advance_issuance_days'},
            {'src': 'sub_imd_validate',       'tgt': 'sub_intermediary_code_validation_required_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('PARTNER:' || nullif(trim(PARTNER_ID),''), 'PARTNER:')", 'tgt': 'HUB_PARTY_BK__PARTNER_PARTNER_ID'},
            {'src_expr': "nullif('SCHEMEPLAN:' || nullif(trim(SCHEME_CODE),'') || '|' || nullif(trim(PLAN_ID),''), 'SCHEMEPLAN:|')", 'tgt': 'HUB_PRODUCT_BK__SCHEMEPLAN_SCHEME_CODE_PLAN_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_CTNGY_SCHEME_PLANS'
    },
    {
        'model': 'stg_grp_hlt_dtls',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pp_suminsured',       'tgt': 'per_person_limit'},
            {'src': 'health_prime_rider_fam_def', 'tgt': 'family_definition'},
            {'src': 'per_person_prem_type','tgt': 'premium_basis'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',  'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'branch',       'tgt': 'HUB_ORG_UNIT_BK__BRANCH'},
            {'src_expr': 'department',   'tgt': 'HUB_ORG_UNIT_BK__DEPARTMENT'},
            {'src_expr': 'policy_no',    'tgt': 'HUB_POLICY_BK__POLICY_NO'},
            {'src_expr': 'prev_pol_ref', 'tgt': 'HUB_POLICY_BK__PREV_POL_REF'},
            {'src_expr': 'reg_no',       'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product',      'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_ref_no', 'tgt': 'HUB_PROPOSAL_BK__QUOTE_REF_NO'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_DTLS'
    },
    {
        'model': 'stg_starpkg_cov_prem_mst',
        'alias': 't9',
        'key_column': 'HUB_COVERAGE_BK__COVER_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(COVER_CODE),'')", 'tgt': 'HUB_COVERAGE_BK__COVER_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_STARPKG_COV_PREM_MST'
    }
] -%}

{%- set output_columns = [
    'at_least_one_coverage_mandatory_indicator',
    'authorised_channels',
    'authorised_sub_intermediary_code_set',
    'backdating_authorised_intermediary_code_set',
    'base_amount',
    'co_payment_percentage',
    'family_definition',
    'generic_sms_intermediary_code_set',
    'indemnity_period',
    'intermediary_backdating_validation_required_indicator',
    'intermediary_code_validation_required_indicator',
    'multiple_mandatory_coverage_selection_blocked_indicator',
    'net_head_premium',
    'new_business_advance_issuance_days',
    'new_business_blocked_indicator',
    'per_day_benefit_amount',
    'per_person_limit',
    'plan_specific_sms_intermediary_code_set',
    'port_in_blocked_indicator',
    'premium_basis',
    'renewability_type',
    'renewal_advance_issuance_days',
    'sub_intermediary_code_validation_required_indicator'
] -%}

{%- set coalesce_rules = {
    'at_least_one_coverage_mandatory_indicator': ['t7'],
    'authorised_channels': ['t7'],
    'authorised_sub_intermediary_code_set': ['t7'],
    'backdating_authorised_intermediary_code_set': ['t7'],
    'base_amount': ['t1', 't4', 't6'],
    'co_payment_percentage': ['t4'],
    'family_definition': ['t8', 't4'],
    'generic_sms_intermediary_code_set': ['t7'],
    'indemnity_period': ['t2', 't3'],
    'intermediary_backdating_validation_required_indicator': ['t7'],
    'intermediary_code_validation_required_indicator': ['t7'],
    'multiple_mandatory_coverage_selection_blocked_indicator': ['t7'],
    'net_head_premium': ['t4', 't5', 't0'],
    'new_business_advance_issuance_days': ['t7'],
    'new_business_blocked_indicator': ['t7'],
    'per_day_benefit_amount': ['t2'],
    'per_person_limit': ['t8'],
    'plan_specific_sms_intermediary_code_set': ['t7'],
    'port_in_blocked_indicator': ['t7'],
    'premium_basis': ['t8'],
    'renewability_type': ['t7'],
    'renewal_advance_issuance_days': ['t7'],
    'sub_intermediary_code_validation_required_indicator': ['t7']
} %}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't6.HUB_AGREEMENT_BK__DEAL_ID'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t2.HUB_ASSESSMENT_BK__SCRUTINY_NO, t6.HUB_ASSESSMENT_BK__SCRUTINY_NO, t8.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 't2.HUB_CLAIM_BK__REFERENCE_ID'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 'coalesce(t1.HUB_COVERAGE_BK__HCP_SEQNO, t9.HUB_COVERAGE_BK__COVER_CODE)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t2.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t5.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t3.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER, t6.HUB_FINANCIAL_ACCOUNT_BK__LOAN_ACCNO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 't6.HUB_FINANCIAL_TRANSACTION_BK__PTRANSACTION_ID'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't2.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t1.HUB_PARTY_BK__PART_ID, t2.HUB_PARTY_BK__CUSTOMER_ID, t3.HUB_PARTY_BK__USER_ID, t5.HUB_PARTY_BK__MEMBER_NO, t7.HUB_PARTY_BK__PARTNER_PARTNER_ID)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__CONTRACT_ID, t2.HUB_POLICY_BK__POLICY_REF, t3.HUB_POLICY_BK__MASTER_POLICY_NO, t4.HUB_POLICY_BK__REG_NO, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__POLICY_REF)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t3.HUB_PRODUCT_BK__PRODUCT_CODE, t4.HUB_PRODUCT_BK__PRODUCT, t6.HUB_PRODUCT_BK__PRODUCT_CODE, t7.HUB_PRODUCT_BK__SCHEMEPLAN_SCHEME_CODE_PLAN_ID, t8.HUB_PRODUCT_BK__PRODUCT)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 't8.HUB_PROPOSAL_BK__QUOTE_REF_NO'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t4.HUB_QUOTE_BK__QUOTE_SUB_NO, t8.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t0.HUB_RISK_OBJECT_BK__LOANACC_LOAN_ACC_NUMBER, t5.HUB_RISK_OBJECT_BK__MEMBER_NO)'},
    {'name': 'T2__HUB_PRODUCT_BK__PLAN_ID', 'expr': 't2.HUB_PRODUCT_BK__PLAN_ID'},
    {'name': 'T2__HUB_PRODUCT_BK__PRODUCT_CODE', 'expr': 't2.HUB_PRODUCT_BK__PRODUCT_CODE'},
    {'name': 'T3__HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER', 'expr': 't3.HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER'},
    {'name': 'T3__HUB_PROPOSAL_BK__REFERENCE_ID', 'expr': 't3.HUB_PROPOSAL_BK__REFERENCE_ID'},
    {'name': 'T6__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't6.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T6__HUB_ORG_UNIT_BK__DEPT_CODE', 'expr': 't6.HUB_ORG_UNIT_BK__DEPT_CODE'},
    {'name': 'T8__HUB_ORG_UNIT_BK__BRANCH', 'expr': 't8.HUB_ORG_UNIT_BK__BRANCH'},
    {'name': 'T8__HUB_ORG_UNIT_BK__DEPARTMENT', 'expr': 't8.HUB_ORG_UNIT_BK__DEPARTMENT'},
    {'name': 'T8__HUB_POLICY_BK__POLICY_NO', 'expr': 't8.HUB_POLICY_BK__POLICY_NO'},
    {'name': 'T8__HUB_POLICY_BK__PREV_POL_REF', 'expr': 't8.HUB_POLICY_BK__PREV_POL_REF'},
    {'name': 'T8__HUB_POLICY_BK__REG_NO', 'expr': 't8.HUB_POLICY_BK__REG_NO'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_coverage_limits'
) }}
