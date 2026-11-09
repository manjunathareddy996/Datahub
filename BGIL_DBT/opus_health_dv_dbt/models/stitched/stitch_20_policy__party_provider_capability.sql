/* RESHAPED (Option C), ONE STITCH PER SATELLITE, from hcon4 central view 20.
   Batch task 7.1 -- applies the pilot procedure (see stitch_01_policy__policy_header.sql).

   spine hub / grain : HUB_POLICY  (unique_key='parent_bk')
   target_sat        : sat_party_provider_capability
   payload           : 8 output column(s), this satellite's stage hashdiff payload only.
   hub_keys          : the FULL final-SELECT hub-key set of the central view (18), verbatim,
                       so downstream hub/stage layers keep resolving every HUB_*_BK column.
   key_column rule   : each source's HUB_POLICY_BK__* column (spine-hub grain key).
   GRAIN DEVIATIONS (source has no HUB_POLICY key; real join key used, kept so hub_keys exprs resolve):
       t7 (stg_hm_hospital_master) key_column=HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID
       t8 (stg_hm_hospital_master_extn) key_column=HUB_AGREEMENT_BK__HOSID
       t9 (stg_hm_hosp_master_extn1) key_column=HUB_AGREEMENT_BK__HOSID
   SAME-ALIAS DROPS (macro emits one column per alias per attr; secondary raw col dropped):
       available_indicator: kept t8.ambulance; dropped biochemistry, blood_bank, bronchoscopy_lab, cath_lab, chemotherapy_unit, clinic_pathology, cobalt_unit, cr_card_accepted, ct_scan, dialysis_unit, dsa, ecg, echo, eeg, emergency, emg, gamma_knife, hematology, holter, inhouse_pharmacy, isolation_wards, lasers, lr_accelerator, mri, pft_spirometry, phototherapy, physiotherapy, rad_imm_assay_ria, tread_mill_test, ultrasound, x_knife, x_ray
       available_indicator: kept t9.biomedwaste; dropped boyleappr, burn, cardiology, centroxy, centrsteril, codingproc, criticalcare, daycare, dental, dermatology, diagcenter, diplomatraining, dnbtraining, docavailblend, docavailmbbs, docavailmdms, docavailmedicine, endocrinology, ent, firesafety, gastroentrology, generalmedicine, generalsurgery, genitourinary, icd10, incubator, infectiousdisease, infectnctrl, laminarflow, laparoscopicsurgery, medicalaudit, medicalestcov, medicalrecord, nephrology, neurology, notraining, nurseavailanm, nurseavailblend, nurseavailreg, nursingsch, obsgynecology, oncology, onlinehospref, opthamology, orthopedics, pediatric, plasticsurgery, portableecg, portablexray, powerbkup, pulmonology, rheumatology, steriarea, trauma, ultrasoudreg, wellcenter
       capacity: kept t8.deluxe_beds; dropped general_ward_beds, icu_beds, single_ac_beds, single_nonac_beds, total_beds
       capacity: kept t9.nicubeds; dropped recoveryrooms, semitwin, suit, tripplesharing
       facility_count: kept t9.nurse_no_icu; dropped tot_mbbs_doct, tot_no_doct, tot_no_nurse, tot_no_surgen, visit_conslnt
       accreditation_indicator: kept t9.fdapharma; dropped hota, iphs, iso, jci, mtp, nabhcertified, nabl, noaccr, pndt
   SOURCES OMITTED   : none.
   merge order       : R8 precedence (v2 > legacy > delta3) preserved from the central view COALESCE order.
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hcp_dt_mem',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'hcp_seqno', 'tgt': 'HUB_COVERAGE_BK__HCP_SEQNO'},
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_DT_MEM'
    },
    {
        'model': 'stg_hcp_prod_8432_ecp_loader',
        'alias': 't1',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'pd_scrutiny_number', 'tgt': 'HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER'},
            {'src_expr': 'pd_partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID'},
            {'src_expr': 'pd_bank_ref_no1_lac_sac', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC'},
            {'src_expr': 'pd_location_code', 'tgt': 'HUB_ORG_UNIT_BK__PD_LOCATION_CODE'},
            {'src_expr': 'pd_bagic_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
            {'src_expr': 'pd_imd_rm_e_code', 'tgt': 'HUB_PARTY_BK__PD_IMD_RM_E_CODE'},
            {'src_expr': 'pd_premium_payer_id', 'tgt': 'HUB_PARTY_BK__PD_PREMIUM_PAYER_ID'},
            {'src_expr': 'pol_serial_no', 'tgt': 'HUB_POLICY_BK__POL_SERIAL_NO'},
            {'src_expr': 'pd_product_code', 'tgt': 'HUB_PRODUCT_BK__PD_PRODUCT_CODE'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_HCP_PROD_8432_ECP_LOADER'
    },
    {
        'model': 'stg_hcp_prod_8433_fhc_loader',
        'alias': 't2',
        'key_column': 'HUB_POLICY_BK__POL_SERIAL_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
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
        'model': 'stg_card_dtls',
        'alias': 't3',
        'key_column': 'HUB_POLICY_BK__POLICY_REF',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'card_no', 'tgt': 'HUB_DOCUMENT_BK__CARD_NO'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_CARD_DTLS'
    },
    {
        'model': 'stg_gmc_bases_extn',
        'alias': 't4',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(contract_id),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_GMC_BASES_EXTN'
    },
    {
        'model': 'stg_hc_part_extn',
        'alias': 't5',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'hospital_detail', 'tgt': 'facility_name'}
        ],
        'hub_key_columns': [
            {'src_expr': 'part_id', 'tgt': 'HUB_PARTY_BK__PART_ID'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_ws_family_dtls_bandhan',
        'alias': 't6',
        'key_column': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER',
        'ldts_column': 'inc_job_updated_at',
        'columns': [],
        'hub_key_columns': [
            {'src_expr': 'pmasterpolicynumber', 'tgt': 'HUB_POLICY_BK__PMASTERPOLICYNUMBER'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_WS_FAMILY_DTLS_BANDHAN'
    },
    {
        'model': 'stg_hm_hospital_master',
        'alias': 't7',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'hosp_speciality', 'tgt': 'facility_name'},
            {'src': 'diagno_yn', 'tgt': 'available_indicator'},
            {'src': 'hosp_spec_type', 'tgt': 'facility_category'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'pin_code', 'tgt': 'HUB_LOCATION_BK__PIN_CODE'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSPITAL_MASTER'
    },
    {
        'model': 'stg_hm_hospital_master_extn',
        'alias': 't8',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'ambulance', 'tgt': 'available_indicator'},
            {'src': 'deluxe_beds', 'tgt': 'capacity'},
            {'src': 'no_oprn_theatres', 'tgt': 'facility_count'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'distribution_partner', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSPITAL_MASTER_EXTN'
    },
    {
        'model': 'stg_hm_hosp_master_extn1',
        'alias': 't9',
        'key_column': 'HUB_AGREEMENT_BK__HOSID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'biomedwaste', 'tgt': 'available_indicator'},
            {'src': 'nicubeds', 'tgt': 'capacity'},
            {'src': 'nurse_no_icu', 'tgt': 'facility_count'},
            {'src': 'fdapharma', 'tgt': 'accreditation_indicator'},
            {'src': 'operatinghrs', 'tgt': 'capability_remarks'},
            {'src': 'stat_lvl_nqas', 'tgt': 'accreditation_reference'}
        ],
        'hub_key_columns': [
            {'src_expr': 'hosid', 'tgt': 'HUB_AGREEMENT_BK__HOSID'},
            {'src_expr': 'hosid', 'tgt': 'HUB_PARTY_BK__HOSID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HOSP_MASTER_EXTN1'
    }
] -%}

{%- set output_columns = [
    'facility_name',
    'available_indicator',
    'facility_category',
    'capacity',
    'facility_count',
    'accreditation_indicator',
    'capability_remarks',
    'accreditation_reference'
] -%}

{%- set coalesce_rules = {
    'facility_name': ['t5', 't7'],
    'available_indicator': ['t7', 't8', 't9'],
    'facility_category': ['t7'],
    'capacity': ['t8', 't9'],
    'facility_count': ['t8', 't9'],
    'accreditation_indicator': ['t9'],
    'capability_remarks': ['t9'],
    'accreditation_reference': ['t9']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 'coalesce(t7.HUB_AGREEMENT_BK__HOSID, t8.HUB_AGREEMENT_BK__HOSID, t9.HUB_AGREEMENT_BK__HOSID)'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t1.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER, t2.HUB_ASSESSMENT_BK__PD_SCRUTINY_NUMBER)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 't0.HUB_COVERAGE_BK__HCP_SEQNO'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t1.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t2.HUB_DISTRIBUTION_CHANNEL_BK__PD_PARTNER_ID, t3.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t7.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t8.HUB_DISTRIBUTION_CHANNEL_BK__DISTRIBUTION_PARTNER)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 't3.HUB_DOCUMENT_BK__CARD_NO'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 'coalesce(t1.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC, t2.HUB_FINANCIAL_ACCOUNT_BK__PD_BANK_REF_NO1_LAC_SAC)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't7.HUB_LOCATION_BK__PIN_CODE'},
    {'name': 'HUB_ORG_UNIT_BK', 'expr': 'coalesce(t1.HUB_ORG_UNIT_BK__PD_LOCATION_CODE, t2.HUB_ORG_UNIT_BK__PD_LOCATION_CODE)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t0.HUB_PARTY_BK__PART_ID, t5.HUB_PARTY_BK__PART_ID, t7.HUB_PARTY_BK__HOSID, t8.HUB_PARTY_BK__HOSID, t9.HUB_PARTY_BK__HOSID)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__POL_SERIAL_NO, t2.HUB_POLICY_BK__POL_SERIAL_NO, t3.HUB_POLICY_BK__POLICY_REF, t4.HUB_POLICY_BK__CONTRACT_ID, t5.HUB_POLICY_BK__CONTRACT_ID, t6.HUB_POLICY_BK__PMASTERPOLICYNUMBER)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t1.HUB_PRODUCT_BK__PD_PRODUCT_CODE, t2.HUB_PRODUCT_BK__PD_PRODUCT_CODE)'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 't2.HUB_RISK_OBJECT_BK__MD_SEQ_NO'},
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
    target_sat='sat_party_provider_capability'
) }}
