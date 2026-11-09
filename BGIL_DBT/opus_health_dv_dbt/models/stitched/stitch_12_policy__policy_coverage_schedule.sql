/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Procedure: the 9-step REUSABLE RESHAPE PROCEDURE documented in the pilot
   stitch_01_policy__policy_header.sql (task 4.1). Applied here by task 6.1.

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk'); satellite: SAT_POLICY_COVERAGE_SCHEDULE
   target_sat        : sat_policy_coverage_schedule  (header "SAT_POLICY_COVERAGE_SCHEDULE" ==
                       stage_12 "SAT_POLICY_COVERAGE_SCHEDULE_HASHDIFF" == filename tail).
   key_column per src: each source's HUB_POLICY_BK__* column (the HUB_POLICY-grain key).
     - all 15 sources carry a HUB_POLICY_BK__* column -> used directly as key_column.
     - t14 (BJAZ_GRP_HLT_DTLS): carries HUB_POLICY_BK__POLICY_NO; the spine-merge picks
       it up there. key_column=HUB_POLICY_BK__POLICY_NO even though the central view's
       FULL OUTER joined t14 on HUB_ASSESSMENT_BK__SCRUTINY_NO. Grain-aligned per rule 4.
   PAYLOAD same-alias collisions (macro emits ONE col per alias per tgt; the central view
   coalesced two+ raw cols from the SAME alias into one attr -- the secondary raw cols are
   a recorded payload-precedence limitation of the macro form):
     - sum_insured            : kept t1.plac_air_ambulance_si; dropped-secondary t1.plc_inpat_hosp_treat_si
     - coverage_opted_indicator: kept t7.annual_health_check; dropped-secondary t7.congenital_intrnal_disease_cvr,
       t7.corona_protection, t7.dental_treatment, t7.domiciliary_hosp_covr, t7.opt_yn, t7.out_patient_treatment
     - sub_limit_amount       : kept t7.ambulance; dropped-secondary t7.amount, t7.caesarian_delivery,
       t7.child_coverage, t7.corporate_buffer_ci, t7.day_care_procedures, t7.excess_maternity_benefitsamt,
       t7.icu, t7.maternity_benefit, t7.normal_delivery, t7.per_family_limit, t7.per_family_limit_ci,
       t7.post_hospitalization, t7.pre_hospitalization, t7.pre_post_natal_exp, t7.pre_post_natal_expenses
   merge order       : R8 precedence (v2 > legacy > delta3) preserved as the central
                       view's documented COALESCE order, transcribed verbatim per attr.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_dt_pol_cov',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'prem_base_cover', 'tgt': 'premium_for_coverage'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno',   'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'part_id',     'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_POL_COV'
    },
    {
        'model': 'stg_hcp_prod_8432_ecp_loader',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plac_air_ambulance_cover', 'tgt': 'coverage_opted_indicator'},
            {'src': 'plac_air_ambulance_si',    'tgt': 'sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',      'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',           'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'pd_bank_ref_no1_lac_sac', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC'},
            {'src_expr': 'pd_location_code',        'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',      'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',        'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',     'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',           'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',         'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8432_ECP_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8433_fhc_loader',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plc_inpat_hosp_treat_si', 'tgt': 'sum_insured'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',      'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',           'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'pd_bank_ref_no1_lac_sac', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC'},
            {'src_expr': 'pd_location_code',        'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',      'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',        'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',     'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',           'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',         'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
            {'src_expr': 'md_seq_no',               'tgt': 'HUB_RISK_OBJECT_BK__MD_SEQ_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8433_FHC_LOADER'
    },
    {
        'model': 'stg_ctngy_covers_ext',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'cover_code',  'tgt': 'coverage_reference'},
            {'src': 'cover_no',    'tgt': 'coverage_sequence'},
            {'src': 'cover_prem',  'tgt': 'premium_for_coverage'},
            {'src': 'plan_id',     'tgt': 'plan_reference'},
            {'src': 'section_id',  'tgt': 'section_reference'},
            {'src': 'version_no',  'tgt': 'source_row_version_number'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('SCHEME:' || nullif(trim(SCHEME_CODE),''), 'SCHEME:')", 'tgt': 'HUB_PRODUCT_BK__SCHEME_SCHEME_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_CTNGY_COVERS_EXT'
    },
    {
        'model': 'stg_ec_mem_dtls_extn',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'deductible_amt', 'tgt': 'deductible_amount'}
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
        'model': 'stg_enroll_pol_dtls',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'meternitybenifitavil', 'tgt': 'coverage_opted_indicator'}
        ],
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
        'model': 'stg_grp_hlt_coverage_dtls',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'maternity_benefit', 'tgt': 'sub_limit_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(reg_no),'')", 'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(product),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': "nullif(trim(quote_no),'')", 'tgt': 'HUB_QUOTE_BK__QUOTE_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_GRP_HLT_COVERAGE_DTLS'
    },
    {
        'model': 'stg_grp_hlt_maternity_dtls',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'annual_health_check',   'tgt': 'coverage_opted_indicator'},
            {'src': 'ambulance',             'tgt': 'sub_limit_amount'},
            {'src': 'maternity_copayment_amt', 'tgt': 'co_payment_amount'},
            {'src': 'maternity_copayment_per', 'tgt': 'co_payment_percentage'},
            {'src': 'nine_mon_waiting_period', 'tgt': 'waiting_period'}
        ],
        'hub_key_columns': [
            {'src_expr': 'reg_no',       'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product',      'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_MATERNITY_DTLS'
    },
    {
        'model': 'stg_hc_part_extn',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'waiting_period', 'tgt': 'waiting_period'}
        ],
        'hub_key_columns': [
            {'src_expr': 'part_id',     'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_hg_pol_dtls',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'air_ambulance_yn', 'tgt': 'coverage_opted_indicator'}
        ],
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
        'model': 'stg_ihg_mem_dtls_extn',
        'alias': 't10',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'waiting_period', 'tgt': 'waiting_period'}
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
        'alias': 't11',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'waiting_period', 'tgt': 'waiting_period'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id',     'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no',      'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id',    'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_starpkg_cover_dtls',
        'alias': 't12',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'cover_code',  'tgt': 'coverage_reference'},
            {'src': 'cover_no',    'tgt': 'coverage_sequence'},
            {'src': 'cover_plan',  'tgt': 'plan_reference'},
            {'src': 'cover_prem',  'tgt': 'premium_for_coverage'},
            {'src': 'section_code','tgt': 'section_reference'},
            {'src': 'version_no',  'tgt': 'source_row_version_number'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_STARPKG_COVER_DTLS'
    },
    {
        'model': 'stg_ocp_policy_covers',
        'alias': 't13',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'agent_commission_company_share', 'tgt': 'agent_commission_company_share_amount'},
            {'src': 'agent_commission_com_share_swf', 'tgt': 'agent_commission_company_share_currency_code'},
            {'src': 'agent_commission_whole_cover',   'tgt': 'agent_commission_whole_cover_amount'},
            {'src': 'agent_commission_whole_cov_swf', 'tgt': 'agent_commission_whole_cover_currency_code'},
            {'src': 'share_portion',                  'tgt': 'co_insurance_share_portion'},
            {'src': 'cvc_code',                       'tgt': 'cover_variant_classification_code'},
            {'src': 'cover_code',                     'tgt': 'coverage_reference'},
            {'src': 'cover_no',                       'tgt': 'coverage_sequence'},
            {'src': 'ftpremium_or_company_share',     'tgt': 'full_term_premium_original_company_share'},
            {'src': 'ftpremium_or_company_share_swf', 'tgt': 'full_term_premium_original_company_share_currency_code'},
            {'src': 'ftpremium_or_whole_cover',       'tgt': 'full_term_premium_original_whole_cover'},
            {'src': 'ftpremium_or_whole_cover_swf',   'tgt': 'full_term_premium_original_whole_cover_currency_code'},
            {'src': 'ftpremium_sys_company_share',    'tgt': 'full_term_premium_system_company_share'},
            {'src': 'ftpremium_sys_comp_share_swf',   'tgt': 'full_term_premium_system_company_share_currency_code'},
            {'src': 'ftpremium_sys_whole_cover',      'tgt': 'premium_for_coverage'},
            {'src': 'ftpremium_sys_whole_cover_swf',  'tgt': 'full_term_premium_system_whole_cover_currency_code'},
            {'src': 'pcov_contract_id',               'tgt': 'parent_coverage_contract_reference'},
            {'src': 'pcov_cover_code',                'tgt': 'parent_coverage_reference'},
            {'src': 'pcov_cover_no',                  'tgt': 'parent_coverage_sequence'},
            {'src': 'pcov_partition_no',              'tgt': 'parent_coverage_partition_number'},
            {'src': 'reinsurable_risk_amount',        'tgt': 'reinsurable_risk_amount'},
            {'src': 'reinsurable_risk_amount_swf',    'tgt': 'reinsurable_risk_amount_currency_code'},
            {'src': 'sum_insured_company_share',      'tgt': 'sum_insured_company_share'},
            {'src': 'sum_insured_company_share_swf',  'tgt': 'sum_insured_company_share_currency_code'},
            {'src': 'sum_insured_whole_cover',        'tgt': 'sum_insured'},
            {'src': 'sum_insured_whole_cover_swf',    'tgt': 'sum_insured_whole_cover_currency_code'},
            {'src': 'surcharge_discount',             'tgt': 'surcharge_or_discount_amount'},
            {'src': 'version_no',                     'tgt': 'source_row_version_number'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_OCP_POLICY_COVERS'
    },
    {
        'model': 'stg_grp_hlt_dtls',
        'alias': 't14',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'children_limit', 'tgt': 'sub_limit_amount'},
            {'src': 'si_coverages',   'tgt': 'sum_insured'}
        ],
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
    }
] -%}

{%- set output_columns = [
    'premium_for_coverage',
    'sum_insured',
    'coverage_opted_indicator',
    'deductible_amount',
    'sub_limit_amount',
    'waiting_period',
    'co_payment_amount',
    'co_payment_percentage',
    'plan_reference',
    'source_row_version_number',
    'coverage_reference',
    'coverage_sequence',
    'section_reference',
    'full_term_premium_original_whole_cover',
    'full_term_premium_original_company_share',
    'full_term_premium_system_company_share',
    'sum_insured_company_share',
    'co_insurance_share_portion',
    'agent_commission_whole_cover_amount',
    'agent_commission_company_share_amount',
    'reinsurable_risk_amount',
    'surcharge_or_discount_amount',
    'cover_variant_classification_code',
    'parent_coverage_reference',
    'parent_coverage_sequence',
    'parent_coverage_partition_number',
    'parent_coverage_contract_reference',
    'full_term_premium_original_whole_cover_currency_code',
    'full_term_premium_system_whole_cover_currency_code',
    'full_term_premium_original_company_share_currency_code',
    'full_term_premium_system_company_share_currency_code',
    'sum_insured_whole_cover_currency_code',
    'sum_insured_company_share_currency_code',
    'agent_commission_whole_cover_currency_code',
    'agent_commission_company_share_currency_code',
    'reinsurable_risk_amount_currency_code'
] -%}

{#-- coalesce_rules: precedence order transcribed from the central view's final-SELECT
     payload COALESCEs. Single-alias rules emit a bare column reference (macro behaviour).
     Same-alias collisions represented once -- see header dropped-secondary note. --#}
{%- set coalesce_rules = {
    'premium_for_coverage':                                 ['t3', 't0', 't12', 't13'],
    'sum_insured':                                          ['t1', 't2', 't14', 't13'],
    'coverage_opted_indicator':                             ['t5', 't1', 't7', 't9'],
    'deductible_amount':                                    ['t4'],
    'sub_limit_amount':                                     ['t14', 't7', 't6'],
    'waiting_period':                                       ['t7', 't8', 't10', 't11'],
    'co_payment_amount':                                    ['t7'],
    'co_payment_percentage':                                ['t7'],
    'plan_reference':                                       ['t3', 't12'],
    'source_row_version_number':                            ['t3', 't12', 't13'],
    'coverage_reference':                                   ['t3', 't12', 't13'],
    'coverage_sequence':                                    ['t3', 't12', 't13'],
    'section_reference':                                    ['t3', 't12'],
    'full_term_premium_original_whole_cover':               ['t13'],
    'full_term_premium_original_company_share':             ['t13'],
    'full_term_premium_system_company_share':               ['t13'],
    'sum_insured_company_share':                            ['t13'],
    'co_insurance_share_portion':                           ['t13'],
    'agent_commission_whole_cover_amount':                  ['t13'],
    'agent_commission_company_share_amount':                ['t13'],
    'reinsurable_risk_amount':                              ['t13'],
    'surcharge_or_discount_amount':                         ['t13'],
    'cover_variant_classification_code':                    ['t13'],
    'parent_coverage_reference':                            ['t13'],
    'parent_coverage_sequence':                             ['t13'],
    'parent_coverage_partition_number':                     ['t13'],
    'parent_coverage_contract_reference':                   ['t13'],
    'full_term_premium_original_whole_cover_currency_code': ['t13'],
    'full_term_premium_system_whole_cover_currency_code':   ['t13'],
    'full_term_premium_original_company_share_currency_code':['t13'],
    'full_term_premium_system_company_share_currency_code': ['t13'],
    'sum_insured_whole_cover_currency_code':                ['t13'],
    'sum_insured_company_share_currency_code':              ['t13'],
    'agent_commission_whole_cover_currency_code':           ['t13'],
    'agent_commission_company_share_currency_code':         ['t13'],
    'reinsurable_risk_amount_currency_code':                ['t13']
} %}

{#-- hub_keys: transcribed VERBATIM from the central view's final SELECT.
     Family 1 = merged-spine BKs (coalesce over alias.tgt). Family 2 = auxiliary
     per-source BKs (single alias.tgt, name prefixed TN__). Order preserved. --#}
{%- set hub_keys = [
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t14.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 'coalesce(t0.HUB_COVERAGE_BK__HCP_SEQNO, t9.HUB_COVERAGE_BK__COVER_CODE)'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t9.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t10.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t11.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t4.HUB_DOCUMENT_BK__MEDICAL_REPORT, t10.HUB_DOCUMENT_BK__MEDICAL_REPORT, t11.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t1.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t2.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__PART_ID, t4.HUB_PARTY_BK__MEMBER_NO, t8.HUB_PARTY_BK__PART_ID, t9.HUB_PARTY_BK__PART_ID, t10.HUB_PARTY_BK__MEMBER_NO, t11.HUB_PARTY_BK__MEMBER_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__CONTRACT_ID, t4.HUB_POLICY_BK__CONTRACT_ID, t5.HUB_POLICY_BK__POLICY_NO, t6.HUB_POLICY_BK__REG_NO, t7.HUB_POLICY_BK__REG_NO, t8.HUB_POLICY_BK__CONTRACT_ID, t9.HUB_POLICY_BK__CONTRACT_ID, t10.HUB_POLICY_BK__CONTRACT_ID, t11.HUB_POLICY_BK__CONTRACT_ID, t12.HUB_POLICY_BK__CONTRACT_ID, t13.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t3.HUB_PRODUCT_BK__SCHEME_SCHEME_CODE, t6.HUB_PRODUCT_BK__PRODUCT, t7.HUB_PRODUCT_BK__PRODUCT, t9.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t14.HUB_PRODUCT_BK__PRODUCT)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t5.HUB_PROPOSAL_BK__SCRUTINY_NO, t9.HUB_PROPOSAL_BK__QUOTE_REF_NO, t14.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t5.HUB_QUOTE_BK__QUOTATION_NO, t6.HUB_QUOTE_BK__QUOTE_NO, t7.HUB_QUOTE_BK__QUOTE_SUB_NO, t9.HUB_QUOTE_BK__QUOTE_REF_NO, t14.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t2.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t4.HUB_RISK_OBJECT_BK__MEMBER_NO)'},
    {'name': 'T1__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't1.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T1__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't1.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T2__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't2.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T2__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't2.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T5__HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN', 'expr': 't5.HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN'},
    {'name': 'T5__HUB_LOCATION_BK__PH_ADDRESS', 'expr': 't5.HUB_LOCATION_BK__PH_ADDRESS'},
    {'name': 'T5__HUB_LOCATION_BK__PP_ADDRESS', 'expr': 't5.HUB_LOCATION_BK__PP_ADDRESS'},
    {'name': 'T5__HUB_PARTY_BK__EMP_RM_CODE', 'expr': 't5.HUB_PARTY_BK__EMP_RM_CODE'},
    {'name': 'T5__HUB_PARTY_BK__CORPORATE_ID', 'expr': 't5.HUB_PARTY_BK__CORPORATE_ID'},
    {'name': 'T5__HUB_PARTY_BK__IMD_CODE', 'expr': 't5.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T5__HUB_PARTY_BK__PH_ID', 'expr': 't5.HUB_PARTY_BK__PH_ID'},
    {'name': 'T5__HUB_PARTY_BK__PP_ID', 'expr': 't5.HUB_PARTY_BK__PP_ID'},
    {'name': 'T5__HUB_PARTY_BK__SUBIMD_CODE', 'expr': 't5.HUB_PARTY_BK__SUBIMD_CODE'},
    {'name': 'T9__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't9.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T9__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't9.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T14__HUB_ORG_UNIT_BK__BRANCH', 'expr': 't14.HUB_ORG_UNIT_BK__BRANCH'},
    {'name': 'T14__HUB_ORG_UNIT_BK__DEPARTMENT', 'expr': 't14.HUB_ORG_UNIT_BK__DEPARTMENT'},
    {'name': 'T14__HUB_POLICY_BK__POLICY_NO', 'expr': 't14.HUB_POLICY_BK__POLICY_NO'},
    {'name': 'T14__HUB_POLICY_BK__PREV_POL_REF', 'expr': 't14.HUB_POLICY_BK__PREV_POL_REF'},
    {'name': 'T14__HUB_POLICY_BK__REG_NO', 'expr': 't14.HUB_POLICY_BK__REG_NO'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_policy_coverage_schedule'
) }}
