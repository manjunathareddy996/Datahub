/* RESHAPED (Option C) from hcon4 central view 42 into the partner thin form.
   Procedure: the reusable 8-step reshape established by the pilot (stitch_01).

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_fin_charge_rate  (filename tail; stage_42 reads src.* and
                       computes 4 hashdiffs, so output_columns carries ALL family-3
                       payload attrs of the central view).
   key_column per src:
     t0 HUB_POLICY_BK__POLICY_REF, t1 HUB_POLICY_BK__POLICY_REF,
     t2 HUB_POLICY_BK__CONTRACT_ID, t3 HUB_POLICY_BK__PMASTERPOLICYNUMBER,
     t4 HUB_POLICY_BK__CONTRACT_ID, t5 HUB_POLICY_BK__CONTRACT_ID,
     t6 HUB_POLICY_BK__POLICY_REF, t7 HUB_POLICY_BK__CONTRACT_ID,
     t8 HUB_POLICY_BK__CONTRACT_ID.
     t9 (stg_grp_hlt_dtls): key_column=HUB_POLICY_BK__POLICY_NO -- the HUB_POLICY-grain
        key it exposes (rule 4), even though the central view FULL OUTER joined t9 on
        HUB_ASSESSMENT_BK__SCRUTINY_NO = t2.HUB_ASSESSMENT_BK__SCRUTINY_NO. Grain-aligned
        choice per pilot t41 precedent; no HUB_POLICY key is missing on view 42.
   same-alias payload collisions (kept FIRST in central-view COALESCE order):
     COMMISSION_AMOUNT : kept t7.main_agent_comm_amt (dropped t7.sub_agent_comm_amt);
                         kept t8.main_agent_comm_amt (dropped t8.sub_agent_comm_amt).
     COMMISSION_RATE   : kept t7.main_agent_comm_rate (dropped t7.sub_agent_comm_rate);
                         kept t8.main_agent_comm_rate (dropped t8.sub_agent_comm_rate).
   merge order : R8 precedence transcribed verbatim per attr.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_card_dtls',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'assignee',       'tgt': 'assignee_reference'},
            {'src': 'floater_or_not', 'tgt': 'floater_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'card_no',    'tgt': 'HUB_DOCUMENT_BK__CARD_NO'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_CARD_DTLS'
    },
    {
        'model': 'stg_ecard_pol_dtls_config',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'comp_contr',        'tgt': 'contributory_indicator'},
            {'src': 'comp_contr_amt',    'tgt': 'employer_contribution_amount'},
            {'src': 'comp_cntrper',      'tgt': 'employer_contribution_percentage'},
            {'src': 'deactive_pol_date', 'tgt': 'termination_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'quote_ref',  'tgt': 'HUB_QUOTE_BK__QUOTE_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ECARD_POL_DTLS_CONFIG'
    },
    {
        'model': 'stg_enroll_scr_dtls',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'commision',               'tgt': 'commission_rate'},
            {'src': 'no_of_dependents',        'tgt': 'dependent_member_count'},
            {'src': 'relationship',            'tgt': 'eligible_relationship_set'},
            {'src': 'risk_covered',            'tgt': 'family_definition_description'},
            {'src': 'members_per_family',      'tgt': 'maximum_members_per_family'},
            {'src': 'total_member_count',      'tgt': 'member_count'},
            {'src': 'parental_si_restriction', 'tgt': 'parental_sum_insured_restriction'},
            {'src': 'no_of_employees',         'tgt': 'primary_member_count'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(SCRUTINY_NO),'')", 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif(trim(QUOTATION_NO),'')", 'tgt': 'HUB_QUOTE_BK__QUOTATION_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_ENROLL_SCR_DTLS'
    },
    {
        'model': 'stg_generic_loader_log_table',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'intermediary', 'tgt': 'intermediary_reference'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partnerid',           'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID'},
            {'src_expr': 'location_code',       'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode',        'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc',          'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location',     'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location',       'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'pmasterpolicynumber', 'tgt': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER'},
            {'src_expr': 'planid',              'tgt': 'HUB_PRODUCT_BK__PLANID'},
            {'src_expr': 'schemecode',          'tgt': 'HUB_PRODUCT_BK__SCHEMECODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GENERIC_LOADER_LOG_TABLE'
    },
    {
        'model': 'stg_grp_tpa_extn',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'service_charge_amt',  'tgt': 'charge_amount'},
            {'src': 'service_charge_rate', 'tgt': 'charge_rate'}
        ],
        'hub_key_columns': [
            {'src_expr': 'tpa_code',    'tgt': 'HUB_PARTY_BK__TPA_CODE'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_TPA_EXTN'
    },
    {
        'model': 'stg_hm_member_dtls',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'ctny_master_contract_id', 'tgt': 'master_policy_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',   'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'bank_ac_no',   'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
            {'src_expr': 'member_id',    'tgt': 'HUB_PARTY_BK__MEMBER_ID'},
            {'src_expr': 'contract_id',  'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_pmsby_data_web_service',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'imd_code', 'tgt': 'imd_code'}
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
        'model': 'stg_policy_bases_extn',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'brokerage_amt',        'tgt': 'brokerage_amount'},
            {'src': 'main_agent_comm_amt',  'tgt': 'commission_amount'},
            {'src': 'main_agent_comm_rate', 'tgt': 'commission_rate'},
            {'src': 'dealer_code',          'tgt': 'dealer_code'},
            {'src': 'main_agent_code',      'tgt': 'imd_code'},
            {'src': 'refer_date',           'tgt': 'referral_date'},
            {'src': 'refered_by_rule_engine','tgt': 'referred_by_rule_engine_indicator'},
            {'src': 'refer_by',             'tgt': 'referred_by_user_reference'},
            {'src': 'main_agent_sc_amt',    'tgt': 'service_charge_amount'},
            {'src': 'main_agent_sc_rate',   'tgt': 'service_charge_rate'},
            {'src': 'sub_agent_code',       'tgt': 'sub_imd_code'},
            {'src': 'referral_reason',      'tgt': 'underwriter_referral_reason'}
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
        'model': 'stg_policy_summary',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'main_agent_comm_amt',  'tgt': 'commission_amount'},
            {'src': 'main_agent_comm_rate', 'tgt': 'commission_rate'},
            {'src': 'dealer_code',          'tgt': 'dealer_code'},
            {'src': 'intermediary_code',    'tgt': 'imd_code'},
            {'src': 'main_agent_sc_amt',    'tgt': 'service_charge_amount'},
            {'src': 'main_agent_sc_rate',   'tgt': 'service_charge_rate'},
            {'src': 'sub_agent_code',       'tgt': 'sub_imd_code'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(ADDRESS),''),'') || '|' || coalesce(nullif(trim(CITY),''),'') || '|' || coalesce(nullif(trim(REGION),''),''), '||'))))", 'tgt': 'HUB_LOCATION_BK__ADDRESS_CITY_REGION'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(INSURED_ADDRESS),''),'') || '|' || coalesce(nullif(trim(PINCODE),''),''), '|'))))", 'tgt': 'HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE'},
            {'src_expr': "md5(normalise(upper(nullif(trim(MAILING_PINCODE),''))))", 'tgt': 'HUB_LOCATION_BK__MAILING_PINCODE'},
            {'src_expr': "nullif(trim(BRANCH_CODE),'')", 'tgt': 'HUB_ORG_UNIT_BK__BRANCH_CODE'},
            {'src_expr': "nullif(trim(DEPARTMENT_CODE),'')", 'tgt': 'HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(CONTRACT_ID),''),'') || '|INSURED|' || coalesce(nullif(trim(INSURED_NAME),''),''), '|INSURED|'))))", 'tgt': 'HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME'},
            {'src_expr': "nullif('PARTID:' || nullif(trim(PART_ID),''), 'PARTID:')", 'tgt': 'HUB_PARTY_BK__PARTID_PART_ID'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(PRODUCT_CODE),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_POLICY_SUMMARY'
    },
    {
        'model': 'stg_grp_hlt_dtls',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_count_expiring',     'tgt': 'expiring_member_count'},
            {'src': 'final_memb_count_atexpiry', 'tgt': 'final_member_count_at_expiry'},
            {'src': 'member_emp_header',         'tgt': 'group_size'},
            {'src': 'empr_emp_relation',         'tgt': 'group_type'},
            {'src': 'age_bracket',               'tgt': 'member_age_band'},
            {'src': 'total_no_proposed',         'tgt': 'member_count'},
            {'src': 'addition_in_year',          'tgt': 'members_added_in_year'},
            {'src': 'deletion_inayear',          'tgt': 'members_deleted_in_year'}
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
    }
] -%}

{%- set output_columns = [
    'assignee_reference',
    'brokerage_amount',
    'charge_amount',
    'charge_rate',
    'commission_amount',
    'commission_rate',
    'contributory_indicator',
    'dealer_code',
    'dependent_member_count',
    'eligible_relationship_set',
    'employer_contribution_amount',
    'employer_contribution_percentage',
    'expiring_member_count',
    'family_definition_description',
    'final_member_count_at_expiry',
    'floater_indicator',
    'group_size',
    'group_type',
    'imd_code',
    'intermediary_reference',
    'master_policy_number',
    'maximum_members_per_family',
    'member_age_band',
    'member_count',
    'members_added_in_year',
    'members_deleted_in_year',
    'parental_sum_insured_restriction',
    'primary_member_count',
    'referral_date',
    'referred_by_rule_engine_indicator',
    'referred_by_user_reference',
    'service_charge_amount',
    'service_charge_rate',
    'sub_imd_code',
    'termination_date',
    'underwriter_referral_reason'
] -%}

{%- set coalesce_rules = {
    'assignee_reference': ['t0'],
    'brokerage_amount': ['t7'],
    'charge_amount': ['t4'],
    'charge_rate': ['t4'],
    'commission_amount': ['t7', 't8'],
    'commission_rate': ['t2', 't7', 't8'],
    'contributory_indicator': ['t1'],
    'dealer_code': ['t7', 't8'],
    'dependent_member_count': ['t2'],
    'eligible_relationship_set': ['t2'],
    'employer_contribution_amount': ['t1'],
    'employer_contribution_percentage': ['t1'],
    'expiring_member_count': ['t9'],
    'family_definition_description': ['t2'],
    'final_member_count_at_expiry': ['t9'],
    'floater_indicator': ['t0'],
    'group_size': ['t9'],
    'group_type': ['t9'],
    'imd_code': ['t6', 't7', 't8'],
    'intermediary_reference': ['t3'],
    'master_policy_number': ['t5'],
    'maximum_members_per_family': ['t2'],
    'member_age_band': ['t9'],
    'member_count': ['t2', 't9'],
    'members_added_in_year': ['t9'],
    'members_deleted_in_year': ['t9'],
    'parental_sum_insured_restriction': ['t2'],
    'primary_member_count': ['t2'],
    'referral_date': ['t7'],
    'referred_by_rule_engine_indicator': ['t7'],
    'referred_by_user_reference': ['t7'],
    'service_charge_amount': ['t7', 't8'],
    'service_charge_rate': ['t7', 't8'],
    'sub_imd_code': ['t7', 't8'],
    'termination_date': ['t1'],
    'underwriter_referral_reason': ['t7']
} %}

{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t2.HUB_ASSESSMENT_BK__SCRUTINY_NO, t9.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 't0.HUB_DOCUMENT_BK__CARD_NO'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 't5.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 't7.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't6.HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 't7.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t4.HUB_PARTY_BK__TPA_CODE, t5.HUB_PARTY_BK__MEMBER_ID)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__POLICY_REF, t1.HUB_POLICY_BK__POLICY_REF, t2.HUB_POLICY_BK__CONTRACT_ID, t3.HUB_POLICY_BK__PMASTERPOLICYNUMBER, t4.HUB_POLICY_BK__CONTRACT_ID, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__POLICY_REF, t7.HUB_POLICY_BK__CONTRACT_ID, t8.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t5.HUB_PRODUCT_BK__PRODUCT_CODE, t7.HUB_PRODUCT_BK__PRODUCT_PRODUCT_4DIGIT_CODE, t8.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t9.HUB_PRODUCT_BK__PRODUCT)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 't9.HUB_PROPOSAL_BK__QUOTE_REF_NO'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t1.HUB_QUOTE_BK__QUOTE_REF, t2.HUB_QUOTE_BK__QUOTATION_NO, t9.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 't6.HUB_RISK_OBJECT_BK__CUSTID_CUST_ID'},
    {'name': 'T3__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't3.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T3__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't3.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T3__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't3.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T3__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't3.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T3__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't3.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T3__HUB_PRODUCT_BK__PLANID', 'expr': 't3.HUB_PRODUCT_BK__PLANID'},
    {'name': 'T3__HUB_PRODUCT_BK__SCHEMECODE', 'expr': 't3.HUB_PRODUCT_BK__SCHEMECODE'},
    {'name': 'T6__HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME', 'expr': 't6.HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME'},
    {'name': 'T6__HUB_PARTY_BK__CUST_ID', 'expr': 't6.HUB_PARTY_BK__CUST_ID'},
    {'name': 'T7__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't7.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T7__HUB_LOCATION_BK__PREV_INSURER_ADD', 'expr': 't7.HUB_LOCATION_BK__PREV_INSURER_ADD'},
    {'name': 'T8__HUB_LOCATION_BK__ADDRESS_CITY_REGION', 'expr': 't8.HUB_LOCATION_BK__ADDRESS_CITY_REGION'},
    {'name': 'T8__HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE', 'expr': 't8.HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE'},
    {'name': 'T8__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't8.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T8__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't8.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T8__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't8.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T8__HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME', 'expr': 't8.HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME'},
    {'name': 'T8__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't8.HUB_PARTY_BK__PARTID_PART_ID'},
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
    target_sat='sat_fin_charge_rate'
) }}
