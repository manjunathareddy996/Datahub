/* RESHAPED (Option C) from hcon4 central view 45 into the partner thin form.
   Procedure: the reusable 8-step reshape established by the pilot (stitch_01).

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_policy_coinsurance  (filename tail; stage_45 reads src.* and
                       computes the per-satellite hashdiffs, so output_columns carries
                       ALL family-3 payload attrs of the central view). NOTE: this stitch
                       is the policy__policy_coinsurance SATELLITE-feeding file, NOT a
                       lnk_ file -- it is reshapable. (The lnk_ misfit is stitch_43.)
   sources           : 8 (t0..t7); central view 45 has only 8 tN CTEs.
   key_column per src:
     t0 HUB_POLICY_BK__CONTRACT_ID, t1 HUB_POLICY_BK__CONTRACT_ID,
     t2 HUB_POLICY_BK__POLICY_REF, t3 HUB_POLICY_BK__POLICY_REF,
     t4 HUB_POLICY_BK__CONTRACT_ID, t5 HUB_POLICY_BK__CONTRACT_ID,
     t6 HUB_POLICY_BK__CONTRACT_ID.
   GRAIN DEVIATION (source carries NO HUB_POLICY key; keep real join key per rule 4):
     t7 (stg_ctngy_scheme_plans): key_column=HUB_PARTY_BK__PARTNER_PARTNER_ID
         (central view joined t7 on this to coalesce(t3.LDR_PID, t4.MEMBER_ID)).
   same-alias payload collisions (kept FIRST in central-view COALESCE order):
     RATING_FACTOR_NAME : kept t2.prem_cal_1 (dropped t2.prem_cal_2, t2.prem_cal_3).
   merge order : R8 precedence transcribed verbatim per attr.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_ba_ccp_insured_details',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'borrower_type', 'tgt': 'interest_type'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(contract_id),''),'') || '|INSURED|' || coalesce(nullif(trim(first_name),''),'') || '|' || coalesce(nullif(trim(middle_name),''),'') || '|' || coalesce(nullif(trim(last_name),''),'') || '|' || coalesce(nullif(trim(to_char(date_of_birth)),''),''), '|INSURED||||'))))", 'tgt': 'HUB_PARTY_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(contract_id),''),'') || '|NOMINEE|' || coalesce(nullif(trim(nominee_name),''),''), '|NOMINEE|'))))", 'tgt': 'HUB_PARTY_BK__CONTRACT_ID_NOMINEE_NOMINEE_NAME'},
            {'src_expr': "nullif(trim(contract_id),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(contract_id),''),'') || '|INSURED|' || coalesce(nullif(trim(first_name),''),'') || '|' || coalesce(nullif(trim(middle_name),''),'') || '|' || coalesce(nullif(trim(last_name),''),'') || '|' || coalesce(nullif(trim(to_char(date_of_birth)),''),''), '|INSURED||||'))))", 'tgt': 'HUB_RISK_OBJECT_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BA_CCP_INSURED_DETAILS'
    },
    {
        'model': 'stg_ba_ccp_sub_mater_dtls',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'co_ins_type',     'tgt': 'co_insurance_arrangement_type'},
            {'src': 'bank_name',       'tgt': 'financier_name'},
            {'src': 'sanctioned_loan', 'tgt': 'loan_amount'},
            {'src': 'loan_period',     'tgt': 'loan_tenor'},
            {'src': 'type_loan',       'tgt': 'loan_type'},
            {'src': 'other_loan_type', 'tgt': 'other_loan_type_description'},
            {'src': 'refund_reason',   'tgt': 'refund_reason'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('LOANACC:' || nullif(trim(LOAN_ACC_NUMBER),''), 'LOANACC:')", 'tgt': 'HUB_RISK_OBJECT_BK__LOANACC_LOAN_ACC_NUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BA_CCP_SUB_MATER_DTLS'
    },
    {
        'model': 'stg_ecard_pol_dtls_config',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'natadd_brnchld_day', 'tgt': 'natural_addition_newborn_days'},
            {'src': 'alwnat_dtls',        'tgt': 'natural_addition_rule_indicator'},
            {'src': 'natadd_spouse_day',  'tgt': 'natural_addition_spouse_days'},
            {'src': 'prem_cal_1',         'tgt': 'rating_factor_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'quote_ref',  'tgt': 'HUB_QUOTE_BK__QUOTE_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ECARD_POL_DTLS_CONFIG'
    },
    {
        'model': 'stg_hm_coinsu_clm_dtls',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'insurco_policy_no', 'tgt': 'co_insurance_reference_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id',   'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'ldr_pid',    'tgt': 'HUB_PARTY_BK__LDR_PID'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'prod_cd',    'tgt': 'HUB_PRODUCT_BK__PROD_CD'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_COINSU_CLM_DTLS'
    },
    {
        'model': 'stg_hm_member_dtls',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'refund_premium', 'tgt': 'net_refund_amount'}
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
        'model': 'stg_hm_member_hlth_dtls',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(HAT_ID_CITY),''),'') || '|' || coalesce(nullif(trim(HAT_ID_STATE),''),''), '|'))))", 'tgt': 'HUB_LOCATION_BK__HAT_ID_CITY_HAT_ID_STATE'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('MEMBER:' || coalesce(nullif(trim(CONTRACT_ID),''),'') || '#' || coalesce(nullif(trim(MEMBER_ID),''),''), 'MEMBER:#')", 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_CONTRACT_ID_MEMBER_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_MEMBER_HLTH_DTLS'
    },
    {
        'model': 'stg_policy_summary',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'coins_dtls',      'tgt': 'co_insurance_details_text'},
            {'src': 'coins_our_share', 'tgt': 'co_insurance_share_percentage'},
            {'src': 'vehicle_make',    'tgt': 'make'},
            {'src': 'vehicle_model',   'tgt': 'model'},
            {'src': 'vehicle_type',    'tgt': 'vehicle_class'},
            {'src': 'vehicle_subtype', 'tgt': 'vehicle_sub_class'}
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
        'model': 'stg_ctngy_scheme_plans',
        'alias': 't7',
        'key_column': 'HUB_PARTY_BK__PARTNER_PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_dob_yn',        'tgt': 'dob_validation_rule'},
            {'src': 'mem_backdate_limit',   'tgt': 'member_backdating_limit_days'},
            {'src': 'mem_data_bulk_upload', 'tgt': 'member_bulk_upload_allowed_indicator'},
            {'src': 'pin_code_val_yn',      'tgt': 'member_pin_code_validation_required_indicator'},
            {'src': 'self_exclude',         'tgt': 'self_member_exclusion_allowed_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('PARTNER:' || nullif(trim(PARTNER_ID),''), 'PARTNER:')", 'tgt': 'HUB_PARTY_BK__PARTNER_PARTNER_ID'},
            {'src_expr': "nullif('SCHEMEPLAN:' || nullif(trim(SCHEME_CODE),'') || '|' || nullif(trim(PLAN_ID),''), 'SCHEMEPLAN:|')", 'tgt': 'HUB_PRODUCT_BK__SCHEMEPLAN_SCHEME_CODE_PLAN_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_CTNGY_SCHEME_PLANS'
    }
] -%}

{%- set output_columns = [
    'co_insurance_arrangement_type',
    'co_insurance_details_text',
    'co_insurance_reference_number',
    'co_insurance_share_percentage',
    'dob_validation_rule',
    'financier_name',
    'interest_type',
    'loan_amount',
    'loan_tenor',
    'loan_type',
    'make',
    'member_backdating_limit_days',
    'member_bulk_upload_allowed_indicator',
    'member_pin_code_validation_required_indicator',
    'model',
    'natural_addition_newborn_days',
    'natural_addition_rule_indicator',
    'natural_addition_spouse_days',
    'net_refund_amount',
    'other_loan_type_description',
    'rating_factor_name',
    'refund_reason',
    'self_member_exclusion_allowed_indicator',
    'vehicle_class',
    'vehicle_sub_class'
] -%}

{%- set coalesce_rules = {
    'co_insurance_arrangement_type': ['t1'],
    'co_insurance_details_text': ['t6'],
    'co_insurance_reference_number': ['t3'],
    'co_insurance_share_percentage': ['t6'],
    'dob_validation_rule': ['t7'],
    'financier_name': ['t1'],
    'interest_type': ['t0'],
    'loan_amount': ['t1'],
    'loan_tenor': ['t1'],
    'loan_type': ['t1'],
    'make': ['t6'],
    'member_backdating_limit_days': ['t7'],
    'member_bulk_upload_allowed_indicator': ['t7'],
    'member_pin_code_validation_required_indicator': ['t7'],
    'model': ['t6'],
    'natural_addition_newborn_days': ['t2'],
    'natural_addition_rule_indicator': ['t2'],
    'natural_addition_spouse_days': ['t2'],
    'net_refund_amount': ['t4'],
    'other_loan_type_description': ['t1'],
    'rating_factor_name': ['t2'],
    'refund_reason': ['t1'],
    'self_member_exclusion_allowed_indicator': ['t7'],
    'vehicle_class': ['t6'],
    'vehicle_sub_class': ['t6']
} %}

{%- set hub_keys = [
    {'name': 'HUB_CLAIM_BK', 'expr': 't3.HUB_CLAIM_BK__CLAIM_ID'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 't4.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 't4.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't5.HUB_LOCATION_BK__HAT_ID_CITY_HAT_ID_STATE'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t3.HUB_PARTY_BK__LDR_PID, t4.HUB_PARTY_BK__MEMBER_ID, t7.HUB_PARTY_BK__PARTNER_PARTNER_ID)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__CONTRACT_ID, t2.HUB_POLICY_BK__POLICY_REF, t3.HUB_POLICY_BK__POLICY_REF, t4.HUB_POLICY_BK__CONTRACT_ID, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t3.HUB_PRODUCT_BK__PROD_CD, t4.HUB_PRODUCT_BK__PRODUCT_CODE, t6.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t7.HUB_PRODUCT_BK__SCHEMEPLAN_SCHEME_CODE_PLAN_ID)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 't2.HUB_QUOTE_BK__QUOTE_REF'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t0.HUB_RISK_OBJECT_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME, t1.HUB_RISK_OBJECT_BK__LOANACC_LOAN_ACC_NUMBER, t5.HUB_RISK_OBJECT_BK__MEMBER_CONTRACT_ID_MEMBER_ID)'},
    {'name': 'T0__HUB_PARTY_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME', 'expr': 't0.HUB_PARTY_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME'},
    {'name': 'T0__HUB_PARTY_BK__CONTRACT_ID_NOMINEE_NOMINEE_NAME', 'expr': 't0.HUB_PARTY_BK__CONTRACT_ID_NOMINEE_NOMINEE_NAME'},
    {'name': 'T6__HUB_LOCATION_BK__ADDRESS_CITY_REGION', 'expr': 't6.HUB_LOCATION_BK__ADDRESS_CITY_REGION'},
    {'name': 'T6__HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE', 'expr': 't6.HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE'},
    {'name': 'T6__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't6.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T6__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't6.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T6__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't6.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T6__HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME', 'expr': 't6.HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME'},
    {'name': 'T6__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't6.HUB_PARTY_BK__PARTID_PART_ID'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_policy_coinsurance'
) }}
