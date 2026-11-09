/* RESHAPED (Option C), ONE STITCH PER SATELLITE, from hcon4 central view 28.
   Batch task 7.1 -- applies the pilot procedure (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_coverage_member_benefit
   payload           : 8 output column(s), this satellite's stage hashdiff payload only.
   hub_keys          : the FULL final-SELECT hub-key set of the central view (17), verbatim,
                       so downstream hub/stage layers keep resolving every HUB_*_BK column.
   key_column rule   : each source's HUB_POLICY_BK__* column (spine-hub grain key).
   GRAIN DEVIATIONS (source has no HUB_POLICY key; real join key used, kept so hub_keys exprs resolve):
       t7 (stg_hcp_transcript_url) key_column=HUB_ASSESSMENT_BK__SCRUTINY_NO
       t8 (stg_hcs_plansi_mapp) key_column=HUB_PRODUCT_BK__PRODUCT_CODE
   SAME-ALIAS DROPS (macro emits one column per alias per attr; secondary raw col dropped):
       benefit_sum_insured: kept t0.mlac_accdt_hosp_expenses; dropped mlac_air_ambulance_cover, mlac_childrens_education, mlac_coma_due_to_accdt, mlac_death_advt_sports_benefit, mlac_emi_pc_sum_insured, mlac_fracture_care, mlac_loan_protector_cover, mlac_loi_disb_frm_accdt_si, mlac_ptd_advt_sports_benefit, mlac_road_ambulance_cover, mlac_travel_expenses_benefit, mlc_si_ppd, mlc_si_ptd, mlc_sum_insured_death
       benefit_sum_insured: kept t2.mlac_accdt_hosp_expenses; dropped mlac_child_edu_ben, mlac_disability_ben_cov, mlac_emi_sum_insured, mlac_f_a_p_cov_brug_rob_cont, mlac_f_a_p_cov_building, mlac_montly_emi_si, mlc_acc_prot_cov_si, mlc_ci_sum_insured
       benefit_sum_insured: kept t3.anciliary; dropped critical_illness, float_addon, hosp_cash, personal_acc
       benefit_sum_insured: kept t7.pa_cover; dropped pa_cover_dti, pa_cover_occ, pa_cover_ppd, pa_cover_ptd
       benefit_sum_insured: kept t8.air_ambulance_si; dropped donor_si, hosp_si, maternity_si, opd_si, phy_si, plan_si, recovery_theft_si
       cumulative_bonus_percentage: kept t0.mlc_death_cb_per; dropped mlc_ppd_cb_per, mlc_ptd_cb_per
       cumulative_bonus_amount: kept t0.mlc_death_cb_amount; dropped mlc_ppd_cb_amount, mlc_ptd_cb_amount
       benefit_limit: kept t0.mlac_hosp_cash_per_day; dropped mlac_loi_disb_frm_accdt_weekly
       benefit_name: kept t2.mlc_acc_prot_cov_plan; dropped mlc_ci_plan
   SOURCES OMITTED   : none.
   merge order       : R8 precedence (v2 > legacy > delta3) preserved from the central view COALESCE order.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_prod_8428_gpg_loader',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'mlac_accdt_hosp_expenses', 'tgt': 'benefit_sum_insured'},
            {'src': 'mlc_death_cb_per', 'tgt': 'cumulative_bonus_percentage'},
            {'src': 'mlc_death_cb_amount', 'tgt': 'cumulative_bonus_amount'},
            {'src': 'mlac_hosp_cash_per_day', 'tgt': 'benefit_limit'},
            {'src': 'mlac_hosp_cash_no_of_days', 'tgt': 'benefit_days_count'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number', 'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'mlac_emi_pc_loan_account_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO'},
            {'src_expr': 'pd_location_code', 'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id', 'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no', 'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code', 'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
            {'src_expr': 'md_seq_no', 'tgt': 'HUB_RISK_OBJECT_BK__MD_SEQ_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8428_GPG_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8433_fhc_loader',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plc_hosp_cash_si', 'tgt': 'benefit_sum_insured'},
            {'src': 'plc_hosp_cash_per_day_benefit', 'tgt': 'benefit_limit'},
            {'src': 'plc_inpat_hosp_treat_plan', 'tgt': 'benefit_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number', 'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'pd_bank_ref_no1_lac_sac', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC'},
            {'src_expr': 'pd_location_code', 'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id', 'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no', 'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code', 'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
            {'src_expr': 'md_seq_no', 'tgt': 'HUB_RISK_OBJECT_BK__MD_SEQ_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8433_FHC_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8439_clh_loader',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'mlac_accdt_hosp_expenses', 'tgt': 'benefit_sum_insured'},
            {'src': 'mlc_acc_prot_cov_plan', 'tgt': 'benefit_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number', 'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'plc_loan_acc_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO'},
            {'src_expr': 'pd_location_code', 'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id', 'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no', 'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code', 'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8439_CLH_LOADER'
    },
    {
        'model': 'stg_hcf_member_dtls',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'anciliary', 'tgt': 'benefit_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_hc_part_extn',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'no_of_days', 'tgt': 'applicable_days'},
            {'src': 'benefit_opted', 'tgt': 'benefit_code'}
        ],
        'hub_key_columns': [
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_illness_bases_extn',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'medical_expenses', 'tgt': 'benefit_limit'}
        ],
        'hub_key_columns': [
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ILLNESS_BASES_EXTN'
    },
    {
        'model': 'stg_pmjay_prmbook_dtls',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_PMJAY_PRMBOOK_DTLS'
    },
    {
        'model': 'stg_hcp_transcript_url',
        'alias': 't7',
        'key_column': 'HUB_ASSESSMENT_BK__SCRUTINY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pa_cover', 'tgt': 'benefit_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'imd_code', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCP_TRANSCRIPT_URL'
    },
    {
        'model': 'stg_hcs_plansi_mapp',
        'alias': 't8',
        'key_column': 'HUB_PRODUCT_BK__PRODUCT_CODE',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'air_ambulance_si', 'tgt': 'benefit_sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'product_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HCS_PLANSI_MAPP'
    }
] -%}

{%- set output_columns = [
    'benefit_sum_insured',
    'cumulative_bonus_percentage',
    'cumulative_bonus_amount',
    'benefit_limit',
    'benefit_days_count',
    'benefit_name',
    'applicable_days',
    'benefit_code'
] -%}

{%- set coalesce_rules = {
    'benefit_sum_insured': ['t0', 't1', 't2', 't3', 't7', 't8'],
    'cumulative_bonus_percentage': ['t0'],
    'cumulative_bonus_amount': ['t0'],
    'benefit_limit': ['t0', 't1', 't5'],
    'benefit_days_count': ['t0'],
    'benefit_name': ['t1', 't2'],
    'applicable_days': ['t4'],
    'benefit_code': ['t4']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t0.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t7.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t0.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t0.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t1.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t2.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t0.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t3.HUB_PARTY_BK__MEMBER_NO, t4.HUB_PARTY_BK__PART_ID)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__POL_SERIAL_NO, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__CONTRACT_ID, t4.HUB_POLICY_BK__CONTRACT_ID, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__POLICY_REF)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t0.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t7.HUB_PRODUCT_BK__PRODUCT_CODE, t8.HUB_PRODUCT_BK__PRODUCT_CODE)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t0.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t1.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t3.HUB_RISK_OBJECT_BK__MEMBER_NO)'},
    {'name': 'T0__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't0.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T0__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't0.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T1__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't1.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T2__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't2.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_coverage_member_benefit'
) }}
