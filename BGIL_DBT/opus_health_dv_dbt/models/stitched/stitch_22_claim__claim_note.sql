/* RESHAPED (Option C), ONE STITCH PER SATELLITE, from hcon4 central view 22.
   Batch task 7.1 -- applies the pilot procedure (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_CLAIM  (unique_key='parent_bk')
   target_sat        : sat_claim_note
   payload           : 2 output column(s), this satellite's stage hashdiff payload only.
   hub_keys          : the FULL final-SELECT hub-key set of the central view (12), verbatim,
                       so downstream hub/stage layers keep resolving every HUB_*_BK column.
   key_column rule   : each source's HUB_CLAIM_BK__* column (spine-hub grain key).
   GRAIN DEVIATIONS (source has no HUB_CLAIM key; real join key used, kept so hub_keys exprs resolve):
       t6 (stg_ctngy_covers_ext) key_column=HUB_POLICY_BK__CONTRACT_ID
       t7 (stg_ctngy_scheme_nr_parms) key_column=HUB_PRODUCT_BK__SCHEME_SCHEME_CODE
       t8 (stg_ctngy_scheme_plans) key_column=HUB_PARTY_BK__PARTNER_PARTNER_ID
       t9 (stg_hcs_plansi_mapp) key_column=HUB_PRODUCT_BK__PRODUCT_CODE
   SAME-ALIAS DROPS  : none.
   SOURCES OMITTED   : none.
   merge order       : R8 precedence (v2 > legacy > delta3) preserved from the central view COALESCE order.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hm_bill_detail',
        'alias': 't0',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'genral_remarks', 'tgt': 'note_text'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_BILL_DETAIL'
    },
    {
        'model': 'stg_hm_claim_tracker',
        'alias': 't1',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_CLAIM_TRACKER'
    },
    {
        'model': 'stg_hm_orphan_reg',
        'alias': 't2',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'orphan_close_remark', 'tgt': 'note_text'},
            {'src': 'orphan_follow_flag', 'tgt': 'follow_up_required_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode', 'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc', 'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'policy_number', 'tgt': 'HUB_POLICY_BK__POLICY_NUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_ORPHAN_REG'
    },
    {
        'model': 'stg_hm_query_remark',
        'alias': 't3',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'query_remark', 'tgt': 'note_text'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_QUERY_REMARK'
    },
    {
        'model': 'stg_remedinet_patient_details',
        'alias': 't4',
        'key_column': 'HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif('REMEDINET_REQ:' || nullif(trim(REQUESTID),''), 'REMEDINET_REQ:')", 'tgt': 'HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(ADDRESS1),''),'') || '|' || coalesce(nullif(trim(ADDRESS2),''),'') || '|' || coalesce(nullif(trim(ADDRESS3),''),'') || '|' || coalesce(nullif(trim(CITY),''),'') || '|' || coalesce(nullif(trim(STATE),''),'') || '|' || coalesce(nullif(trim(PIN_CODE),''),''), '|||||'))))", 'tgt': 'HUB_LOCATION_BK__ADDRESS1_ADDRESS2_ADDRESS3_CITY'},
            {'src_expr': "nullif('MEMBER:' || nullif(trim(MEMBER_NO),''), 'MEMBER:')", 'tgt': 'HUB_PARTY_BK__MEMBER_MEMBER_NO'},
            {'src_expr': "nullif('MEMBER:' || nullif(trim(MEMBER_NO),''), 'MEMBER:')", 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_REMEDINET_PATIENT_DETAILS'
    },
    {
        'model': 'stg_risk_trans_dtls',
        'alias': 't5',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(CONTRACT_ID),''),'') || '|' || coalesce(nullif(trim(CLAIM_ID),''),'') || '|' || coalesce(nullif(trim(RISK_ID),''),''), '||'))))", 'tgt': 'HUB_ASSESSMENT_BK__CONTRACT_ID_CLAIM_ID_RISK_ID'},
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_RISK_TRANS_DTLS'
    },
    {
        'model': 'stg_ctngy_covers_ext',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('SCHEME:' || nullif(trim(SCHEME_CODE),''), 'SCHEME:')", 'tgt': 'HUB_PRODUCT_BK__SCHEME_SCHEME_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_CTNGY_COVERS_EXT'
    },
    {
        'model': 'stg_ctngy_scheme_nr_parms',
        'alias': 't7',
        'key_column': 'HUB_PRODUCT_BK__SCHEME_SCHEME_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif('SCHEME:' || nullif(trim(SCHEME_CODE),''), 'SCHEME:')", 'tgt': 'HUB_PRODUCT_BK__SCHEME_SCHEME_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_CTNGY_SCHEME_NR_PARMS'
    },
    {
        'model': 'stg_ctngy_scheme_plans',
        'alias': 't8',
        'key_column': 'HUB_PARTY_BK__PARTNER_PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif('PARTNER:' || nullif(trim(PARTNER_ID),''), 'PARTNER:')", 'tgt': 'HUB_PARTY_BK__PARTNER_PARTNER_ID'},
            {'src_expr': "nullif('SCHEMEPLAN:' || nullif(trim(SCHEME_CODE),'') || '|' || nullif(trim(PLAN_ID),''), 'SCHEMEPLAN:|')", 'tgt': 'HUB_PRODUCT_BK__SCHEMEPLAN_SCHEME_CODE_PLAN_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_CTNGY_SCHEME_PLANS'
    },
    {
        'model': 'stg_hcs_plansi_mapp',
        'alias': 't9',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCS_PLANSI_MAPP'
    }
] -%}

{%- set output_columns = [
    'note_text',
    'follow_up_required_indicator'
] -%}

{%- set coalesce_rules = {
    'note_text': ['t0', 't2', 't3'],
    'follow_up_required_indicator': ['t2']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 't5.HUB_ASSESSMENT_BK__CONTRACT_ID_CLAIM_ID_RISK_ID'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t0.HUB_CLAIM_BK__CLAIM_ID, t1.HUB_CLAIM_BK__CLAIM_ID, t2.HUB_CLAIM_BK__CLAIM_ID, t3.HUB_CLAIM_BK__CLAIM_ID, t4.HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID, t5.HUB_CLAIM_BK__CLAIM_ID)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't4.HUB_LOCATION_BK__ADDRESS1_ADDRESS2_ADDRESS3_CITY'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t4.HUB_PARTY_BK__MEMBER_MEMBER_NO, t8.HUB_PARTY_BK__PARTNER_PARTNER_ID)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t2.HUB_POLICY_BK__POLICY_NUMBER, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t6.HUB_PRODUCT_BK__SCHEME_SCHEME_CODE, t7.HUB_PRODUCT_BK__SCHEME_SCHEME_CODE, t8.HUB_PRODUCT_BK__SCHEMEPLAN_SCHEME_CODE_PLAN_ID, t9.HUB_PRODUCT_BK__PRODUCT_CODE)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 't4.HUB_RISK_OBJECT_BK__MEMBER_MEMBER_NO'},
    {'name': 'T2__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't2.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T2__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't2.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T2__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't2.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T2__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't2.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T2__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't2.HUB_LOCATION_BK__RISK_LOCATION'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_claim_note'
) }}
