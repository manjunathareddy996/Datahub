/* RESHAPED (Option C) from central view 39 into the partner thin form.
   Procedure: the pilot's 9-step REUSABLE RESHAPE PROCEDURE
   (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_PARTY  (unique_key='parent_bk')
   target_sat        : sat_common_communication_preference
     Central view 39 feeds 6 satellites; this reshape carries ONLY the
     SAT_COMMON_COMMUNICATION_PREFERENCE payload (stage_39 hashdiff:
     PREFERRED_CHANNEL_CODE, carried by t1).
   key_column per src: each source's HUB_PARTY_BK__* column (HUB_PARTY grain).
     DOCUMENTED GRAIN DEVIATIONS (no HUB_PARTY key is the central-view join key;
     key_column is the real join key):
     - t6 (BJAZ_ENROLL_POL_DTLS)   -> key_column=HUB_POLICY_BK__POLICY_NO
     - t7 (BJAZ_GRP_HLT_DTLS)      -> key_column=HUB_PROPOSAL_BK__QUOTE_REF_NO
     - t8 (BJAZ_HM_PREAUTH_REQUEST)-> key_column=HUB_CLAIM_BK__CLAIM_ID
   same-alias drops  : none.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_ec_mem_dtls_extn',
        'alias': 't0',
        'key_column': 'HUB_PARTY_BK__MEMBER_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'model': 'stg_hat_pol_emp_map',
        'alias': 't1',
        'key_column': 'HUB_PARTY_BK__EMP_POLICY_NO_EMP_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'mail_indicator', 'tgt': 'preferred_channel_code'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('EMP:' || coalesce(nullif(trim(POLICY_NO),''),'') || '#' || coalesce(nullif(trim(EMP_CODE),''),''), 'EMP:#')", 'tgt': 'HUB_PARTY_BK__EMP_POLICY_NO_EMP_CODE'},
            {'src_expr': "nullif(trim(POLICY_NO),'')", 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HAT_POL_EMP_MAP'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't2',
        'key_column': 'HUB_PARTY_BK__HOSPITAL_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'alias': 't3',
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
        'model': 'stg_hm_policy_usermapping',
        'alias': 't4',
        'key_column': 'HUB_PARTY_BK__LOGINNAME',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'loginname',  'tgt': 'HUB_PARTY_BK__LOGINNAME'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_POLICY_USERMAPPING'
    },
    {
        'model': 'stg_ocp_interested_parties',
        'alias': 't5',
        'key_column': 'HUB_PARTY_BK__PARTNER_PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif('ADDRID:' || nullif(trim(MAILING_ADDRESS_ID),''), 'ADDRID:')", 'tgt': 'HUB_LOCATION_BK__ADDRID_MAILING_ADDRESS_ID'},
            {'src_expr': "nullif('PARTNER:' || nullif(trim(PARTNER_ID),''), 'PARTNER:')", 'tgt': 'HUB_PARTY_BK__PARTNER_PARTNER_ID'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_OCP_INTERESTED_PARTIES'
    },
    {
        'model': 'stg_enroll_pol_dtls',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(trim( coalesce(ADDRESS_LINE1,'') || '|' || coalesce(CORP_CITY,'') || '|' || coalesce(CORP_PIN,'') ), '||'))))", 'tgt': 'HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN'},
            {'src_expr': "md5(normalise(upper(nullif(trim( coalesce(PH_ADDRESS,'') ), ''))))", 'tgt': 'HUB_LOCATION_BK__PH_ADDRESS'},
            {'src_expr': "md5(normalise(upper(nullif(trim( coalesce(PP_ADDRESS,'') ), ''))))", 'tgt': 'HUB_LOCATION_BK__PP_ADDRESS'},
            {'src_expr': "nullif('EMP:' || nullif(trim(RM_CODE),''), 'EMP:')", 'tgt': 'HUB_PARTY_BK__EMP_RM_CODE'},
            {'src_expr': "nullif(trim(CORPORATE_ID),'')", 'tgt': 'HUB_PARTY_BK__CORPORATE_ID'},
            {'src_expr': "nullif(trim(IMD_CODE),'')", 'tgt': 'HUB_PARTY_BK__IMD_CODE'},
            {'src_expr': "nullif(trim(PH_ID),'')", 'tgt': 'HUB_PARTY_BK__PH_ID'},
            {'src_expr': "nullif(trim(PP_ID),'')", 'tgt': 'HUB_PARTY_BK__PP_ID'},
            {'src_expr': "nullif(trim(SUBIMD_CODE),'')", 'tgt': 'HUB_PARTY_BK__SUBIMD_CODE'},
            {'src_expr': "nullif(trim(POLICY_NO),'')", 'tgt': 'HUB_POLICY_BK__POLICY_NO'},
            {'src_expr': "nullif(trim(SCRUTINY_NO),'')", 'tgt': 'HUB_PROPOSAL_BK__SCRUTINY_NO'},
            {'src_expr': "nullif(trim(QUOTATION_NO),'')", 'tgt': 'HUB_QUOTE_BK__QUOTATION_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_ENROLL_POL_DTLS'
    },
    {
        'model': 'stg_grp_hlt_dtls',
        'alias': 't7',
        'key_column': 'HUB_PROPOSAL_BK__QUOTE_REF_NO',
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
    },
    {
        'model': 'stg_hm_preauth_request',
        'alias': 't8',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': "nullif('FIR:' || nullif(trim(FIR_NO),''), 'FIR:')", 'tgt': 'HUB_DOCUMENT_BK__FIR_FIR_NO'},
            {'src_expr': "nullif('OMNI_INWARD:' || nullif(trim(OMNI_INWARD_NO),''), 'OMNI_INWARD:')", 'tgt': 'HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO'},
            {'src_expr': "nullif('HEALTHCARD:' || nullif(trim(INSURED_CARD_NO),''), 'HEALTHCARD:')", 'tgt': 'HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO'},
            {'src_expr': "nullif('HEALTHCARD:' || nullif(trim(PATIENT_ID_CARD),''), 'HEALTHCARD:')", 'tgt': 'HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD'},
            {'src_expr': "nullif('HOSPID:' || nullif(trim(HOS_ID),''), 'HOSPID:')", 'tgt': 'HUB_PARTY_BK__HOSPID_HOS_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_PREAUTH_REQUEST'
    }
] -%}

{%- set output_columns = [
    'preferred_channel_code'
] -%}

{%- set coalesce_rules = {
    'preferred_channel_code': ['t1']
} %}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't3.HUB_AGREEMENT_BK__HOSID'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 't7.HUB_ASSESSMENT_BK__SCRUTINY_NO'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t2.HUB_CLAIM_BK__CLID, t8.HUB_CLAIM_BK__CLAIM_ID)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t3.HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 't0.HUB_DOCUMENT_BK__MEDICAL_REPORT'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 't2.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 't2.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't5.HUB_LOCATION_BK__ADDRID_MAILING_ADDRESS_ID'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 't2.HUB_LOSS_EVENT_BK__CLAIM_NO'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__MEMBER_NO, t1.HUB_PARTY_BK__EMP_POLICY_NO_EMP_CODE, t2.HUB_PARTY_BK__HOSPITAL_ID, t3.HUB_PARTY_BK__HOSID, t4.HUB_PARTY_BK__LOGINNAME, t5.HUB_PARTY_BK__PARTNER_PARTNER_ID)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 't2.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__POLICY_NO, t2.HUB_POLICY_BK__POLICY, t4.HUB_POLICY_BK__POLICY_REF, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 't7.HUB_PRODUCT_BK__PRODUCT'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t6.HUB_PROPOSAL_BK__SCRUTINY_NO, t7.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t6.HUB_QUOTE_BK__QUOTATION_NO, t7.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 't0.HUB_RISK_OBJECT_BK__MEMBER_NO'},
    {'name': 'T2__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't2.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T2__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't2.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T2__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't2.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T2__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't2.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T2__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't2.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T6__HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN', 'expr': 't6.HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN'},
    {'name': 'T6__HUB_LOCATION_BK__PH_ADDRESS', 'expr': 't6.HUB_LOCATION_BK__PH_ADDRESS'},
    {'name': 'T6__HUB_LOCATION_BK__PP_ADDRESS', 'expr': 't6.HUB_LOCATION_BK__PP_ADDRESS'},
    {'name': 'T6__HUB_PARTY_BK__EMP_RM_CODE', 'expr': 't6.HUB_PARTY_BK__EMP_RM_CODE'},
    {'name': 'T6__HUB_PARTY_BK__CORPORATE_ID', 'expr': 't6.HUB_PARTY_BK__CORPORATE_ID'},
    {'name': 'T6__HUB_PARTY_BK__IMD_CODE', 'expr': 't6.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T6__HUB_PARTY_BK__PH_ID', 'expr': 't6.HUB_PARTY_BK__PH_ID'},
    {'name': 'T6__HUB_PARTY_BK__PP_ID', 'expr': 't6.HUB_PARTY_BK__PP_ID'},
    {'name': 'T6__HUB_PARTY_BK__SUBIMD_CODE', 'expr': 't6.HUB_PARTY_BK__SUBIMD_CODE'},
    {'name': 'T7__HUB_ORG_UNIT_BK__BRANCH', 'expr': 't7.HUB_ORG_UNIT_BK__BRANCH'},
    {'name': 'T7__HUB_ORG_UNIT_BK__DEPARTMENT', 'expr': 't7.HUB_ORG_UNIT_BK__DEPARTMENT'},
    {'name': 'T7__HUB_POLICY_BK__POLICY_NO', 'expr': 't7.HUB_POLICY_BK__POLICY_NO'},
    {'name': 'T7__HUB_POLICY_BK__PREV_POL_REF', 'expr': 't7.HUB_POLICY_BK__PREV_POL_REF'},
    {'name': 'T7__HUB_POLICY_BK__REG_NO', 'expr': 't7.HUB_POLICY_BK__REG_NO'},
    {'name': 'T8__HUB_DOCUMENT_BK__FIR_FIR_NO', 'expr': 't8.HUB_DOCUMENT_BK__FIR_FIR_NO'},
    {'name': 'T8__HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO', 'expr': 't8.HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO'},
    {'name': 'T8__HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO', 'expr': 't8.HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO'},
    {'name': 'T8__HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD', 'expr': 't8.HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD'},
    {'name': 'T8__HUB_PARTY_BK__HOSPID_HOS_ID', 'expr': 't8.HUB_PARTY_BK__HOSPID_HOS_ID'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_common_communication_preference'
) }}
