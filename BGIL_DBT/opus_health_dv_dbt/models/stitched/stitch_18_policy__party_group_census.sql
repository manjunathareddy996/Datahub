/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Procedure: the 9-step REUSABLE RESHAPE PROCEDURE documented in the pilot
   stitch_01_policy__policy_header.sql (task 4.1). Applied here by task 6.1.

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk'); satellite: SAT_PARTY_GROUP_CENSUS
   target_sat        : sat_party_group_census  (header "SAT_PARTY_GROUP_CENSUS" ==
                       stage_18 "SAT_PARTY_GROUP_CENSUS_HASHDIFF" == filename tail).
   key_column per src: each source's HUB_POLICY_BK__* column (the HUB_POLICY-grain key).
     - 10 of 11 sources carry a HUB_POLICY_BK__* column -> used directly as key_column.
     - t10 (BJAZ_ECARD_MEMBR_DEL_DTLS): carries NO HUB_POLICY key; the central view joined it
       on HUB_PARTY_BK__EMP_CODE. DOCUMENTED GRAIN DEVIATION: key_column=HUB_PARTY_BK__EMP_CODE
       (its real join key). Kept as a source so the family-1 hub_keys exprs referencing
       t10.* (HUB_PARTY_BK, HUB_QUOTE_BK) resolve.
   PAYLOAD same-alias collisions (macro emits ONE col per alias per tgt):
     - employee_id: kept t8.co_empnumber; dropped-secondary t8.hat_empcode
   merge order       : R8 precedence (v2 > legacy > delta3) preserved as the central
                       view's documented COALESCE order, transcribed verbatim per attr.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_bgil_gmc_final_instl_data',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'doj',        'tgt': 'date_of_joining'},
            {'src': 'grade_code', 'tgt': 'designation_band'}
        ],
        'hub_key_columns': [
            {'src_expr': 'emp_code',  'tgt': 'HUB_PARTY_BK__EMP_CODE'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BGIL_GMC_FINAL_INSTL_DATA'
    },
    {
        'model': 'stg_card_dtls',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'date_of_joining', 'tgt': 'date_of_joining'},
            {'src': 'emp_no',          'tgt': 'employee_id'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'card_no',    'tgt': 'HUB_DOCUMENT_BK__CARD_NO'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_CARD_DTLS'
    },
    {
        'model': 'stg_generic_loader_log_table',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'empno', 'tgt': 'employee_id'}
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
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'emp_no', 'tgt': 'employee_id'}
        ],
        'hub_key_columns': [
            {'src_expr': 'member_no',   'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HAT_ID_MEM_DETLS'
    },
    {
        'model': 'stg_hc_part_extn',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'status', 'tgt': 'active_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'part_id',     'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_hm_coinsu_clm_dtls',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'emp_no', 'tgt': 'employee_id'}
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
        'model': 'stg_hm_gmc_ahc',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'emp_id', 'tgt': 'employee_id'}
        ],
        'hub_key_columns': [
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_GMC_AHC'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__POLICY',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'doj', 'tgt': 'date_of_joining'}
        ],
        'hub_key_columns': [
            {'src_expr': 'clid',            'tgt': 'HUB_CLAIM_BK__CLID'},
            {'src_expr': 'imd_code',        'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'bank_ac_no',      'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
            {'src_expr': 'utr_no',          'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__UTR_NO'},
            {'src_expr': 'location_code',   'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode',    'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc',      'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location',   'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'claim_no',        'tgt': 'HUB_LOSS_EVENT_BK__CLAIM_NO'},
            {'src_expr': 'hospital_id',     'tgt': 'HUB_PARTY_BK__HOSPITAL_ID'},
            {'src_expr': 'cheque_no',       'tgt': 'HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
            {'src_expr': 'policy',          'tgt': 'HUB_POLICY_BK__POLICY'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HCM_EXTRACT'
    },
    {
        'model': 'stg_hm_member_dtls',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'co_empnumber',      'tgt': 'employee_id'},
            {'src': 'employee_location', 'tgt': 'location_reference'},
            {'src': 'grade',             'tgt': 'designation_band'}
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
        'model': 'stg_remedinet_claim_details',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'employee_id', 'tgt': 'employee_id'}
        ],
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
        'model': 'stg_ecard_membr_del_dtls',
        'alias': 't10',
        'key_column': 'HUB_PARTY_BK__EMP_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'emp_neme', 'tgt': 'member_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'emp_code',  'tgt': 'HUB_PARTY_BK__EMP_CODE'},
            {'src_expr': 'quote_ref', 'tgt': 'HUB_QUOTE_BK__QUOTE_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ECARD_MEMBR_DEL_DTLS'
    }
] -%}

{%- set output_columns = [
    'designation_band',
    'date_of_joining',
    'employee_id',
    'member_name',
    'active_indicator',
    'location_reference'
] -%}

{#-- coalesce_rules: precedence order transcribed from the central view's final-SELECT
     payload COALESCEs. Single-alias rules emit a bare column reference (macro behaviour).
     Same-alias collision on employee_id (t8) represented once -- see header. --#}
{%- set coalesce_rules = {
    'designation_band':   ['t0', 't8'],
    'date_of_joining':    ['t0', 't1', 't7'],
    'employee_id':        ['t1', 't2', 't3', 't5', 't6', 't8', 't9'],
    'member_name':        ['t10'],
    'active_indicator':   ['t4'],
    'location_reference': ['t8']
} %}

{#-- hub_keys: transcribed VERBATIM from the central view's final SELECT.
     Family 1 = merged-spine BKs (coalesce over alias.tgt). Family 2 = auxiliary
     per-source BKs (single alias.tgt, name prefixed TN__). Order preserved. --#}
{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't9.HUB_AGREEMENT_BK__REMEDINET_PROVIDER_CODE'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t5.HUB_CLAIM_BK__CLAIM_ID, t7.HUB_CLAIM_BK__CLID, t9.HUB_CLAIM_BK__CLAIM_NO)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t1.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID, t7.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t8.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t1.HUB_DOCUMENT_BK__CARD_NO, t9.HUB_DOCUMENT_BK__OMNI_INWARD_NO)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t7.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO, t8.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 't7.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 't7.HUB_LOSS_EVENT_BK__CLAIM_NO'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__EMP_CODE, t3.HUB_PARTY_BK__MEMBER_NO, t4.HUB_PARTY_BK__PART_ID, t5.HUB_PARTY_BK__LDR_PID, t7.HUB_PARTY_BK__HOSPITAL_ID, t8.HUB_PARTY_BK__MEMBER_ID, t10.HUB_PARTY_BK__EMP_CODE)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 't7.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__POLICY_NO, t1.HUB_POLICY_BK__POLICY_REF, t2.HUB_POLICY_BK__PMASTERPOLICYNUMBER, t3.HUB_POLICY_BK__CONTRACT_ID, t4.HUB_POLICY_BK__CONTRACT_ID, t5.HUB_POLICY_BK__POLICY_REF, t6.HUB_POLICY_BK__POLICY_NO, t7.HUB_POLICY_BK__POLICY, t8.HUB_POLICY_BK__CONTRACT_ID, t9.HUB_POLICY_BK__POLICY_NO)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t5.HUB_PRODUCT_BK__PROD_CD, t8.HUB_PRODUCT_BK__PRODUCT_CODE)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 't10.HUB_QUOTE_BK__QUOTE_REF'},
    {'name': 'T2__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't2.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T2__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't2.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T2__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't2.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T2__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't2.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T2__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't2.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T2__HUB_PRODUCT_BK__PLANID', 'expr': 't2.HUB_PRODUCT_BK__PLANID'},
    {'name': 'T2__HUB_PRODUCT_BK__SCHEMECODE', 'expr': 't2.HUB_PRODUCT_BK__SCHEMECODE'},
    {'name': 'T7__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't7.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T7__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't7.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T7__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't7.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T7__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't7.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T7__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't7.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T9__HUB_PARTY_BK__PAYER_CODE', 'expr': 't9.HUB_PARTY_BK__PAYER_CODE'},
    {'name': 'T9__HUB_PARTY_BK__REMEDINET_PROVIDER_CODE', 'expr': 't9.HUB_PARTY_BK__REMEDINET_PROVIDER_CODE'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_party_group_census'
) }}
