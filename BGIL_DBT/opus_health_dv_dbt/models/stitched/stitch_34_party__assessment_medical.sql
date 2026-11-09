/* RESHAPED (Option C) from central view 34 into the partner thin form.
   Procedure: the pilot's 9-step REUSABLE RESHAPE PROCEDURE
   (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_PARTY  (unique_key='parent_bk')
   target_sat        : sat_assessment_medical
     Central view 34 feeds 3 satellites; this reshape carries ONLY the
     SAT_ASSESSMENT_MEDICAL payload (stage_34 SAT_ASSESSMENT_MEDICAL_HASHDIFF, 15 cols).
   key_column per src: each source's HUB_PARTY_BK__* column (HUB_PARTY grain).
     DOCUMENTED GRAIN DEVIATIONS (no HUB_PARTY key; key_column is the real join key):
     - t6 (BJAZ_HM_DOCTOR_ASSESS)       -> key_column=HUB_ASSESSMENT_BK__DOCASESS_ID
     - t7 (BJAZ_HM_DOCTOR_MULTI_ASSESS) -> key_column=HUB_ASSESSMENT_BK__DOCASESS_ID
     - t8 (BJAZ_HM_PCS_MULTI_ASSESS)    -> key_column=HUB_ASSESSMENT_BK__DOCASESS_ID
     - t9 (BJAZ_POLICY_SUMMARY)         -> key_column=HUB_POLICY_BK__CONTRACT_ID
   same-alias drops  : none.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_pp_mem_dtls',
        'alias': 't0',
        'key_column': 'HUB_PARTY_BK__ALLOTED_TO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'test_code', 'tgt': 'medical_test_type'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',       'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'alloted_to',        'tgt': 'HUB_PARTY_BK__ALLOTED_TO'},
            {'src_expr': 'contract_id',       'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'hi_control_number', 'tgt': 'HUB_PROPOSAL_BK__HI_CONTROL_NUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PP_MEM_DTLS'
    },
    {
        'model': 'stg_hcf_member_dtls',
        'alias': 't1',
        'key_column': 'HUB_PARTY_BK__MEMBER_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'med_report_received', 'tgt': 'medical_report_received_indicator'},
            {'src': 'reports_normal',      'tgt': 'abnormality_indicator'},
            {'src': 'med_exam_flag',       'tgt': 'medical_examination_conducted_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',   'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no',    'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id',  'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no',    'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_hg_pol_dtls',
        'alias': 't2',
        'key_column': 'HUB_PARTY_BK__PART_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'model': 'stg_hm_hcm_extract',
        'alias': 't3',
        'key_column': 'HUB_PARTY_BK__HOSPITAL_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'medical_mgt_date',    'tgt': 'medical_management_date'},
            {'src': 'assessment_exclause', 'tgt': 'recommended_exclusion'}
        ],
        'hub_key_columns': [
            {'src_expr': 'clid',          'tgt': 'HUB_CLAIM_BK__CLID'},
            {'src_expr': 'imd_code',      'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'bank_ac_no',    'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
            {'src_expr': 'utr_no',        'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__UTR_NO'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode',  'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc',    'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location','tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'claim_no',      'tgt': 'HUB_LOSS_EVENT_BK__CLAIM_NO'},
            {'src_expr': 'hospital_id',   'tgt': 'HUB_PARTY_BK__HOSPITAL_ID'},
            {'src_expr': 'cheque_no',     'tgt': 'HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
            {'src_expr': 'policy',        'tgt': 'HUB_POLICY_BK__POLICY'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HCM_EXTRACT'
    },
    {
        'model': 'stg_hm_hospital_master_extn',
        'alias': 't4',
        'key_column': 'HUB_PARTY_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'hosid',                'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'distribution_partner', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER'},
            {'src_expr': 'hosid',                'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSPITAL_MASTER_EXTN'
    },
    {
        'model': 'stg_hm_inward_dtls',
        'alias': 't5',
        'key_column': 'HUB_PARTY_BK__COURIER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'claim_id',       'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'inward_id',      'tgt': 'HUB_DOCUMENT_BK__INWARD_ID'},
            {'src_expr': 'location_code',  'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode',   'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc',     'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location','tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location',  'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'claim_id',       'tgt': 'HUB_LOSS_EVENT_BK__CLAIM_ID'},
            {'src_expr': 'courier_id',     'tgt': 'HUB_PARTY_BK__COURIER_ID'},
            {'src_expr': 'policy_ref',     'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_INWARD_DTLS'
    },
    {
        'model': 'stg_hm_doctor_assess',
        'alias': 't6',
        'key_column': 'HUB_ASSESSMENT_BK__DOCASESS_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'medical_mgmt_date', 'tgt': 'medical_management_date'},
            {'src': 'medical_mgmt_type', 'tgt': 'medical_management_type'},
            {'src': 'diagnosis_id',      'tgt': 'diagnosis_code'},
            {'src': 'diagnosis_detail',  'tgt': 'diagnosis_description'},
            {'src': 'package_flag',      'tgt': 'package_applicable_indicator'},
            {'src': 'icd_id',            'tgt': 'icd_code'},
            {'src': 'hlth_tips',         'tgt': 'health_advice_text'},
            {'src': 'pcs_yn',            'tgt': 'pcs_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'docasess_id', 'tgt': 'HUB_ASSESSMENT_BK__DOCASESS_ID'},
            {'src_expr': 'claim_id',    'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_DOCTOR_ASSESS'
    },
    {
        'model': 'stg_hm_doctor_multi_assess',
        'alias': 't7',
        'key_column': 'HUB_ASSESSMENT_BK__DOCASESS_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'medical_mgmt_date', 'tgt': 'medical_management_date'},
            {'src': 'medical_mgmt_type', 'tgt': 'medical_management_type'},
            {'src': 'hlth_tips',         'tgt': 'health_advice_text'},
            {'src': 'package_flag',      'tgt': 'package_procedure_indicator'},
            {'src': 'pcs_yn',            'tgt': 'procedure_applicable_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'docasess_id',   'tgt': 'HUB_ASSESSMENT_BK__DOCASESS_ID'},
            {'src_expr': 'claim_id',      'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'cover_section', 'tgt': 'HUB_COVERAGE_BK__COVER_SECTION'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_DOCTOR_MULTI_ASSESS'
    },
    {
        'model': 'stg_hm_pcs_multi_assess',
        'alias': 't8',
        'key_column': 'HUB_ASSESSMENT_BK__DOCASESS_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'medical_mgmt_date', 'tgt': 'medical_management_date'},
            {'src': 'medical_mgmt_type', 'tgt': 'medical_management_type'}
        ],
        'hub_key_columns': [
            {'src_expr': 'docasess_id', 'tgt': 'HUB_ASSESSMENT_BK__DOCASESS_ID'},
            {'src_expr': 'claim_id',    'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_PCS_MULTI_ASSESS'
    },
    {
        'model': 'stg_policy_summary',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
    }
] -%}

{%- set output_columns = [
    'medical_test_type',
    'medical_report_received_indicator',
    'abnormality_indicator',
    'medical_examination_conducted_indicator',
    'medical_management_date',
    'medical_management_type',
    'diagnosis_code',
    'diagnosis_description',
    'package_applicable_indicator',
    'icd_code',
    'health_advice_text',
    'pcs_indicator',
    'package_procedure_indicator',
    'procedure_applicable_indicator',
    'recommended_exclusion'
] -%}

{%- set coalesce_rules = {
    'medical_test_type':                       ['t0'],
    'medical_report_received_indicator':       ['t1'],
    'abnormality_indicator':                   ['t1'],
    'medical_examination_conducted_indicator': ['t1'],
    'medical_management_date':                 ['t6', 't7', 't3', 't8'],
    'medical_management_type':                 ['t6', 't7', 't8'],
    'diagnosis_code':                          ['t6'],
    'diagnosis_description':                   ['t6'],
    'package_applicable_indicator':            ['t6'],
    'icd_code':                                ['t6'],
    'health_advice_text':                      ['t6', 't7'],
    'pcs_indicator':                           ['t6'],
    'package_procedure_indicator':             ['t7'],
    'procedure_applicable_indicator':          ['t7'],
    'recommended_exclusion':                   ['t3']
} %}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't4.HUB_AGREEMENT_BK__HOSID'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__SCRUTINY_NO, t6.HUB_ASSESSMENT_BK__DOCASESS_ID, t7.HUB_ASSESSMENT_BK__DOCASESS_ID, t8.HUB_ASSESSMENT_BK__DOCASESS_ID)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t3.HUB_CLAIM_BK__CLID, t5.HUB_CLAIM_BK__CLAIM_ID, t6.HUB_CLAIM_BK__CLAIM_ID, t7.HUB_CLAIM_BK__CLAIM_ID, t8.HUB_CLAIM_BK__CLAIM_ID)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 'coalesce(t2.HUB_COVERAGE_BK__COVER_CODE, t7.HUB_COVERAGE_BK__COVER_SECTION)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t1.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t3.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t4.HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 't5.HUB_DOCUMENT_BK__INWARD_ID'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 't3.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 't3.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t3.HUB_LOSS_EVENT_BK__CLAIM_NO, t5.HUB_LOSS_EVENT_BK__CLAIM_ID)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__ALLOTED_TO, t1.HUB_PARTY_BK__MEMBER_NO, t2.HUB_PARTY_BK__PART_ID, t3.HUB_PARTY_BK__HOSPITAL_ID, t4.HUB_PARTY_BK__HOSID, t5.HUB_PARTY_BK__COURIER_ID)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 't3.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__CONTRACT_ID, t2.HUB_POLICY_BK__CONTRACT_ID, t3.HUB_POLICY_BK__POLICY, t5.HUB_POLICY_BK__POLICY_REF, t9.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t2.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t9.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t0.HUB_PROPOSAL_BK__HI_CONTROL_NUMBER, t2.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 't2.HUB_QUOTE_BK__QUOTE_REF_NO'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 't1.HUB_RISK_OBJECT_BK__MEMBER_NO'},
    {'name': 'T2__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't2.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T2__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't2.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T3__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't3.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T3__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't3.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T3__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't3.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T3__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't3.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T3__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't3.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T5__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't5.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T5__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't5.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T5__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't5.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T5__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't5.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T5__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't5.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T9__HUB_LOCATION_BK__ADDRESS_CITY_REGION', 'expr': 't9.HUB_LOCATION_BK__ADDRESS_CITY_REGION'},
    {'name': 'T9__HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE', 'expr': 't9.HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE'},
    {'name': 'T9__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't9.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T9__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't9.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T9__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't9.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T9__HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME', 'expr': 't9.HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME'},
    {'name': 'T9__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't9.HUB_PARTY_BK__PARTID_PART_ID'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_assessment_medical'
) }}
