/* RESHAPED (Option C) from central view 37 into the partner thin form.
   Procedure: the pilot's 9-step REUSABLE RESHAPE PROCEDURE
   (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_common_admin_geography
     Central view 37 feeds 6 satellites; this reshape carries ONLY the
     SAT_COMMON_ADMIN_GEOGRAPHY payload (stage_37 SAT_COMMON_ADMIN_GEOGRAPHY_HASHDIFF:
     CITY_CLASS_CODE, UNION_TERRITORY_INDICATOR).
   key_column per src: each source's HUB_POLICY_BK__* column (HUB_POLICY grain).
     DOCUMENTED GRAIN DEVIATIONS (no HUB_POLICY key; key_column is the real join key):
     - t7 (BJAZ_BRANCH_MASTER)           -> key_column=HUB_ORG_UNIT_BK__BRANCH_CODE
     - t8 (BJAZ_HM_HOSPITAL_MASTER_EXTN) -> key_column=HUB_AGREEMENT_BK__HOSID
     - t9 (BJAZ_INTERMEDIARY)            -> key_column=HUB_PARTY_BK__INTERMEDIARY_ID
   same-alias drops  : none.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hm_member_dtls',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'model': 'stg_pmjay_prmbook_dtls',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_PMJAY_PRMBOOK_DTLS'
    },
    {
        'model': 'stg_policy_bases_extn',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'alias': 't3',
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
    },
    {
        'model': 'stg_remedinet_claim_details',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'remedinet_provider_code', 'tgt': 'HUB_AGREEMENT_BK__REMEDINET_PROVIDER_CODE'},
            {'src_expr': 'claim_no',                'tgt': 'HUB_CLAIM_BK__CLAIM_NO'},
            {'src_expr': 'omni_inward_no',          'tgt': 'HUB_DOCUMENT_BK__OMNI_INWARD_NO'},
            {'src_expr': 'payer_code',              'tgt': 'HUB_PARTY_BK__PAYER_CODE'},
            {'src_expr': 'remedinet_provider_code', 'tgt': 'HUB_PARTY_BK__REMEDINET_PROVIDER_CODE'},
            {'src_expr': 'policy_no',               'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_REMEDINET_CLAIM_DETAILS'
    },
    {
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'bjaz_claim_id',      'tgt': 'HUB_CLAIM_BK__BJAZ_CLAIM_ID'},
            {'src_expr': 'partner_id',         'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'tpa_trans_key',      'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY'},
            {'src_expr': 'tpa_claim_no',       'tgt': 'HUB_LOSS_EVENT_BK__TPA_CLAIM_NO'},
            {'src_expr': 'controlling_office', 'tgt': 'HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
            {'src_expr': 'operating_office',   'tgt': 'HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
            {'src_expr': 'customer_id',        'tgt': 'HUB_PARTY_BK__CUSTOMER_ID'},
            {'src_expr': 'hospital_code',      'tgt': 'HUB_PARTY_BK__HOSPITAL_CODE'},
            {'src_expr': 'cheque_no',          'tgt': 'HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
            {'src_expr': 'policy_no',          'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_TPA_CLAIM_DETAILS_WS'
    },
    {
        'model': 'stg_versions_extn',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_VERSIONS_EXTN'
    },
    {
        'model': 'stg_branch_master',
        'alias': 't7',
        'key_column': 'HUB_ORG_UNIT_BK__BRANCH_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'ut_flag', 'tgt': 'union_territory_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(trim( coalesce(ADD_LINE1,'') || '|' || coalesce(ADD_LINE2,'') || '|' || coalesce(ADD_LINE3,'') || '|' || coalesce(ADD_LINE4,'') || '|' || coalesce(CITY,'') || '|' || coalesce(STATE,'') || '|' || coalesce(STATE_CODE,'') || '|' || coalesce(PINCODE,'') ), '|||||||'))))", 'tgt': 'HUB_LOCATION_BK__ADD_LINE1_ADD_LINE2_ADD_LINE3_ADD_LINE4'},
            {'src_expr': "nullif(trim(BRANCH_CODE),'')", 'tgt': 'HUB_ORG_UNIT_BK__BRANCH_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_BRANCH_MASTER'
    },
    {
        'model': 'stg_hm_hospital_master_extn',
        'alias': 't8',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'city_class', 'tgt': 'city_class_code'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid',                'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'distribution_partner', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER'},
            {'src_expr': 'hosid',                'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSPITAL_MASTER_EXTN'
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
    'city_class_code',
    'union_territory_indicator'
] -%}

{%- set coalesce_rules = {
    'city_class_code':           ['t8'],
    'union_territory_indicator': ['t7']
} %}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 'coalesce(t4.HUB_AGREEMENT_BK__REMEDINET_PROVIDER_CODE, t8.HUB_AGREEMENT_BK__HOSID)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t4.HUB_CLAIM_BK__CLAIM_NO, t5.HUB_CLAIM_BK__BJAZ_CLAIM_ID)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t8.HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 't4.HUB_DOCUMENT_BK__OMNI_INWARD_NO'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 't0.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t2.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID, t5.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't7.HUB_LOCATION_BK__ADD_LINE1_ADD_LINE2_ADD_LINE3_ADD_LINE4'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 't5.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t2.HUB_ORG_UNIT_BK__DEPARTMENT_CODE, t7.HUB_ORG_UNIT_BK__BRANCH_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__MEMBER_ID, t8.HUB_PARTY_BK__HOSID, t9.HUB_PARTY_BK__INTERMEDIARY_ID)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 't5.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__POLICY_REF, t2.HUB_POLICY_BK__CONTRACT_ID, t3.HUB_POLICY_BK__CONTRACT_ID, t4.HUB_POLICY_BK__POLICY_NO, t5.HUB_POLICY_BK__POLICY_NO, t6.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PRODUCT_CODE, t2.HUB_PRODUCT_BK__PRODUCT_PRODUCT_4DIGIT_CODE, t3.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE)'},
    {'name': 'T2__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't2.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T2__HUB_LOCATION_BK__PREV_INSURER_ADD', 'expr': 't2.HUB_LOCATION_BK__PREV_INSURER_ADD'},
    {'name': 'T3__HUB_LOCATION_BK__ADDRESS_CITY_REGION', 'expr': 't3.HUB_LOCATION_BK__ADDRESS_CITY_REGION'},
    {'name': 'T3__HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE', 'expr': 't3.HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE'},
    {'name': 'T3__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't3.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T3__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't3.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T3__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't3.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T3__HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME', 'expr': 't3.HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME'},
    {'name': 'T3__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't3.HUB_PARTY_BK__PARTID_PART_ID'},
    {'name': 'T4__HUB_PARTY_BK__PAYER_CODE', 'expr': 't4.HUB_PARTY_BK__PAYER_CODE'},
    {'name': 'T4__HUB_PARTY_BK__REMEDINET_PROVIDER_CODE', 'expr': 't4.HUB_PARTY_BK__REMEDINET_PROVIDER_CODE'},
    {'name': 'T5__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't5.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T5__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't5.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T5__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't5.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T5__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't5.HUB_PARTY_BK__HOSPITAL_CODE'},
    {'name': 'T9__HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL', 'expr': 't9.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_CHANNEL'},
    {'name': 'T9__HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC', 'expr': 't9.HUB_DISTRIBUTION_CHANNEL_BK__NEW_BC'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_common_admin_geography'
) }}
