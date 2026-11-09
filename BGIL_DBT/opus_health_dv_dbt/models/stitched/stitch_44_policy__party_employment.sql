/* RESHAPED (Option C) from hcon4 central view 44 into the partner thin form.
   Procedure: the reusable 8-step reshape established by the pilot (stitch_01).

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_party_employment  (filename tail; stage_44 reads src.* and
                       computes 2 hashdiffs, so output_columns carries ALL family-3
                       payload attrs of the central view).
   key_column per src: every source (t0..t9) carries a HUB_POLICY_BK__* column
                       (t1 = HUB_POLICY_BK__POL_SERIAL_NO, t3 = PMASTERPOLICYNUMBER, the
                       rest = CONTRACT_ID). NO grain deviation on view 44.
   same-alias payload collisions : NONE (each payload attr draws at most one col per alias).
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
            {'src': 'occupation', 'tgt': 'occupation_description'}
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
        'model': 'stg_hcp_prod_8439_clh_loader',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'md_occupation_type', 'tgt': 'occupation_code'}
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
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'hlth_ins_pol_yrs', 'tgt': 'continuous_years_insured'},
            {'src': 'occupation',       'tgt': 'occupation_description'}
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
        'model': 'stg_generic_loader_log_table',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'empstatus', 'tgt': 'employment_status'}
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
        'model': 'stg_hat_id_mem_detls',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'designation', 'tgt': 'designation'},
            {'src': 'profession',  'tgt': 'occupation_description'}
        ],
        'hub_key_columns': [
            {'src_expr': 'member_no',   'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HAT_ID_MEM_DETLS'
    },
    {
        'model': 'stg_hcf_member_dtls',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_occupation', 'tgt': 'occupation_description'}
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
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'occupation', 'tgt': 'occupation_description'}
        ],
        'hub_key_columns': [
            {'src_expr': 'part_id',     'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_hm_member_dtls',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'designation',    'tgt': 'designation'},
            {'src': 'monthly_salary', 'tgt': 'monthly_salary_amount'},
            {'src': 'occupation',     'tgt': 'occupation_description'}
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
        'model': 'stg_ihg_mem_dtls_extn',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'occupation', 'tgt': 'occupation_description'}
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
        'model': 'stg_sh_mem_dtls_extn',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'occupation', 'tgt': 'occupation_description'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no',      'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id',    'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_SH_MEM_DTLS_EXTN'
    }
] -%}

{%- set output_columns = [
    'continuous_years_insured',
    'designation',
    'employment_status',
    'monthly_salary_amount',
    'occupation_code',
    'occupation_description'
] -%}

{%- set coalesce_rules = {
    'continuous_years_insured': ['t2'],
    'designation': ['t4', 't7'],
    'employment_status': ['t3'],
    'monthly_salary_amount': ['t7'],
    'occupation_code': ['t1'],
    'occupation_description': ['t2', 't4', 't5', 't6', 't7', 't8', 't9', 't0']
} %}

{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 't1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t8.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t9.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t2.HUB_DOCUMENT_BK__MEDICAL_REPORT, t8.HUB_DOCUMENT_BK__MEDICAL_REPORT, t9.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t1.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t7.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 't1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t2.HUB_PARTY_BK__MEMBER_NO, t4.HUB_PARTY_BK__MEMBER_NO, t5.HUB_PARTY_BK__MEMBER_NO, t6.HUB_PARTY_BK__PART_ID, t7.HUB_PARTY_BK__MEMBER_ID, t8.HUB_PARTY_BK__MEMBER_NO, t9.HUB_PARTY_BK__MEMBER_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__CONTRACT_ID, t3.HUB_POLICY_BK__PMASTERPOLICYNUMBER, t4.HUB_POLICY_BK__CONTRACT_ID, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__CONTRACT_ID, t7.HUB_POLICY_BK__CONTRACT_ID, t8.HUB_POLICY_BK__CONTRACT_ID, t9.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t7.HUB_PRODUCT_BK__PRODUCT_CODE)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t0.HUB_RISK_OBJECT_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME, t2.HUB_RISK_OBJECT_BK__MEMBER_NO, t5.HUB_RISK_OBJECT_BK__MEMBER_NO)'},
    {'name': 'T0__HUB_PARTY_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME', 'expr': 't0.HUB_PARTY_BK__CONTRACT_ID_INSURED_FIRST_NAME_MIDDLE_NAME'},
    {'name': 'T0__HUB_PARTY_BK__CONTRACT_ID_NOMINEE_NOMINEE_NAME', 'expr': 't0.HUB_PARTY_BK__CONTRACT_ID_NOMINEE_NOMINEE_NAME'},
    {'name': 'T1__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't1.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T3__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't3.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T3__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't3.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T3__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't3.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T3__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't3.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T3__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't3.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T3__HUB_PRODUCT_BK__PLANID', 'expr': 't3.HUB_PRODUCT_BK__PLANID'},
    {'name': 'T3__HUB_PRODUCT_BK__SCHEMECODE', 'expr': 't3.HUB_PRODUCT_BK__SCHEMECODE'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_party_employment'
) }}
