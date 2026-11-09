/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   This file is the PILOT (task 4.1). It establishes the repeatable reshape procedure
   applied uniformly by the batch tasks (5.1, 6.1, 7.1, 8.1, 9.1).

   ============================================================================
   REUSABLE RESHAPE PROCEDURE (apply per central view, in numeric order)
   ============================================================================
   1. HEADER  : read the central view header -> spine hub, contributing stg_* models,
                satellite fed, merge order (R8: v2 > legacy > delta3).
   2. STAGE   : read stage_NN_*.sql -> the <SAT>_HASHDIFF payload list = output_columns
                (lower-cased); the satellite name -> target_sat (lower-cased).
   3. SOURCES : one sources[] entry per tN CTE: model=ref name, alias=tN (preserved),
                ldts_column='inc_job_updated_at', source_tag='OPUS_HEALTH_<RUN>_<RAWTABLE>'
                from the staging model's `source run` + `source table` header.
   4. KEY_COLUMN SELECTION RULE (the load-bearing decision):
                The macro merges at ONE hub grain = the satellite's spine hub
                (here HUB_POLICY). key_column per source = that source's per-source
                HUB_POLICY_BK__* column (the alias-local business key that aligns to
                parent_bk / the satellite's HUB_POLICY grain), NOT whatever column the
                central view's FULL OUTER physically joined on. Where a source exposes a
                HUB_POLICY_BK__* column, use it. For a source that carries NO HUB_POLICY
                key, use its actual central-view join key and record the grain deviation
                (see t42 below) -- it stays a source so the hub_keys[].expr terms that
                reference its alias still resolve.
   5. PAYLOAD : columns[{src,tgt}] per source maps each raw payload col -> canonical
                output attr; coalesce_rules[tgt]=[alias,...] in central-view precedence
                order. (Payload coalesce fidelity is coverage-checked, not byte-exact.)
   6. HUB KEYS: sources[].hub_key_columns=[{src_expr,tgt}] transcribes each tN CTE's
                inline hub-key expression VERBATIM (bare nullif(trim(...)), prefix
                literals 'LOANACC:'/'PRODUCT:'/'TXN:'/'CUSTID:'/'EMP:'/'PARTID:',
                md5(normalise(upper(...))) hashes). hub_keys=[{name,expr}] transcribes the
                final-SELECT hub-BK columns VERBATIM: family 1 = merged-spine BK
                coalesce(...) (name like HUB_POLICY_BK); family 2 = auxiliary per-source
                BK single alias.tgt (name like T4__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE).
   7. EMIT    : config(view) + four Jinja vars + ONE stitch_incremental_hcon(...) call
                with unique_key='parent_bk', target_sat='sat_<name>'.
   8. VALIDATE: every output col in a coalesce rule; every coalesce alias in sources;
                every alias.tgt in a hub_keys[].expr declared as a hub_key_columns[].tgt
                on that alias; every source_tag non-empty <SYSTEM>_<TABLE>; target_sat
                matches stage/header.
   9. FIDELITY: hub_keys names + exprs match the central view's final-SELECT hub-BK
                columns EXACTLY (names, prefix literals, hashes, COALESCE order).

   ============================================================================
   PILOT MAPPING DECISIONS (stitch_01_policy__policy_header)
   ============================================================================
   spine hub / grain : HUB_POLICY  (unique_key='parent_bk'); satellite: SAT_POLICY_HEADER
   target_sat        : sat_policy_header  (header "SAT_POLICY_HEADER" == stage
                       "SAT_POLICY_HEADER_HASHDIFF" == filename tail "policy_header").
   key_column per src: each source's HUB_POLICY_BK__* column (the HUB_POLICY-grain key).
     - 41 of 43 sources carry a HUB_POLICY_BK__* column -> used directly as key_column.
     - t41 (BJAZ_GRP_HLT_DTLS): carries HUB_POLICY_BK__POLICY_NO (the column the spine
       merge uses for t41); key_column=HUB_POLICY_BK__POLICY_NO even though the central
       view's FULL OUTER joined t41 on HUB_ASSESSMENT_BK__SCRUTINY_NO. Grain-aligned
       choice per rule 4.
     - t42 (BJAZ_HM_HOSPITAL_MASTER): carries NO HUB_POLICY key; the central view joined
       it on HUB_AGREEMENT_BK__HOSID = t24.HUB_AGREEMENT_BK__DEAL_ID. DOCUMENTED GRAIN
       DEVIATION: it cannot key at HUB_POLICY grain, so key_column=HUB_AGREEMENT_BK__HOSID
       (its real join key). It is kept as a source only so the family-1 hub_keys exprs
       that reference t42.* (HUB_AGREEMENT_BK, HUB_DISTRIBUTION_CHANNEL_BK, HUB_LOCATION_BK,
       HUB_PARTY_BK) resolve. Its one payload contribution (expiry_date -> risk_expiry_date)
       and its hub keys are only populated when t42 survives the parent_bk row-pick.
   PAYLOAD same-alias collisions (macro emits ONE col per alias per tgt; the central
   view coalesced two raw cols from the SAME alias into one attr -- the secondary raw
   col is a recorded payload-precedence limitation of the macro form, not a hub-key issue):
     - application_submission_date: kept t33.dateofsubmission; dropped-secondary t33.entry_date
     - policy_type                : kept t12.policy_type;      dropped-secondary t12.pol_type
     - risk_expiry_date           : kept t41.expiry_date;      dropped-secondary t41.expiry_date_gpg
   merge order       : R8 precedence (v2 > legacy > delta3) preserved as the central
                       view's documented COALESCE order, transcribed verbatim per attr.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_ba_ccp_sub_mater_dtls',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'customer_comm',       'tgt': 'customer_communication_text'},
            {'src': 'remarks',             'tgt': 'policy_remarks'},
            {'src': 'policy_period',       'tgt': 'policy_term'},
            {'src': 'risk_expiry_time',    'tgt': 'risk_end_time'},
            {'src': 'version_no',          'tgt': 'policy_version_number'},
            {'src': 'sum_insured',         'tgt': 'sum_insured_total'},
            {'src': 'risk_inception_time', 'tgt': 'risk_start_time'},
            {'src': 'risk_expiry_date',    'tgt': 'risk_expiry_date'},
            {'src': 'risk_inception_date', 'tgt': 'risk_inception_date'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('LOANACC:' || nullif(trim(LOAN_ACC_NUMBER),''), 'LOANACC:')", 'tgt': 'HUB_RISK_OBJECT_BK__LOANACC_LOAN_ACC_NUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BA_CCP_SUB_MATER_DTLS'
    },
    {
        'model': 'stg_hcp_pol_mst',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_status',    'tgt': 'policy_status'},
            {'src': 'policy_end_date',  'tgt': 'risk_expiry_date'},
            {'src': 'policy_start_date','tgt': 'risk_inception_date'}
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
        'model': 'stg_hcp_port_wordings',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pol_version_no', 'tgt': 'policy_version_number'},
            {'src': 'inception_date', 'tgt': 'risk_inception_date'},
            {'src': 'top_indicator',  'tgt': 'top_up_policy_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no', 'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'partner_id',  'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PORT_WORDINGS'
    },
    {
        'model': 'stg_hcp_prime_rider_dtls',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__BASE_POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_period', 'tgt': 'policy_term'}
        ],
        'hub_key_columns': [
            {'src_expr': 'base_policy_ref', 'tgt': 'HUB_POLICY_BK__BASE_POLICY_REF'},
            {'src_expr': 'product_code',    'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PRIME_RIDER_DTLS'
    },
    {
        'model': 'stg_hcp_prod_8428_gpg_loader',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_policy_period',           'tgt': 'policy_term'},
            {'src': 'pd_risk_inception_date',     'tgt': 'risk_inception_date'},
            {'src': 'pd_risk_inception_time_hhmm','tgt': 'risk_start_time'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',           'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',                'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'mlac_emi_pc_loan_account_no',  'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO'},
            {'src_expr': 'pd_location_code',             'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',           'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',             'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',          'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',                'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',              'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
            {'src_expr': 'md_seq_no',                    'tgt': 'HUB_RISK_OBJECT_BK__MD_SEQ_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8428_GPG_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8432_ecp_loader',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_policy_period',           'tgt': 'policy_term'},
            {'src': 'pd_risk_end_date',           'tgt': 'risk_expiry_date'},
            {'src': 'pd_risk_inception_date',     'tgt': 'risk_inception_date'},
            {'src': 'pd_risk_inception_time_hhmm','tgt': 'risk_start_time'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',          'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',               'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'pd_bank_ref_no1_lac_sac',     'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC'},
            {'src_expr': 'pd_location_code',            'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',          'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',            'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',         'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',               'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',             'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8432_ECP_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8433_fhc_loader',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_policy_period',           'tgt': 'policy_term'},
            {'src': 'pd_risk_end_date',           'tgt': 'risk_expiry_date'},
            {'src': 'pd_risk_inception_date',     'tgt': 'risk_inception_date'},
            {'src': 'pd_risk_inception_time_hhmm','tgt': 'risk_start_time'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',          'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',               'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'pd_bank_ref_no1_lac_sac',     'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC'},
            {'src_expr': 'pd_location_code',            'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',          'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',            'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',         'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',               'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',             'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'},
            {'src_expr': 'md_seq_no',                   'tgt': 'HUB_RISK_OBJECT_BK__MD_SEQ_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8433_FHC_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8439_clh_loader',
        'alias': 't7',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pd_master_policy_number',    'tgt': 'master_policy_reference'},
            {'src': 'pd_policy_period',           'tgt': 'policy_term'},
            {'src': 'pd_risk_inception_date',     'tgt': 'risk_inception_date'},
            {'src': 'pd_risk_inception_time_hhmm','tgt': 'risk_start_time'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number',          'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id',               'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'plc_loan_acc_no',             'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO'},
            {'src_expr': 'pd_location_code',            'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code',          'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code',            'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id',         'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no',               'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code',             'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8439_CLH_LOADER'
    },
    {
        'model': 'stg_bgil_gmc_final_instl_data',
        'alias': 't8',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_expiry_date','tgt': 'risk_expiry_date'},
            {'src': 'policy_start_date', 'tgt': 'risk_inception_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'emp_code',  'tgt': 'HUB_PARTY_BK__EMP_CODE'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BGIL_GMC_FINAL_INSTL_DATA'
    },
    {
        'model': 'stg_bandhan_medi_clam',
        'alias': 't9',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'no_of_years',    'tgt': 'policy_term'},
            {'src': 'term_end_date',  'tgt': 'risk_expiry_date'},
            {'src': 'term_start_date','tgt': 'risk_inception_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',   'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'reference_id',  'tgt': 'HUB_CLAIM_BK__REFERENCE_ID'},
            {'src_expr': 'partner_id',    'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'customer_id',   'tgt': 'HUB_PARTY_BK__CUSTOMER_ID'},
            {'src_expr': 'policy_ref',    'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'plan_id',       'tgt': 'HUB_PRODUCT_BK__PLAN_ID'},
            {'src_expr': 'product_code',  'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_BANDHAN_MEDI_CLAM'
    },
    {
        'model': 'stg_card_dtls',
        'alias': 't10',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'status',      'tgt': 'policy_status'},
            {'src': 'policy_type', 'tgt': 'policy_type'},
            {'src': 'expiry_date', 'tgt': 'risk_expiry_date'},
            {'src': 'eff_date',    'tgt': 'risk_inception_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'card_no',    'tgt': 'HUB_DOCUMENT_BK__CARD_NO'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_CARD_DTLS'
    },
    {
        'model': 'stg_ctngy_gc_control',
        'alias': 't11',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'location_code',      'tgt': 'issuing_org_unit_code'},
            {'src': 'master_contract_id', 'tgt': 'policy_reference_number'},
            {'src': 'remarks',            'tgt': 'policy_remarks'},
            {'src': 'premium_payer_id',   'tgt': 'premium_payer_reference'},
            {'src': 'product_code',       'tgt': 'product_reference'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(POLICY_REF),'')", 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(PRODUCT_CODE),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_CTNGY_GC_CONTROL'
    },
    {
        'model': 'stg_ecard_pol_dtls_config',
        'alias': 't12',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_status',     'tgt': 'policy_status'},
            {'src': 'policy_type',       'tgt': 'policy_type'},
            {'src': 'risk_expiry_date',  'tgt': 'risk_expiry_date'},
            {'src': 'risk_inception_date','tgt': 'risk_inception_date'},
            {'src': 'short_period_date', 'tgt': 'short_period_end_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'quote_ref',  'tgt': 'HUB_QUOTE_BK__QUOTE_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ECARD_POL_DTLS_CONFIG'
    },
    {
        'model': 'stg_ec_mem_dtls_extn',
        'alias': 't13',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'expiry_date',    'tgt': 'risk_expiry_date'},
            {'src': 'inception_date', 'tgt': 'risk_inception_date'}
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
        'model': 'stg_ehh_pol_dtls',
        'alias': 't14',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'referenc_id',    'tgt': 'policy_number'},
            {'src': 'pol_period',     'tgt': 'policy_term'},
            {'src': 'term_end_date',  'tgt': 'risk_expiry_date'},
            {'src': 'term_start_date','tgt': 'risk_inception_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',         'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'partner_id',          'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'location_code',       'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode',        'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc',          'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location',     'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location',       'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'company_org_unit',    'tgt': 'HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
            {'src_expr': 'policy_ref',          'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'product_4digit_code', 'tgt': 'HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_EHH_POL_DTLS'
    },
    {
        'model': 'stg_enroll_pol_dtls',
        'alias': 't15',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'other_remarks','tgt': 'additional_remarks'},
            {'src': 'hat_ref_no',   'tgt': 'policy_reference_number'},
            {'src': 'remarks',      'tgt': 'policy_remarks'},
            {'src': 'policy_type',  'tgt': 'policy_type'},
            {'src': 'product_name', 'tgt': 'product_reference'},
            {'src': 'si_type',      'tgt': 'sum_insured_basis'}
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
        'model': 'stg_enroll_scr_dtls',
        'alias': 't16',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'co_insurance',        'tgt': 'co_insurance_indicator'},
            {'src': 'branch',              'tgt': 'issuing_org_unit_code'},
            {'src': 'buiseness_source',    'tgt': 'issuing_channel_reference'},
            {'src': 'line_of_buiseness',   'tgt': 'line_of_business'},
            {'src': 'policy_period',       'tgt': 'policy_term_days'},
            {'src': 'total_sum_insured',   'tgt': 'sum_insured_total'},
            {'src': 'rural_yn',            'tgt': 'rural_sector_policy_indicator'},
            {'src': 'product_code',        'tgt': 'product_reference'},
            {'src': 'policy_effective_till','tgt': 'risk_expiry_date'},
            {'src': 'policy_effective_from','tgt': 'risk_inception_date'}
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
        'alias': 't17',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policyissuedate','tgt': 'issue_date'},
            {'src': 'premiumpayerid', 'tgt': 'premium_payer_reference'},
            {'src': 'ptodate',        'tgt': 'risk_expiry_date'},
            {'src': 'pstartdate',     'tgt': 'risk_inception_date'}
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
        'model': 'stg_gmc_bases_extn',
        'alias': 't18',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'comments',       'tgt': 'additional_remarks'},
            {'src': 'version_no',     'tgt': 'policy_version_number'},
            {'src': 'inception_date', 'tgt': 'risk_inception_date'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(contract_id),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_GMC_BASES_EXTN'
    },
    {
        'model': 'stg_gpg_pol_dtls',
        'alias': 't19',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_period',      'tgt': 'policy_term'},
            {'src': 'policy_type',        'tgt': 'policy_type'},
            {'src': 'risk_expiry_date',  'tgt': 'risk_expiry_date'},
            {'src': 'risk_inception_date','tgt': 'risk_inception_date'},
            {'src': 'risk_inception_time','tgt': 'risk_start_time'}
        ],
        'hub_key_columns': [
            {'src_expr': 'scrutiny_no',      'tgt': 'HUB_ASSESSMENT_BK__SCRUTINY_NO'},
            {'src_expr': 'imd_code',         'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'lms_no',           'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__LMS_NO'},
            {'src_expr': 'company_org_unit', 'tgt': 'HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
            {'src_expr': 'bagic_e_code',     'tgt': 'HUB_PARTY_BK__BAGIC_E_CODE'},
            {'src_expr': 'bagic_rm_e_code',  'tgt': 'HUB_PARTY_BK__BAGIC_RM_E_CODE'},
            {'src_expr': 'imd_code',         'tgt': 'HUB_PARTY_BK__IMD_CODE'},
            {'src_expr': 'sub_imd_code',     'tgt': 'HUB_PARTY_BK__SUB_IMD_CODE'},
            {'src_expr': 'reference_id',     'tgt': 'HUB_POLICY_BK__REFERENCE_ID'},
            {'src_expr': 'product_code',     'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 're_insu',          'tgt': 'HUB_REINSURANCE_TREATY_BK__RE_INSU'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GPG_POL_DTLS'
    },
    {
        'model': 'stg_gp_hospital_cash',
        'alias': 't20',
        'key_column': 'HUB_POLICY_BK__MASTER_POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'no_of_years',    'tgt': 'policy_term'},
            {'src': 'term_end_date',  'tgt': 'risk_expiry_date'},
            {'src': 'term_start_date','tgt': 'risk_inception_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'imd_code',            'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 's_account_number',    'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER'},
            {'src_expr': 'user_id',             'tgt': 'HUB_PARTY_BK__USER_ID'},
            {'src_expr': 'master_policy_no',    'tgt': 'HUB_POLICY_BK__MASTER_POLICY_NO'},
            {'src_expr': 'product_code',        'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 'kgc_proposal_number', 'tgt': 'HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER'},
            {'src_expr': 'reference_id',        'tgt': 'HUB_PROPOSAL_BK__REFERENCE_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GP_HOSPITAL_CASH'
    },
    {
        'model': 'stg_grp_hlt_maternity_dtls',
        'alias': 't21',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'remarks_branch_ho', 'tgt': 'policy_remarks'}
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
        'alias': 't22',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'inception_date', 'tgt': 'risk_inception_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'part_id',     'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_hdfc_sec_fhpp',
        'alias': 't23',
        'key_column': 'HUB_POLICY_BK__REFERENCE_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'no_of_years',    'tgt': 'policy_term'},
            {'src': 'no_of_days',     'tgt': 'policy_term_days'},
            {'src': 'term_end_date',  'tgt': 'risk_expiry_date'},
            {'src': 'term_start_date','tgt': 'risk_inception_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'imd_code',         'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 's_account_number', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER'},
            {'src_expr': 'client_id',        'tgt': 'HUB_PARTY_BK__CLIENT_ID'},
            {'src_expr': 'reference_id',     'tgt': 'HUB_POLICY_BK__REFERENCE_ID'},
            {'src_expr': 'product_code',     'tgt': 'HUB_PRODUCT_BK__PRODUCT_CODE'},
            {'src_expr': 'ba_lead_no',       'tgt': 'HUB_PROPOSAL_BK__BA_LEAD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HDFC_SEC_FHPP'
    },
    {
        'model': 'stg_health_webservice_info',
        'alias': 't24',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_period',  'tgt': 'policy_term'},
            {'src': 'term_end_date',  'tgt': 'risk_expiry_date'},
            {'src': 'term_start_date','tgt': 'risk_inception_date'},
            {'src': 'si_flag',        'tgt': 'sum_insured_basis'},
            {'src': 'tot_plan_si',    'tgt': 'sum_insured_total'}
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
        'model': 'stg_hg_pol_dtls',
        'alias': 't25',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pol_period',       'tgt': 'policy_term'},
            {'src': 'term_end_date',    'tgt': 'risk_expiry_date'},
            {'src': 'term_start_date',  'tgt': 'risk_inception_date'},
            {'src': 'policy_type',      'tgt': 'policy_type'},
            {'src': 'total_sum_insured','tgt': 'sum_insured_total'}
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
        'model': 'stg_hm_coinsu_clm_dtls',
        'alias': 't26',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'valid_upto_date','tgt': 'risk_expiry_date'},
            {'src': 'comncmnt_date',  'tgt': 'risk_inception_date'}
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
        'model': 'stg_hm_hcm_extract',
        'alias': 't27',
        'key_column': 'HUB_POLICY_BK__POLICY',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'red', 'tgt': 'risk_expiry_date'},
            {'src': 'rid', 'tgt': 'risk_inception_date'}
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
        'model': 'stg_hm_member_dtls',
        'alias': 't28',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'term_end_date',  'tgt': 'risk_expiry_date'},
            {'src': 'term_start_date','tgt': 'risk_inception_date'}
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
        'model': 'stg_hm_orphan_reg',
        'alias': 't29',
        'key_column': 'HUB_POLICY_BK__POLICY_NUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'end_date',  'tgt': 'risk_expiry_date'},
            {'src': 'start_date','tgt': 'risk_inception_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id',       'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'location_code',  'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode',   'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc',     'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location','tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location',  'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'policy_number',  'tgt': 'HUB_POLICY_BK__POLICY_NUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_ORPHAN_REG'
    },
    {
        'model': 'stg_ihg_mem_dtls_extn',
        'alias': 't30',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'expiry_date',    'tgt': 'risk_expiry_date'},
            {'src': 'inception_date', 'tgt': 'risk_inception_date'}
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
        'model': 'stg_illness_bases_extn',
        'alias': 't31',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'covernote_date', 'tgt': 'cover_note_date'},
            {'src': 'covernote_no',   'tgt': 'cover_note_reference'}
        ],
        'hub_key_columns': [
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_ILLNESS_BASES_EXTN'
    },
    {
        'model': 'stg_pmjay_prmbook_dtls',
        'alias': 't32',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'business_flg', 'tgt': 'first_year_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_PMJAY_PRMBOOK_DTLS'
    },
    {
        'model': 'stg_pmsby_data_web_service',
        'alias': 't33',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'dateofsubmission', 'tgt': 'application_submission_date'},
            {'src': 'issued_date',      'tgt': 'issue_date'},
            {'src': 'policy_issued_yn', 'tgt': 'policy_issued_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(USER_TRANS_KEY_NO),'')", 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO'},
            {'src_expr': "md5(normalise(upper(nullif(trim( coalesce(ADDRESS_1,'') || ' ' || coalesce(ADDRESS_2,'') || ' ' || coalesce(PINCODE,'') ),''))))", 'tgt': 'HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(POLICY_REF),''),'') || '|NOMINEE|' || coalesce(nullif(trim(NOMINEENAME),''),''), '|NOMINEE|'))))", 'tgt': 'HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME'},
            {'src_expr': "nullif(trim(CUST_ID),'')", 'tgt': 'HUB_PARTY_BK__CUST_ID'},
            {'src_expr': "nullif(trim(POLICY_REF),'')", 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': "nullif('CUSTID:' || nullif(trim(CUST_ID),''), 'CUSTID:')", 'tgt': 'HUB_RISK_OBJECT_BK__CUSTID_CUST_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_PMSBY_DATA_WEB_SERVICE'
    },
    {
        'model': 'stg_policy_bases_extn',
        'alias': 't34',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'comments',          'tgt': 'additional_remarks'},
            {'src': 'covernote_date',    'tgt': 'cover_note_date'},
            {'src': 'covernote_no',      'tgt': 'cover_note_reference'},
            {'src': 'i_track_no',        'tgt': 'internal_tracking_number'},
            {'src': 'multi_year_flag',   'tgt': 'multi_year_indicator'},
            {'src': 'calculation_period','tgt': 'premium_calculation_period'},
            {'src': 'policy_period',     'tgt': 'policy_term'},
            {'src': 'term_start_time',   'tgt': 'risk_start_time'},
            {'src': 'sum_insured',       'tgt': 'sum_insured_total'},
            {'src': 'version_no',        'tgt': 'policy_version_number'}
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
        'alias': 't35',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'coins_flag',       'tgt': 'co_insurance_indicator'},
            {'src': 'covernote_date',   'tgt': 'cover_note_date'},
            {'src': 'covernote_no',     'tgt': 'cover_note_reference'},
            {'src': 'policy_issue_date','tgt': 'issue_date'},
            {'src': 'policy_ref',       'tgt': 'policy_reference_number'},
            {'src': 'policy_status',    'tgt': 'policy_status'},
            {'src': 'rural_flag',       'tgt': 'rural_sector_policy_indicator'},
            {'src': 'term_end_date',    'tgt': 'risk_expiry_date'},
            {'src': 'term_start_date',  'tgt': 'risk_inception_date'},
            {'src': 'sum_insured',      'tgt': 'sum_insured_total'},
            {'src': 'version_no',       'tgt': 'policy_version_number'}
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
        'model': 'stg_risk_trans_dtls',
        'alias': 't36',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_ref', 'tgt': 'policy_reference_number'}
        ],
        'hub_key_columns': [
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(CONTRACT_ID),''),'') || '|' || coalesce(nullif(trim(CLAIM_ID),''),'') || '|' || coalesce(nullif(trim(RISK_ID),''),''), '||'))))", 'tgt': 'HUB_ASSESSMENT_BK__CONTRACT_ID_CLAIM_ID_RISK_ID'},
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_RISK_TRANS_DTLS'
    },
    {
        'model': 'stg_sh_mem_dtls_extn',
        'alias': 't37',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'period_of_insurance','tgt': 'policy_term'},
            {'src': 'expiry_date',        'tgt': 'risk_expiry_date'},
            {'src': 'inception_date',     'tgt': 'risk_inception_date'}
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
        'model': 'stg_starpkg_pol_dtls',
        'alias': 't38',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pol_eff_years',    'tgt': 'policy_term'},
            {'src': 'total_si',         'tgt': 'sum_insured_total'},
            {'src': 'pol_eff_end_date', 'tgt': 'risk_expiry_date'},
            {'src': 'pol_eff_start_date','tgt': 'risk_inception_date'},
            {'src': 'pol_eff_time',     'tgt': 'risk_start_time'},
            {'src': 'version_no',       'tgt': 'policy_version_number'},
            {'src': 'uw_flag',          'tgt': 'underwriting_review_indicator'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('TXN:' || nullif(trim(TRANSACTION_ID),''), 'TXN:')", 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID'},
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('PRODUCT:' || nullif(trim(PROD_CODE),''), 'PRODUCT:')", 'tgt': 'HUB_PRODUCT_BK__PRODUCT_PROD_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_STARPKG_POL_DTLS'
    },
    {
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't39',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_type', 'tgt': 'policy_type'},
            {'src': 'policy_upto', 'tgt': 'risk_expiry_date'},
            {'src': 'policy_from', 'tgt': 'risk_inception_date'}
        ],
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
        'model': 'stg_ws_family_dtls_bandhan',
        'alias': 't40',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plan_name', 'tgt': 'product_reference'}
        ],
        'hub_key_columns': [
            {'src_expr': 'pmasterpolicynumber', 'tgt': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_WS_FAMILY_DTLS_BANDHAN'
    },
    {
        'model': 'stg_grp_hlt_dtls',
        'alias': 't41',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_issuance_confirmation','tgt': 'policy_issuance_confirmation_indicator'},
            {'src': 'policy_period',               'tgt': 'policy_term'},
            {'src': 'policy_type',                 'tgt': 'policy_type'},
            {'src': 'expiry_date',                 'tgt': 'risk_expiry_date'},
            {'src': 'effective_date',              'tgt': 'risk_inception_date'}
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
    },
    {
        'model': 'stg_hm_hospital_master',
        'alias': 't42',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'expiry_date', 'tgt': 'risk_expiry_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid',      'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'pin_code',   'tgt': 'HUB_LOCATION_BK__PIN_CODE'},
            {'src_expr': 'hosid',      'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSPITAL_MASTER'
    }
] -%}

{%- set output_columns = [
    'risk_inception_date',
    'risk_expiry_date',
    'policy_status',
    'policy_version_number',
    'top_up_policy_indicator',
    'policy_term',
    'risk_start_time',
    'master_policy_reference',
    'policy_type',
    'short_period_end_date',
    'policy_number',
    'premium_payer_reference',
    'issue_date',
    'policy_issuance_confirmation_indicator',
    'policy_remarks',
    'policy_term_days',
    'sum_insured_total',
    'sum_insured_basis',
    'cover_note_reference',
    'cover_note_date',
    'first_year_indicator',
    'product_reference',
    'policy_reference_number',
    'additional_remarks',
    'issuing_org_unit_code',
    'application_submission_date',
    'policy_issued_indicator',
    'line_of_business',
    'issuing_channel_reference',
    'rural_sector_policy_indicator',
    'co_insurance_indicator',
    'underwriting_review_indicator',
    'risk_end_time',
    'customer_communication_text',
    'multi_year_indicator',
    'internal_tracking_number',
    'premium_calculation_period'
] -%}

{#-- coalesce_rules: precedence order transcribed from the central view's final-SELECT
     payload COALESCEs. Single-alias rules emit a bare column reference (macro behaviour).
     Same-alias collisions (central view coalesced two raw cols from one alias) are
     represented once -- see header: application_submission_date, policy_type,
     risk_expiry_date each drop one same-alias secondary raw col (macro limitation). --#}
{%- set coalesce_rules = {
    'risk_inception_date':                    ['t16', 't1', 't2', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't12', 't13', 't14', 't17', 't19', 't20', 't41', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't37', 't39', 't0', 't18', 't35', 't38'],
    'risk_expiry_date':                       ['t16', 't1', 't5', 't6', 't8', 't9', 't10', 't12', 't13', 't14', 't17', 't19', 't20', 't41', 't23', 't24', 't25', 't26', 't27', 't42', 't28', 't29', 't30', 't37', 't39', 't0', 't35', 't38'],
    'policy_status':                          ['t1', 't10', 't12', 't35'],
    'policy_version_number':                  ['t2', 't0', 't18', 't34', 't35', 't38'],
    'top_up_policy_indicator':                ['t2'],
    'policy_term':                            ['t3', 't4', 't5', 't6', 't7', 't9', 't14', 't19', 't20', 't41', 't23', 't24', 't25', 't37', 't0', 't34', 't38'],
    'risk_start_time':                        ['t4', 't5', 't6', 't7', 't19', 't0', 't34', 't38'],
    'master_policy_reference':                ['t7'],
    'policy_type':                            ['t15', 't10', 't12', 't19', 't41', 't25', 't39'],
    'short_period_end_date':                  ['t12'],
    'policy_number':                          ['t14'],
    'premium_payer_reference':                ['t11', 't17'],
    'issue_date':                             ['t33', 't17', 't35'],
    'policy_issuance_confirmation_indicator': ['t41'],
    'policy_remarks':                         ['t11', 't15', 't21', 't0'],
    'policy_term_days':                       ['t16', 't23'],
    'sum_insured_total':                      ['t16', 't24', 't25', 't0', 't34', 't35', 't38'],
    'sum_insured_basis':                      ['t15', 't24'],
    'cover_note_reference':                   ['t31', 't34', 't35'],
    'cover_note_date':                        ['t31', 't34', 't35'],
    'first_year_indicator':                   ['t32'],
    'product_reference':                      ['t11', 't15', 't16', 't40'],
    'policy_reference_number':                ['t11', 't15', 't35', 't36'],
    'additional_remarks':                     ['t15', 't18', 't34'],
    'issuing_org_unit_code':                  ['t11', 't16'],
    'application_submission_date':            ['t33'],
    'policy_issued_indicator':                ['t33'],
    'line_of_business':                       ['t16'],
    'issuing_channel_reference':              ['t16'],
    'rural_sector_policy_indicator':          ['t16', 't35'],
    'co_insurance_indicator':                 ['t16', 't35'],
    'underwriting_review_indicator':          ['t38'],
    'risk_end_time':                          ['t0'],
    'customer_communication_text':            ['t0'],
    'multi_year_indicator':                   ['t34'],
    'internal_tracking_number':               ['t34'],
    'premium_calculation_period':             ['t34']
} %}

{#-- hub_keys: transcribed VERBATIM from the central view's final SELECT.
     Family 1 = merged-spine BKs (coalesce over alias.tgt). Family 2 = auxiliary
     per-source BKs (single alias.tgt, name prefixed TN__). Order preserved. --#}
{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 'coalesce(t24.HUB_AGREEMENT_BK__DEAL_ID, t42.HUB_AGREEMENT_BK__HOSID)'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t2.HUB_ASSESSMENT_BK__SCRUTINY_NO, t4.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t5.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t6.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t7.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t9.HUB_ASSESSMENT_BK__SCRUTINY_NO, t14.HUB_ASSESSMENT_BK__SCRUTINY_NO, t16.HUB_ASSESSMENT_BK__SCRUTINY_NO, t19.HUB_ASSESSMENT_BK__SCRUTINY_NO, t24.HUB_ASSESSMENT_BK__SCRUTINY_NO, t36.HUB_ASSESSMENT_BK__CONTRACT_ID_CLAIM_ID_RISK_ID, t41.HUB_ASSESSMENT_BK__SCRUTINY_NO)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t9.HUB_CLAIM_BK__REFERENCE_ID, t26.HUB_CLAIM_BK__CLAIM_ID, t27.HUB_CLAIM_BK__CLID, t29.HUB_CLAIM_BK__CLAIM_ID, t36.HUB_CLAIM_BK__CLAIM_ID, t39.HUB_CLAIM_BK__BJAZ_CLAIM_ID)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 't25.HUB_COVERAGE_BK__COVER_CODE'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t1.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t4.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t5.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t6.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t9.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t10.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t13.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t14.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t17.HUB_DISTRIBUTION_CHANNEL_BK__PARTNERID, t19.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t20.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t23.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t24.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t25.HUB_DISTRIBUTION_CHANNEL_BK__BUSINESS_SOURCE, t27.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t28.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t30.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t33.HUB_DISTRIBUTION_CHANNEL_BK__USER_TRANS_KEY_NO, t37.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t39.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t42.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t10.HUB_DOCUMENT_BK__CARD_NO, t13.HUB_DOCUMENT_BK__MEDICAL_REPORT, t30.HUB_DOCUMENT_BK__MEDICAL_REPORT, t37.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t4.HUB_FINANCIAL_ACCOUNT_BK__MLAC_EMI_PC_LOAN_ACCOUNT_NO, t5.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t6.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t7.HUB_FINANCIAL_ACCOUNT_BK__PLC_LOAN_ACC_NO, t19.HUB_FINANCIAL_ACCOUNT_BK__LMS_NO, t20.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER, t23.HUB_FINANCIAL_ACCOUNT_BK__S_ACCOUNT_NUMBER, t24.HUB_FINANCIAL_ACCOUNT_BK__LOAN_ACCNO, t27.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO, t28.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO)'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t24.HUB_FINANCIAL_TRANSACTION_BK__PTRANSACTION_ID, t27.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t34.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID, t38.HUB_FINANCIAL_TRANSACTION_BK__TXN_TRANSACTION_ID, t39.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 'coalesce(t1.HUB_LOCATION_BK__CHILD_LOC_CODE, t9.HUB_LOCATION_BK__LOCATION_CODE, t33.HUB_LOCATION_BK__ADDRESS_1_ADDRESS_2_PINCODE, t42.HUB_LOCATION_BK__PIN_CODE)'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t27.HUB_LOSS_EVENT_BK__CLAIM_NO, t39.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t4.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t5.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t6.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t7.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t14.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT, t19.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT, t34.HUB_ORG_UNIT_BK__DEPARTMENT_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t1.HUB_PARTY_BK__USER_ID, t8.HUB_PARTY_BK__EMP_CODE, t9.HUB_PARTY_BK__CUSTOMER_ID, t13.HUB_PARTY_BK__MEMBER_NO, t20.HUB_PARTY_BK__USER_ID, t22.HUB_PARTY_BK__PART_ID, t23.HUB_PARTY_BK__CLIENT_ID, t25.HUB_PARTY_BK__PART_ID, t26.HUB_PARTY_BK__LDR_PID, t27.HUB_PARTY_BK__HOSPITAL_ID, t28.HUB_PARTY_BK__MEMBER_ID, t30.HUB_PARTY_BK__MEMBER_NO, t37.HUB_PARTY_BK__MEMBER_NO, t42.HUB_PARTY_BK__HOSID)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t27.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t39.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__CONTRACT_ID, t2.HUB_POLICY_BK__CONTRACT_ID, t3.HUB_POLICY_BK__BASE_POLICY_REF, t4.HUB_POLICY_BK__POL_SERIAL_NO, t5.HUB_POLICY_BK__POL_SERIAL_NO, t6.HUB_POLICY_BK__POL_SERIAL_NO, t7.HUB_POLICY_BK__POL_SERIAL_NO, t8.HUB_POLICY_BK__POLICY_NO, t9.HUB_POLICY_BK__POLICY_REF, t10.HUB_POLICY_BK__POLICY_REF, t11.HUB_POLICY_BK__POLICY_REF, t12.HUB_POLICY_BK__POLICY_REF, t13.HUB_POLICY_BK__CONTRACT_ID, t14.HUB_POLICY_BK__POLICY_REF, t15.HUB_POLICY_BK__POLICY_NO, t16.HUB_POLICY_BK__CONTRACT_ID, t17.HUB_POLICY_BK__PMASTERPOLICYNUMBER, t18.HUB_POLICY_BK__CONTRACT_ID, t19.HUB_POLICY_BK__REFERENCE_ID, t20.HUB_POLICY_BK__MASTER_POLICY_NO, t21.HUB_POLICY_BK__REG_NO, t22.HUB_POLICY_BK__CONTRACT_ID, t23.HUB_POLICY_BK__REFERENCE_ID, t24.HUB_POLICY_BK__POLICY_REF, t25.HUB_POLICY_BK__CONTRACT_ID, t26.HUB_POLICY_BK__POLICY_REF, t27.HUB_POLICY_BK__POLICY, t28.HUB_POLICY_BK__CONTRACT_ID, t29.HUB_POLICY_BK__POLICY_NUMBER, t30.HUB_POLICY_BK__CONTRACT_ID, t31.HUB_POLICY_BK__CONTRACT_ID, t32.HUB_POLICY_BK__POLICY_REF, t33.HUB_POLICY_BK__POLICY_REF, t34.HUB_POLICY_BK__CONTRACT_ID, t35.HUB_POLICY_BK__CONTRACT_ID, t36.HUB_POLICY_BK__CONTRACT_ID, t37.HUB_POLICY_BK__CONTRACT_ID, t38.HUB_POLICY_BK__CONTRACT_ID, t39.HUB_POLICY_BK__POLICY_NO, t40.HUB_POLICY_BK__PMASTERPOLICYNUMBER)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t3.HUB_PRODUCT_BK__PRODUCT_CODE, t4.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t5.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t6.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t7.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t11.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t14.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t19.HUB_PRODUCT_BK__PRODUCT_CODE, t20.HUB_PRODUCT_BK__PRODUCT_CODE, t21.HUB_PRODUCT_BK__PRODUCT, t23.HUB_PRODUCT_BK__PRODUCT_CODE, t24.HUB_PRODUCT_BK__PRODUCT_CODE, t25.HUB_PRODUCT_BK__PRODUCT_4DIGIT_CODE, t26.HUB_PRODUCT_BK__PROD_CD, t28.HUB_PRODUCT_BK__PRODUCT_CODE, t34.HUB_PRODUCT_BK__PRODUCT_PRODUCT_4DIGIT_CODE, t35.HUB_PRODUCT_BK__PRODUCT_PRODUCT_CODE, t38.HUB_PRODUCT_BK__PRODUCT_PROD_CODE, t41.HUB_PRODUCT_BK__PRODUCT)'},
    {'name': 'HUB_PROPOSAL_BK', 'expr': 'coalesce(t15.HUB_PROPOSAL_BK__SCRUTINY_NO, t23.HUB_PROPOSAL_BK__BA_LEAD_NO, t25.HUB_PROPOSAL_BK__QUOTE_REF_NO, t41.HUB_PROPOSAL_BK__QUOTE_REF_NO)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 'coalesce(t12.HUB_QUOTE_BK__QUOTE_REF, t15.HUB_QUOTE_BK__QUOTATION_NO, t16.HUB_QUOTE_BK__QUOTATION_NO, t21.HUB_QUOTE_BK__QUOTE_SUB_NO, t25.HUB_QUOTE_BK__QUOTE_REF_NO, t41.HUB_QUOTE_BK__QUOTE_SUB_NO)'},
    {'name': 'HUB_REINSURANCE_TREATY_BK', 'expr': 't19.HUB_REINSURANCE_TREATY_BK__RE_INSU'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t0.HUB_RISK_OBJECT_BK__LOANACC_LOAN_ACC_NUMBER, t4.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t6.HUB_RISK_OBJECT_BK__MD_SEQ_NO, t13.HUB_RISK_OBJECT_BK__MEMBER_NO, t33.HUB_RISK_OBJECT_BK__CUSTID_CUST_ID)'},
    {'name': 'T4__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't4.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T4__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't4.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T4__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't4.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T5__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't5.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T5__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't5.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T5__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't5.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T6__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't6.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T6__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't6.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T6__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't6.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T7__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE', 'expr': 't7.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    {'name': 'T7__HUB_PARTY_BK__PD_IMD_RM_E_CODE', 'expr': 't7.HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
    {'name': 'T7__HUB_PARTY_BK__PD_PREMIUM_PAYER_ID', 'expr': 't7.HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
    {'name': 'T9__HUB_PRODUCT_BK__PLAN_ID', 'expr': 't9.HUB_PRODUCT_BK__PLAN_ID'},
    {'name': 'T9__HUB_PRODUCT_BK__PRODUCT_CODE', 'expr': 't9.HUB_PRODUCT_BK__PRODUCT_CODE'},
    {'name': 'T14__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't14.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T14__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't14.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T14__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't14.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T14__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't14.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T14__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't14.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T15__HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN', 'expr': 't15.HUB_LOCATION_BK__ADDRESS_LINE1_CORP_CITY_CORP_PIN'},
    {'name': 'T15__HUB_LOCATION_BK__PH_ADDRESS', 'expr': 't15.HUB_LOCATION_BK__PH_ADDRESS'},
    {'name': 'T15__HUB_LOCATION_BK__PP_ADDRESS', 'expr': 't15.HUB_LOCATION_BK__PP_ADDRESS'},
    {'name': 'T15__HUB_PARTY_BK__EMP_RM_CODE', 'expr': 't15.HUB_PARTY_BK__EMP_RM_CODE'},
    {'name': 'T15__HUB_PARTY_BK__CORPORATE_ID', 'expr': 't15.HUB_PARTY_BK__CORPORATE_ID'},
    {'name': 'T15__HUB_PARTY_BK__IMD_CODE', 'expr': 't15.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T15__HUB_PARTY_BK__PH_ID', 'expr': 't15.HUB_PARTY_BK__PH_ID'},
    {'name': 'T15__HUB_PARTY_BK__PP_ID', 'expr': 't15.HUB_PARTY_BK__PP_ID'},
    {'name': 'T15__HUB_PARTY_BK__SUBIMD_CODE', 'expr': 't15.HUB_PARTY_BK__SUBIMD_CODE'},
    {'name': 'T17__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't17.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T17__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't17.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T17__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't17.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T17__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't17.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T17__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't17.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T17__HUB_PRODUCT_BK__PLANID', 'expr': 't17.HUB_PRODUCT_BK__PLANID'},
    {'name': 'T17__HUB_PRODUCT_BK__SCHEMECODE', 'expr': 't17.HUB_PRODUCT_BK__SCHEMECODE'},
    {'name': 'T19__HUB_PARTY_BK__BAGIC_E_CODE', 'expr': 't19.HUB_PARTY_BK__BAGIC_E_CODE'},
    {'name': 'T19__HUB_PARTY_BK__BAGIC_RM_E_CODE', 'expr': 't19.HUB_PARTY_BK__BAGIC_RM_E_CODE'},
    {'name': 'T19__HUB_PARTY_BK__IMD_CODE', 'expr': 't19.HUB_PARTY_BK__IMD_CODE'},
    {'name': 'T19__HUB_PARTY_BK__SUB_IMD_CODE', 'expr': 't19.HUB_PARTY_BK__SUB_IMD_CODE'},
    {'name': 'T20__HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER', 'expr': 't20.HUB_PROPOSAL_BK__KGC_PROPOSAL_NUMBER'},
    {'name': 'T20__HUB_PROPOSAL_BK__REFERENCE_ID', 'expr': 't20.HUB_PROPOSAL_BK__REFERENCE_ID'},
    {'name': 'T24__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't24.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T24__HUB_ORG_UNIT_BK__DEPT_CODE', 'expr': 't24.HUB_ORG_UNIT_BK__DEPT_CODE'},
    {'name': 'T25__HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT', 'expr': 't25.HUB_ORG_UNIT_BK__COMPANY_ORG_UNIT'},
    {'name': 'T25__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't25.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T27__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't27.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T27__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't27.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T27__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't27.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T27__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't27.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T27__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't27.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T29__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't29.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T29__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't29.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T29__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't29.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T29__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't29.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T29__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't29.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T33__HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME', 'expr': 't33.HUB_PARTY_BK__POLICY_REF_NOMINEE_NOMINEENAME'},
    {'name': 'T33__HUB_PARTY_BK__CUST_ID', 'expr': 't33.HUB_PARTY_BK__CUST_ID'},
    {'name': 'T34__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't34.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T34__HUB_LOCATION_BK__PREV_INSURER_ADD', 'expr': 't34.HUB_LOCATION_BK__PREV_INSURER_ADD'},
    {'name': 'T35__HUB_LOCATION_BK__ADDRESS_CITY_REGION', 'expr': 't35.HUB_LOCATION_BK__ADDRESS_CITY_REGION'},
    {'name': 'T35__HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE', 'expr': 't35.HUB_LOCATION_BK__INSURED_ADDRESS_PINCODE'},
    {'name': 'T35__HUB_LOCATION_BK__MAILING_PINCODE', 'expr': 't35.HUB_LOCATION_BK__MAILING_PINCODE'},
    {'name': 'T35__HUB_ORG_UNIT_BK__BRANCH_CODE', 'expr': 't35.HUB_ORG_UNIT_BK__BRANCH_CODE'},
    {'name': 'T35__HUB_ORG_UNIT_BK__DEPARTMENT_CODE', 'expr': 't35.HUB_ORG_UNIT_BK__DEPARTMENT_CODE'},
    {'name': 'T35__HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME', 'expr': 't35.HUB_PARTY_BK__CONTRACT_ID_INSURED_INSURED_NAME'},
    {'name': 'T35__HUB_PARTY_BK__PARTID_PART_ID', 'expr': 't35.HUB_PARTY_BK__PARTID_PART_ID'},
    {'name': 'T39__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't39.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T39__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't39.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T39__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't39.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T39__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't39.HUB_PARTY_BK__HOSPITAL_CODE'},
    {'name': 'T41__HUB_ORG_UNIT_BK__BRANCH', 'expr': 't41.HUB_ORG_UNIT_BK__BRANCH'},
    {'name': 'T41__HUB_ORG_UNIT_BK__DEPARTMENT', 'expr': 't41.HUB_ORG_UNIT_BK__DEPARTMENT'},
    {'name': 'T41__HUB_POLICY_BK__POLICY_NO', 'expr': 't41.HUB_POLICY_BK__POLICY_NO'},
    {'name': 'T41__HUB_POLICY_BK__PREV_POL_REF', 'expr': 't41.HUB_POLICY_BK__PREV_POL_REF'},
    {'name': 'T41__HUB_POLICY_BK__REG_NO', 'expr': 't41.HUB_POLICY_BK__REG_NO'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_policy_header'
) }}
