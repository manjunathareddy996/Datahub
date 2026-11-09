/* RESHAPED (Option C) from hcon4 central view 40 into the partner thin form.
   Procedure: the reusable 8-step reshape established by the pilot (stitch_01). See
   stitch_01_policy__policy_header.sql for the full REUSABLE RESHAPE PROCEDURE.

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_common_lifecycle  (filename tail == first satellite the
                       central view feeds; stage_40 reads src.* and computes 4 hashdiffs,
                       so output_columns carries ALL family-3 payload attrs of the view).
   key_column per src: every source (t0..t9) carries a HUB_POLICY_BK__* column, used as
                       its key_column. NO grain deviation on view 40.
   same-alias payload collisions (macro emits ONE col per alias per tgt; the central view
   coalesced multiple raw cols from the SAME alias into one attr -- kept the FIRST in the
   central view's COALESCE order, dropped the rest as a recorded payload-precedence
   limitation of the macro form, NOT a hub-key issue):
     AMOUNT_APPLIED       : kept t3.additional_loading   (dropped t3.commercial_disc_amt, t3.other_discount, t3.special_disc, t3.special_discount, t3.uw_load_amt)
                            kept t1.additional_load_amt  (dropped t1.addon_cov_disc_amt, t1.cd_amt, t1.claim_free_renewal_disc_amt, t1.direct_cust_disc_amt, t1.disc_in_lieu_agency_comm_amt, t1.emp_disc_amt, t1.family_disc_amt, t1.good_health_disc_amt, t1.loading_amt, t1.long_term_policy_disc_amt, t1.online_disc_amt, t1.sp_disc_amt, t1.uw_loading_amt, t1.voluntary_deduct_amt)
                            kept t2.claim_discount       (dropped t2.claim_loading, t2.cto_ceo_discount, t2.cto_ceo_loading)
                            kept t6.commercial_discount  (dropped t6.family_discount, t6.grid_load, t6.member_loading, t6.other_discount, t6.uw_loading_amt, t6.uw_load_amt)
                            kept t0.brc_cd_amt           (dropped t0.brc_load_amt, t0.brj_cd_amt, t0.brj_load_amt, t0.fab_cd_amt, t0.fab_load_amt, t0.fac_cd_amt, t0.fac_load_amt)
                            kept t7.add_disc_amt         (dropped t7.add_load_amt, t7.adj_add_load_amt, t7.adj_cm_disc_amt, t7.adj_uw_load_amt, t7.commercial_disc_amt, t7.endorse_terr_surcharge, t7.lterm_disc_amt, t7.mpmp_disc_amt, t7.renewal_disc_amt, t7.service_charge_amt, t7.special_disc_amt, t7.terr_surcharge, t7.uw_load_amt)
                            kept t8.special_disc         (dropped t8.terr_surcharge)
                            kept t9.ci_load              (dropped t9.comm_disc, t9.uw_load)
     BTP_SCOPE_TAX_CODE   : t7.btp_tax_code, t8.btp_tax_code (distinct aliases, no drop)
     CGST_AMOUNT          : t7.cgst_amt, t8.cgst_amt
     GSTIN_OF_DISTRIBUTION_PARTNER : t7.partner_gstn, t8.partner_gstn
     IGST_AMOUNT          : t7.igst_amt, t8.igst_amt
     ITEM_APPLIED_INDICATOR: kept t3.cm_disc_flag        (dropped t3.uw_load_flag)
                             kept t0.brc_cd_yn           (dropped t0.brc_load_yn, t0.brj_cd_yn, t0.brj_load_yn, t0.fab_cd_yn, t0.fab_load_yn, t0.fac_cd_yn, t0.fac_load_yn)
                             kept t7.cm_disc_flag        (dropped t7.uw_load_flag)
     JUSTIFICATION        : kept t3.reason_for_discount  (dropped t3.reason_for_loading)
                            kept t7.add_disc_reason      (dropped t7.add_load_reason)
     PERCENTAGE_APPLIED   : kept t3.commercial_disc_rate (dropped t3.uw_load_rate)
                            kept t1.additional_load_rate (dropped t1.addon_cov_disc_rate, t1.cd_rate, t1.claim_free_renewal_disc_rate, t1.direct_cust_disc_rate, t1.disc_in_lieu_agency_comm_rate, t1.emp_disc_rate, t1.family_disc_rate, t1.good_health_disc_rate, t1.loading_rate, t1.long_term_policy_disc, t1.online_disc_rate, t1.sp_disc_rate, t1.uw_loading_rate, t1.voluntary_deduct_rate)
                            kept t6.commercial_discount_per (dropped t6.grid_load_rate, t6.uw_loading_per, t6.uw_load_rate)
                            kept t0.brc_cd_per           (dropped t0.brc_load_per, t0.brj_cd_per, t0.brj_load_per, t0.fab_cd_per, t0.fab_load_per, t0.fac_cd_per, t0.fac_load_per)
                            kept t7.add_disc_rate        (dropped t7.add_load_rate, t7.commercial_disc_rate, t7.lterm_disc_rate, t7.mpmp_disc_rate, t7.renewal_disc_rate, t7.service_charge_rate, t7.special_disc_rate, t7.uw_load_rate)
     SGST_AMOUNT          : t7.sgst_amt, t8.sgst_amt
     STAMP_DUTY_AMOUNT    : t7.stamp_duty_amt, t8.stamp_duty
     TP_SCOPE_TAX_CODE    : t7.tp_tax_code, t8.tp_tax_code
     TAX_AMOUNT           : kept t3.service_tax          (dropped t3.s_tax)
                            kept t5.educess_amt          (dropped t5.kkcess_amt, t5.sbcess_amt, t5.sertax_amt)
                            kept t0.edu_cess             (dropped t0.ser_tax)
                            kept t7.adj_cess1_amt        (dropped t7.adj_cess2_amt, t7.adj_cess3_amt, t7.adj_cgst_amt, t7.adj_edu_cess_tax, t7.adj_igst_amt, t7.adj_kkc_amt, t7.adj_ncc_amt, t7.adj_sgst_amt, t7.adj_st_exp_amt, t7.adj_swb_amt, t7.adj_utgst_amt, t7.btp_adj_cgst_amt, t7.btp_adj_igst_amt, t7.btp_adj_sgst_amt, t7.btp_adj_utgst_amt, t7.btp_cgst_amt, t7.btp_igst_amt, t7.btp_sgst_amt, t7.btp_utgst_amt, t7.cess1_amt, t7.cess2_amt, t7.cess3_amt, t7.edu_cess_tax, t7.kkc_amt, t7.ncc_amt, t7.service_tax_amt, t7.st_exp_amt, t7.swb_amt, t7.tp_adj_cgst_amt, t7.tp_adj_igst_amt, t7.tp_adj_sgst_amt, t7.tp_adj_utgst_amt, t7.tp_cgst_amt, t7.tp_igst_amt, t7.tp_sgst_amt, t7.tp_utgst_amt)
                            kept t8.btp_adj_cgst_amt     (dropped t8.btp_adj_igst_amt, t8.btp_adj_sgst_amt, t8.btp_adj_utgst_amt, t8.btp_cgst_amt, t8.btp_igst_amt, t8.btp_sgst_amt, t8.btp_utgst_amt, t8.jk_surchg_educess_amt, t8.kkc_cess_amt, t8.ncc_cess_amt, t8.service_tax, t8.swb_cess_amt, t8.tp_adj_cgst_amt, t8.tp_adj_igst_amt, t8.tp_adj_sgst_amt, t8.tp_adj_utgst_amt, t8.tp_cgst_amt, t8.tp_igst_amt, t8.tp_sgst_amt, t8.tp_utgst_amt)
                            kept t4.pservicetax (single)
     UTGST_AMOUNT         : t7.utgst_amt, t8.utgst_amt
   merge order : R8 precedence transcribed verbatim per attr (v2 > legacy > delta3).
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_ba_ccp_sub_mater_dtls',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'brc_cd_amt',           'tgt': 'amount_applied'},
            {'src': 'brc_cd_yn',            'tgt': 'item_applied_indicator'},
            {'src': 'brc_cd_per',           'tgt': 'percentage_applied'},
            {'src': 'ccp_80d_premium',      'tgt': 'section_80d_eligible_premium'},
            {'src': 'ccp_80d_endt_premium', 'tgt': 'section_80d_eligible_premium_on_endorsement'},
            {'src': 'edu_cess',             'tgt': 'tax_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('LOANACC:' || nullif(trim(LOAN_ACC_NUMBER),''), 'LOANACC:')", 'tgt': 'HUB_RISK_OBJECT_BK__LOANACC_LOAN_ACC_NUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BA_CCP_SUB_MATER_DTLS'
    },
    {
        'model': 'stg_hcp_dt_premium',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'additional_load_amt',  'tgt': 'amount_applied'},
            {'src': 'additional_load_rate', 'tgt': 'percentage_applied'}
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
        'model': 'stg_hcp_pol_mst',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claim_discount', 'tgt': 'amount_applied'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'child_loc_code', 'tgt': 'HUB_LOCATION_BK__CHILD_LOC_CODE'},
            {'src_expr': 'user_id',        'tgt': 'HUB_PARTY_BK__USER_ID'},
            {'src_expr': 'contract_id',    'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_POL_MST'
    },
    {
        'model': 'stg_enroll_scr_dtls',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'additional_loading',    'tgt': 'amount_applied'},
            {'src': 'edu_cess_tax',          'tgt': 'cess_amount'},
            {'src': 'cm_disc_flag',          'tgt': 'item_applied_indicator'},
            {'src': 'reason_for_discount',   'tgt': 'justification'},
            {'src': 'commercial_disc_rate',  'tgt': 'percentage_applied'},
            {'src': 'service_tax',           'tgt': 'tax_amount'}
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
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pservicetax', 'tgt': 'tax_amount'}
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
        'model': 'stg_grp_hlt_maternity_dtls',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'educess_amt', 'tgt': 'tax_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': 'reg_no',       'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product',      'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_MATERNITY_DTLS'
    },
    {
        'model': 'stg_health_webservice_info',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'commercial_discount',     'tgt': 'amount_applied'},
            {'src': 'commercial_discount_per', 'tgt': 'percentage_applied'}
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
        'model': 'stg_policy_bases_extn',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'add_disc_amt',               'tgt': 'amount_applied'},
            {'src': 'btp_tax_code',               'tgt': 'btp_scope_tax_code'},
            {'src': 'cgst_amt',                   'tgt': 'cgst_amount'},
            {'src': 'partner_gstn',               'tgt': 'gstin_of_distribution_partner'},
            {'src': 'igst_amt',                   'tgt': 'igst_amount'},
            {'src': 'cm_disc_flag',               'tgt': 'item_applied_indicator'},
            {'src': 'add_disc_reason',            'tgt': 'justification'},
            {'src': 'add_disc_rate',              'tgt': 'percentage_applied'},
            {'src': 'sgst_amt',                   'tgt': 'sgst_amount'},
            {'src': 'stamp_duty_amt',             'tgt': 'stamp_duty_amount'},
            {'src': 'stamp_duty_chargable_yn',    'tgt': 'stamp_duty_chargeable_indicator'},
            {'src': 'tp_tax_code',                'tgt': 'tp_scope_tax_code'},
            {'src': 'adj_cess1_amt',              'tgt': 'tax_amount'},
            {'src': 'tax_code',                   'tgt': 'tax_code'},
            {'src': 'st_exp_rate',                'tgt': 'tax_rate'},
            {'src': 'tax_type1',                  'tgt': 'tax_type_1_code'},
            {'src': 'tax_type2',                  'tgt': 'tax_type_2_code'},
            {'src': 'utgst_amt',                  'tgt': 'utgst_amount'}
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
            {'src': 'special_disc',      'tgt': 'amount_applied'},
            {'src': 'btp_tax_code',      'tgt': 'btp_scope_tax_code'},
            {'src': 'cgst_amt',          'tgt': 'cgst_amount'},
            {'src': 'partner_gstn',      'tgt': 'gstin_of_distribution_partner'},
            {'src': 'igst_amt',          'tgt': 'igst_amount'},
            {'src': 'sgst_amt',          'tgt': 'sgst_amount'},
            {'src': 'stamp_duty',        'tgt': 'stamp_duty_amount'},
            {'src': 'event_date',        'tgt': 'status_date'},
            {'src': 'tp_tax_code',       'tgt': 'tp_scope_tax_code'},
            {'src': 'btp_adj_cgst_amt',  'tgt': 'tax_amount'},
            {'src': 'utgst_amt',         'tgt': 'utgst_amount'}
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
        'model': 'stg_starpkg_pol_dtls',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'ci_load', 'tgt': 'amount_applied'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('TXN:' || nullif(trim(TRANSACTION_ID),''), 'TXN:')", 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(PROD_CODE),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT_PROD_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_STARPKG_POL_DTLS'
    }
] -%}

{%- set output_columns = [
    'amount_applied',
    'btp_scope_tax_code',
    'cgst_amount',
    'cess_amount',
    'gstin_of_distribution_partner',
    'igst_amount',
    'item_applied_indicator',
    'justification',
    'percentage_applied',
    'sgst_amount',
    'section_80d_eligible_premium',
    'section_80d_eligible_premium_on_endorsement',
    'stamp_duty_amount',
    'stamp_duty_chargeable_indicator',
    'status_date',
    'tp_scope_tax_code',
    'tax_amount',
    'tax_code',
    'tax_rate',
    'tax_type_1_code',
    'tax_type_2_code',
    'utgst_amount'
] -%}

{%- set coalesce_rules = {
    'amount_applied': ['t3', 't1', 't2', 't6', 't0', 't7', 't8', 't9'],
    'btp_scope_tax_code': ['t7', 't8'],
    'cgst_amount': ['t7', 't8'],
    'cess_amount': ['t3'],
    'gstin_of_distribution_partner': ['t7', 't8'],
    'igst_amount': ['t7', 't8'],
    'item_applied_indicator': ['t3', 't0', 't7'],
    'justification': ['t3', 't7'],
    'percentage_applied': ['t3', 't1', 't6', 't0', 't7'],
    'sgst_amount': ['t7', 't8'],
    'section_80d_eligible_premium': ['t0'],
    'section_80d_eligible_premium_on_endorsement': ['t0'],
    'stamp_duty_amount': ['t7', 't8'],
    'stamp_duty_chargeable_indicator': ['t7'],
    'status_date': ['t8'],
    'tp_scope_tax_code': ['t7', 't8'],
    'tax_amount': ['t3', 't4', 't5', 't0', 't7', 't8'],
    'tax_code': ['t7'],
    'tax_rate': ['t7'],
    'tax_type_1_code': ['t7'],
    'tax_type_2_code': ['t7'],
    'utgst_amount': ['t7', 't8']
} %}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't6.HUB_AGREEMENT_BK__DEAL_ID'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t3.HUB_ASSESSMENT_BK__SCRUTINY_NO, t6.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 't1.HUB_COVERAGE_BK__HCP_SEQNO'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t2.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID, t6.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 't6.HUB_FINANCIAL_ACCOUNT_BK__LOAN_ACCNO'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t6.HUB_FINANCIAL_TRANSACTION_BK__PTRANSACTION_ID, t7.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID, t9.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't2.HUB_LOCATION_BK__CHILD_LOC_CODE'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 't7.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t1.HUB_PARTY_BK__USER_ID, t2.HUB_PARTY_BK__USER_ID)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__CONTRACT_ID, t2.HUB_POLICY_BK__CONTRACT_ID, t3.HUB_POLICY_BK__CONTRACT_ID, t4.HUB_POLICY_BK__PMASTERPOLICYNUMBER, t5.HUB_POLICY_BK__REG_NO, t6.HUB_POLICY_BK__POLICY_REF, t7.HUB_POLICY_BK__CONTRACT_ID, t8.HUB_POLICY_BK__CONTRACT_ID, t9.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t1.HUB_PRODUCT_BK__PRODUCT_CODE, t5.HUB_PRODUCT_BK__PRODUCT, t6.HUB_PRODUCT_BK__PRODUCT_CODE, t7.HUB_PRODUCT_BK__PRODUCT_PRODUCT_4DIGIT_CODE, t8.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t9.HUB_PRODUCT_BK__PRODUCT_PROD_CODE)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t3.HUB_QUOTE_BK__QUOTATION_NO, t5.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 't0.HUB_RISK_OBJECT_BK__LOANACC_LOAN_ACC_NUMBER'},
    {'name': 'T4__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't4.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T4__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't4.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T4__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't4.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T4__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't4.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T4__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't4.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T4__HUB_PRODUCT_BK__PLANID', 'expr': 't4.HUB_PRODUCT_BK__PLANID'},
    {'name': 'T4__HUB_PRODUCT_BK__SCHEMECODE', 'expr': 't4.HUB_PRODUCT_BK__SCHEMECODE'},
    {'name': 'T6__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't6.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T6__HUB_ORG_UNIT_BK__DEPT_CODE', 'expr': 't6.HUB_ORG_UNIT_BK__DEPT_CODE'},
    {'name': 'T7__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't7.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T7__HUB_LOCATION_BK__PREV_INSURER_ADD', 'expr': 't7.HUB_LOCATION_BK__PREV_INSURER_ADD'},
    {'name': 'T8__HUB_LOCATION_BK__ADDRESS_CITY_REGION', 'expr': 't8.HUB_LOCATION_BK__ADDRESS_CITY_REGION'},
    {'name': 'T8__HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE', 'expr': 't8.HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE'},
    {'name': 'T8__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't8.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T8__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't8.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T8__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't8.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T8__HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME', 'expr': 't8.HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME'},
    {'name': 'T8__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't8.HUB_PARTY_BK__PARTID_PART_ID'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_common_lifecycle'
) }}
