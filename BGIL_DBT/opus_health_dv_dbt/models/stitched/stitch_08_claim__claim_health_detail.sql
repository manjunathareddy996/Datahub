/* RESHAPED (Option C) from the hcon4 central view into the partner thin form.
   Batch task 5.1. Procedure: the stitch_01 pilot's 9-step REUSABLE PROCEDURE.
   spine hub / grain : HUB_CLAIM  (unique_key='parent_bk')
   target_sat        : sat_claim_health_detail
   GRAIN DEVIATIONS (source has no spine-hub key; keyed on its real join col):
     - t16 (stg_ec_mem_dtls_extn): no HUB_CLAIM key; key_column=HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID (real join key)
     - t17 (stg_grp_hlt_maternity_dtls): no HUB_CLAIM key; key_column=HUB_POLICY_BK__REG_NO (real join key)
     - t18 (stg_hm_gmc_ahc): no HUB_CLAIM key; key_column=HUB_POLICY_BK__POLICY_NO (real join key)
     - t19 (stg_sh_mem_dtls_extn): no HUB_CLAIM key; key_column=HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID (real join key)
   SAME-ALIAS PAYLOAD DROPS (macro emits one col per alias per tgt; secondary dropped):
     - icd_code: kept t8.icd_code, dropped-secondary t8.icd_descri
     - icu_rent_amount: kept t7.criti_unit_room_rent_per_day, dropped-secondary t7.criti_unit_room_rent_per_day_h
     - room_category: kept t7.availed_room_category, dropped-secondary t7.availed_room_category_h
     - room_category: kept t7.availed_room_category, dropped-secondary t7.room_category
     - room_rent_amount: kept t0.availed_room_rent_per_day, dropped-secondary t0.room_rent
     - room_rent_per_day: kept t7.availed_room_rent_per_day, dropped-secondary t7.availed_room_rent_per_day_h
*/
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_hm_bill_detail',
        'alias': 't0',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'eligible_room_category', 'tgt': 'eligible_room_category'},
            {'src': 'eligible_room_rent', 'tgt': 'eligible_room_rent'},
            {'src': 'criti_unit_room_rent_per_day', 'tgt': 'icu_rent_amount'},
            {'src': 'ip_no', 'tgt': 'ipd_number'},
            {'src': 'availed_room_category', 'tgt': 'room_category'},
            {'src': 'grade', 'tgt': 'room_grade'},
            {'src': 'availed_room_rent_per_day', 'tgt': 'room_rent_amount'},
            {'src': 'room_rent_perc', 'tgt': 'room_rent_eligibility_percentage'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_BILL_DETAIL'
    },
    {
        'model': 'stg_hm_bill_detail_ocr',
        'alias': 't1',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'availed_room_rent_per_day', 'tgt': 'availed_room_rent_per_day'},
            {'src': 'eligible_room_category', 'tgt': 'eligible_room_category'},
            {'src': 'eligible_room_rent', 'tgt': 'eligible_room_rent'},
            {'src': 'criti_unit_room_rent_per_day', 'tgt': 'icu_rent_amount'},
            {'src': 'ip_no', 'tgt': 'ipd_number'},
            {'src': 'discount', 'tgt': 'network_discount_amount'},
            {'src': 'availed_room_category', 'tgt': 'room_category'},
            {'src': 'room_rent', 'tgt': 'room_rent_amount'},
            {'src': 'room_rent_perc', 'tgt': 'room_rent_eligibility_percentage'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_BILL_DETAIL_OCR'
    },
    {
        'model': 'stg_hm_cashless_inward',
        'alias': 't2',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'cashless_in_no', 'tgt': 'cashless_authorisation_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'hospital_id', 'tgt': 'HUB_PARTY_BK__HOSPITAL_ID'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_CASHLESS_INWARD'
    },
    {
        'model': 'stg_hm_coinsu_clm_dtls',
        'alias': 't3',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'date_admission', 'tgt': 'admission_date'},
            {'src': 'ailment', 'tgt': 'ailment_description'},
            {'src': 'co_paymnt_deduction', 'tgt': 'co_pay_amount'},
            {'src': 'buffer_utilised_amt', 'tgt': 'corporate_buffer_utilised_amount'},
            {'src': 'final_diagnosis', 'tgt': 'diagnosis_code'},
            {'src': 'reasons', 'tgt': 'disallowance_reason'},
            {'src': 'not_payable_exp', 'tgt': 'disallowed_amount'},
            {'src': 'date_of_discharge', 'tgt': 'discharge_date'},
            {'src': 'disease_catagory', 'tgt': 'disease_category'},
            {'src': 'final_bill_amt', 'tgt': 'final_bill_amount'},
            {'src': 'provider_no', 'tgt': 'hospital_reference'},
            {'src': 'icd_code', 'tgt': 'icd_code'},
            {'src': 'major_diseases', 'tgt': 'major_disease_category'},
            {'src': 'network', 'tgt': 'network_hospital_indicator'},
            {'src': 'not_covered_amt', 'tgt': 'not_covered_amount'},
            {'src': 'non_payable_def_amt', 'tgt': 'other_deduction_amount'},
            {'src': 'primary_classification', 'tgt': 'primary_diagnosis_classification'},
            {'src': 'primary_proc', 'tgt': 'procedure_code'},
            {'src': 'si_exhausted_amt', 'tgt': 'sum_insured_exhausted_amount'},
            {'src': 'level_of_care', 'tgt': 'treatment_type'}
        ],
        'hub_key_columns': [
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'ldr_pid', 'tgt': 'HUB_PARTY_BK__LDR_PID'},
            {'src_expr': 'policy_ref', 'tgt': 'HUB_POLICY_BK__POLICY_REF'},
            {'src_expr': 'prod_cd', 'tgt': 'HUB_PRODUCT_BK__PROD_CD'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_COINSU_CLM_DTLS'
    },
    {
        'model': 'stg_hm_doctor_assess',
        'alias': 't4',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'package_charge', 'tgt': 'actual_package_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': 'docasess_id', 'tgt': 'HUB_ASSESSMENT_BK__DOCASESS_ID'},
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_DOCTOR_ASSESS'
    },
    {
        'model': 'stg_hm_doctor_multi_assess',
        'alias': 't5',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'package_charge', 'tgt': 'actual_package_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': 'docasess_id', 'tgt': 'HUB_ASSESSMENT_BK__DOCASESS_ID'},
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'cover_section', 'tgt': 'HUB_COVERAGE_BK__COVER_SECTION'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_DOCTOR_MULTI_ASSESS'
    },
    {
        'model': 'stg_hm_gpa_bill_dtls',
        'alias': 't6',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'hosp_doa', 'tgt': 'admission_date'},
            {'src': 'hosp_dod', 'tgt': 'discharge_date'},
            {'src': 'hosp_icu_elgiamt', 'tgt': 'eligible_icu_rent_amount'},
            {'src': 'hosp_norm_elgiamt', 'tgt': 'eligible_room_rent'},
            {'src': 'hosp_icu_days', 'tgt': 'icu_days'},
            {'src': 'hosp_icu_room_amt', 'tgt': 'icu_rent_amount'},
            {'src': 'hosp_norm_room', 'tgt': 'normal_room_days'},
            {'src': 'hosp_normal_room_amt', 'tgt': 'room_rent_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_GPA_BILL_DTLS'
    },
    {
        'model': 'stg_hm_hcm_extract',
        'alias': 't7',
        'key_column': 'HUB_CLAIM_BK__CLID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'package_charges', 'tgt': 'actual_package_amount'},
            {'src': 'actual_doa', 'tgt': 'admission_date'},
            {'src': 'ip_type', 'tgt': 'admission_type'},
            {'src': 'diagnosis_detail', 'tgt': 'ailment_description'},
            {'src': 'ambulance', 'tgt': 'ambulance_charges'},
            {'src': 'cardiology', 'tgt': 'cardiology_charges_amount'},
            {'src': 'co_payment', 'tgt': 'co_pay_amount'},
            {'src': 'corporate_buffer_amt', 'tgt': 'corporate_buffer_amount'},
            {'src': 'final_diagnosis', 'tgt': 'diagnosis_code'},
            {'src': 'hospital_disallow_amt_reason', 'tgt': 'disallowance_reason'},
            {'src': 'hospital_disallowed_amt', 'tgt': 'disallowed_amount'},
            {'src': 'actual_dod', 'tgt': 'discharge_date'},
            {'src': 'disease_category', 'tgt': 'disease_category'},
            {'src': 'doctor_charges', 'tgt': 'doctor_charges_amount'},
            {'src': 'eligible_room_category', 'tgt': 'eligible_room_category'},
            {'src': 'eligible_room_rent', 'tgt': 'eligible_room_rent'},
            {'src': 'equipement', 'tgt': 'equipment_charges_amount'},
            {'src': 'expected_dod', 'tgt': 'expected_discharge_date'},
            {'src': 'total_bill', 'tgt': 'final_bill_amount'},
            {'src': 'icd_code', 'tgt': 'icd_code'},
            {'src': 'icu_charges', 'tgt': 'icu_charges_amount'},
            {'src': 'criti_unit_room_rent_per_day', 'tgt': 'icu_rent_amount'},
            {'src': 'ip_no', 'tgt': 'ipd_number'},
            {'src': 'implant_charges', 'tgt': 'implant_cost'},
            {'src': 'insured_disallow_amt_reason', 'tgt': 'insured_disallowance_reason'},
            {'src': 'insured_disallowed_amt', 'tgt': 'insured_disallowed_amount'},
            {'src': 'miscellaneous', 'tgt': 'miscellaneous_charges_amount'},
            {'src': 'neo_natal_charges', 'tgt': 'neonatal_charges_amount'},
            {'src': 'discount', 'tgt': 'network_discount_amount'},
            {'src': 'non_medical', 'tgt': 'non_medical_charges_amount'},
            {'src': 'non_network_co_pay', 'tgt': 'non_network_co_pay_amount'},
            {'src': 'nursing_charges', 'tgt': 'nursing_charges'},
            {'src': 'ot_charges', 'tgt': 'ot_charges'},
            {'src': 'other_deduction', 'tgt': 'other_deduction_amount'},
            {'src': 'pathology', 'tgt': 'pathology_charges_amount'},
            {'src': 'pharmacy', 'tgt': 'pharmacy_amount'},
            {'src': 'post_hosp_charges', 'tgt': 'post_hospitalisation_amount'},
            {'src': 'pre_hosp_charges', 'tgt': 'pre_hospitalisation_amount'},
            {'src': 'dig_procedure', 'tgt': 'procedure_description'},
            {'src': 'provisional_diagnosis', 'tgt': 'provisional_diagnosis'},
            {'src': 'radiology', 'tgt': 'radiology_charges_amount'},
            {'src': 'availed_room_category', 'tgt': 'room_category'},
            {'src': 'room_charges', 'tgt': 'room_rent_amount'},
            {'src': 'room_rent_diff_co_pay', 'tgt': 'room_rent_difference_co_pay_amount'},
            {'src': 'availed_room_rent_per_day', 'tgt': 'room_rent_per_day'},
            {'src': 'service_charges', 'tgt': 'service_charges_amount'},
            {'src': 'surgeon_charges', 'tgt': 'surgeon_fee'},
            {'src': 'medical_or_surgical', 'tgt': 'surgery_indicator'},
            {'src': 'treatment_type', 'tgt': 'treatment_type'}
        ],
        'hub_key_columns': [
            {'src_expr': 'clid', 'tgt': 'HUB_CLAIM_BK__CLID'},
            {'src_expr': 'imd_code', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE'},
            {'src_expr': 'bank_ac_no', 'tgt': 'HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
            {'src_expr': 'utr_no', 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__UTR_NO'},
            {'src_expr': 'location_code', 'tgt': 'HUB_LOCATION_BK__LOCATION_CODE'},
            {'src_expr': 'locationcode', 'tgt': 'HUB_LOCATION_BK__LOCATIONCODE'},
            {'src_expr': 'orphan_loc', 'tgt': 'HUB_LOCATION_BK__ORPHAN_LOC'},
            {'src_expr': 'policy_location', 'tgt': 'HUB_LOCATION_BK__POLICY_LOCATION'},
            {'src_expr': 'risk_location', 'tgt': 'HUB_LOCATION_BK__RISK_LOCATION'},
            {'src_expr': 'claim_no', 'tgt': 'HUB_LOSS_EVENT_BK__CLAIM_NO'},
            {'src_expr': 'hospital_id', 'tgt': 'HUB_PARTY_BK__HOSPITAL_ID'},
            {'src_expr': 'cheque_no', 'tgt': 'HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
            {'src_expr': 'policy', 'tgt': 'HUB_POLICY_BK__POLICY'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_HCM_EXTRACT'
    },
    {
        'model': 'stg_hm_hcs_tech_assess_cov',
        'alias': 't8',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'actual_doa', 'tgt': 'admission_date'},
            {'src': 'final_diag', 'tgt': 'ailment_description'},
            {'src': 'actual_dod', 'tgt': 'discharge_date'},
            {'src': 'first_consult_date', 'tgt': 'first_consultation_date'},
            {'src': 'icd_code', 'tgt': 'icd_code'},
            {'src': 'last_consult_date', 'tgt': 'last_consultation_date'},
            {'src': 'prov_diag', 'tgt': 'provisional_diagnosis_description'},
            {'src': 'treat_dr', 'tgt': 'treating_doctor_name'},
            {'src': 'treat_type', 'tgt': 'treatment_type'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': "nullif('HEALTHCARD:' || nullif(trim(ID_CARD_NO),''), 'HEALTHCARD:')", 'tgt': 'HUB_RISK_OBJECT_BK__HEALTHCARD_ID_CARD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_HCS_TECH_ASSESS_COV'
    },
    {
        'model': 'stg_hm_inward_autoallocation',
        'alias': 't9',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'cashless_in_no', 'tgt': 'cashless_authorisation_number'}
        ],
        'hub_key_columns': [
            {'src_expr': 'allocate_id', 'tgt': 'HUB_CASE_BK__ALLOCATE_ID'},
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': 'omni_inward_no', 'tgt': 'HUB_DOCUMENT_BK__OMNI_INWARD_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_INWARD_AUTOALLOCATION'
    },
    {
        'model': 'stg_hm_preauth_enhance',
        'alias': 't10',
        'key_column': 'HUB_CLAIM_BK__CLID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'expected_dod', 'tgt': 'expected_discharge_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'enhance_ref_id', 'tgt': 'HUB_CASE_BK__ENHANCE_REF_ID'},
            {'src_expr': 'clid', 'tgt': 'HUB_CLAIM_BK__CLID'},
            {'src_expr': 'omni_inward_no', 'tgt': 'HUB_DOCUMENT_BK__OMNI_INWARD_NO'},
            {'src_expr': 'hosp_id', 'tgt': 'HUB_PARTY_BK__HOSP_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_PREAUTH_ENHANCE'
    },
    {
        'model': 'stg_hm_preauth_request',
        'alias': 't11',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'patient_admission_dt', 'tgt': 'admission_date'},
            {'src': 'patient_admission_time', 'tgt': 'admission_time'},
            {'src': 'illness_nature', 'tgt': 'ailment_description'},
            {'src': 'ailment_duration', 'tgt': 'ailment_duration_days'},
            {'src': 'attendant_contact_no', 'tgt': 'attendant_contact_number'},
            {'src': 'attendant_name', 'tgt': 'attendant_name'},
            {'src': 'clinical', 'tgt': 'clinical_findings_description'},
            {'src': 'corporate_name', 'tgt': 'corporate_group_reference'},
            {'src': 'delivery_date', 'tgt': 'delivery_date'},
            {'src': 'test_conducted', 'tgt': 'diagnostic_test_conducted_indicator'},
            {'src': 'drug_administration', 'tgt': 'drug_administration_detail'},
            {'src': 'expected_dod', 'tgt': 'expected_discharge_date'},
            {'src': 'exp_len_stay', 'tgt': 'expected_length_of_stay_days'},
            {'src': 'fam_contact_no', 'tgt': 'family_physician_contact_number'},
            {'src': 'fam_phy_yn', 'tgt': 'family_physician_indicator'},
            {'src': 'fam_phy_name', 'tgt': 'family_physician_name'},
            {'src': 'first_consulation_date', 'tgt': 'first_consultation_date'},
            {'src': 'hospitalization_type', 'tgt': 'hospitalisation_type'},
            {'src': 'icd_code', 'tgt': 'icd_code'},
            {'src': 'icu_stay', 'tgt': 'icu_stay_days'},
            {'src': 'injury_occur', 'tgt': 'injury_circumstance_description'},
            {'src': 'injury_disease', 'tgt': 'injury_or_disease_indicator'},
            {'src': 'invest_med_dtls', 'tgt': 'investigation_and_medical_management_detail'},
            {'src': 'lmp', 'tgt': 'last_menstrual_period_date'},
            {'src': 'curr_medclaim', 'tgt': 'other_health_cover_declared_indicator'},
            {'src': 'curr_comp_dtls', 'tgt': 'other_health_cover_detail'},
            {'src': 'curr_comp_name', 'tgt': 'other_insurer_name'},
            {'src': 'other_treatment', 'tgt': 'other_treatment_detail'},
            {'src': 'police_report', 'tgt': 'police_report_indicator'},
            {'src': 'provisional_diagnosis', 'tgt': 'provisional_diagnosis_description'},
            {'src': 'rta_status', 'tgt': 'road_traffic_accident_indicator'},
            {'src': 'room_type', 'tgt': 'room_category'},
            {'src': 'room_stay', 'tgt': 'room_stay_days'},
            {'src': 'surgery_name', 'tgt': 'surgery_name'},
            {'src': 'doc_contact_no', 'tgt': 'treating_doctor_contact_number'},
            {'src': 'treating_doc_name', 'tgt': 'treating_doctor_name'},
            {'src': 'line_of_treatment', 'tgt': 'treatment_type'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CLAIM_ID),'')", 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'},
            {'src_expr': "nullif('FIR:' || nullif(trim(FIR_NO),''), 'FIR:')", 'tgt': 'HUB_DOCUMENT_BK__FIR_FIR_NO'},
            {'src_expr': "nullif('OMNI_INWARD:' || nullif(trim(OMNI_INWARD_NO),''), 'OMNI_INWARD:')", 'tgt': 'HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO'},
            {'src_expr': "nullif('HEALTHCARD:' || nullif(trim(INSURED_CARD_NO),''), 'HEALTHCARD:')", 'tgt': 'HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO'},
            {'src_expr': "nullif('HEALTHCARD:' || nullif(trim(PATIENT_ID_CARD),''), 'HEALTHCARD:')", 'tgt': 'HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD'},
            {'src_expr': "nullif('HOSPID:' || nullif(trim(HOS_ID),''), 'HOSPID:')", 'tgt': 'HUB_PARTY_BK__HOSPID_HOS_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_V2_BJAZ_HM_PREAUTH_REQUEST'
    },
    {
        'model': 'stg_hm_pro_assessment',
        'alias': 't12',
        'key_column': 'HUB_CLAIM_BK__CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'tot_claimed_amt', 'tgt': 'final_bill_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': 'assess_id', 'tgt': 'HUB_ASSESSMENT_BK__ASSESS_ID'},
            {'src_expr': 'claim_id', 'tgt': 'HUB_CLAIM_BK__CLAIM_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_PRO_ASSESSMENT'
    },
    {
        'model': 'stg_remedinet_claim_details',
        'alias': 't13',
        'key_column': 'HUB_CLAIM_BK__CLAIM_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'actual_package_amount', 'tgt': 'actual_package_amount'},
            {'src': 'approved_package_amount', 'tgt': 'approved_package_amount'},
            {'src': 'preauth_no', 'tgt': 'cashless_authorisation_number'},
            {'src': 'copay_amount', 'tgt': 'co_pay_amount'},
            {'src': 'copay_type', 'tgt': 'co_pay_type'},
            {'src': 'total_bill_amount', 'tgt': 'final_bill_amount'},
            {'src': 'patient_paid_amount', 'tgt': 'patient_paid_amount'},
            {'src': 'preauth_amount', 'tgt': 'pre_authorisation_amount'},
            {'src': 'provider_remarks', 'tgt': 'pre_authorisation_remarks'},
            {'src': 'total_claimed_amount', 'tgt': 'total_claimed_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': 'remedinet_provider_code', 'tgt': 'HUB_AGREEMENT_BK__REMEDINET_PROVIDER_CODE'},
            {'src_expr': 'claim_no', 'tgt': 'HUB_CLAIM_BK__CLAIM_NO'},
            {'src_expr': 'omni_inward_no', 'tgt': 'HUB_DOCUMENT_BK__OMNI_INWARD_NO'},
            {'src_expr': 'payer_code', 'tgt': 'HUB_PARTY_BK__PAYER_CODE'},
            {'src_expr': 'remedinet_provider_code', 'tgt': 'HUB_PARTY_BK__REMEDINET_PROVIDER_CODE'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_REMEDINET_CLAIM_DETAILS'
    },
    {
        'model': 'stg_remedinet_patient_details',
        'alias': 't14',
        'key_column': 'HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'preauth_no', 'tgt': 'cashless_authorisation_number'},
            {'src': 'patient_hospital_no', 'tgt': 'ipd_number'}
        ],
        'hub_key_columns': [
            {'src_expr': "nullif('REMEDINET_REQ:' || nullif(trim(REQUESTID),''), 'REMEDINET_REQ:')", 'tgt': 'HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID'},
            {'src_expr': "md5(normalise(upper(nullif(coalesce(nullif(trim(ADDRESS1),''),'') || '|' || coalesce(nullif(trim(ADDRESS2),''),'') || '|' || coalesce(nullif(trim(ADDRESS3),''),'') || '|' || coalesce(nullif(trim(CITY),''),'') || '|' || coalesce(nullif(trim(STATE),''),'') || '|' || coalesce(nullif(trim(PIN_CODE),''),''), '|||||'))))", 'tgt': 'HUB_LOCATION_BK__ADDRESS1_ADDRESS2_ADDRESS3_CITY'},
            {'src_expr': "nullif('MEMBER:' || nullif(trim(MEMBER_NO),''), 'MEMBER:')", 'tgt': 'HUB_PARTY_BK__MEMBER_MEMBER_NO'},
            {'src_expr': "nullif('MEMBER:' || nullif(trim(MEMBER_NO),''), 'MEMBER:')", 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_DELTA3_BJAZ_REMEDINET_PATIENT_DETAILS'
    },
    {
        'model': 'stg_tpa_claim_details_ws',
        'alias': 't15',
        'key_column': 'HUB_CLAIM_BK__BJAZ_CLAIM_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'doa', 'tgt': 'admission_date'},
            {'src': 'diagnosis', 'tgt': 'ailment_description'},
            {'src': 'ambulance_charges', 'tgt': 'ambulance_charges'},
            {'src': 'anesthesia_fees', 'tgt': 'anaesthetist_fee'},
            {'src': 'pre_auth_letter_no', 'tgt': 'cashless_authorisation_number'},
            {'src': 'co_pay_amount', 'tgt': 'co_pay_amount'},
            {'src': 'consultant_charges', 'tgt': 'consultant_charges'},
            {'src': 'diagnosis_code_level1', 'tgt': 'diagnosis_code'},
            {'src': 'deduction_reason', 'tgt': 'disallowance_reason'},
            {'src': 'dod', 'tgt': 'discharge_date'},
            {'src': 'claim_amount', 'tgt': 'final_bill_amount'},
            {'src': 'icucharges', 'tgt': 'icu_charges_amount'},
            {'src': 'imaging_studies_charges', 'tgt': 'imaging_studies_charges'},
            {'src': 'investigation_charges', 'tgt': 'investigation_charges'},
            {'src': 'misc', 'tgt': 'miscellaneous_charges_amount'},
            {'src': 'nursing_fees', 'tgt': 'nursing_charges'},
            {'src': 'otcharges', 'tgt': 'ot_charges'},
            {'src': 'medicines', 'tgt': 'pharmacy_amount'},
            {'src': 'physician_fees', 'tgt': 'physician_fees'},
            {'src': 'pre_auth_amount', 'tgt': 'pre_authorisation_amount'},
            {'src': 'procedure_codes_level1', 'tgt': 'procedure_code'},
            {'src': 'procedure_description_level1', 'tgt': 'procedure_description'},
            {'src': 'room_charges', 'tgt': 'room_rent_amount'},
            {'src': 'specialist_charges', 'tgt': 'specialist_charges'},
            {'src': 'surgeon_charges', 'tgt': 'surgeon_fee'},
            {'src': 'treatment', 'tgt': 'treatment_type'}
        ],
        'hub_key_columns': [
            {'src_expr': 'bjaz_claim_id', 'tgt': 'HUB_CLAIM_BK__BJAZ_CLAIM_ID'},
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'tpa_trans_key', 'tgt': 'HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY'},
            {'src_expr': 'tpa_claim_no', 'tgt': 'HUB_LOSS_EVENT_BK__TPA_CLAIM_NO'},
            {'src_expr': 'controlling_office', 'tgt': 'HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
            {'src_expr': 'operating_office', 'tgt': 'HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
            {'src_expr': 'customer_id', 'tgt': 'HUB_PARTY_BK__CUSTOMER_ID'},
            {'src_expr': 'hospital_code', 'tgt': 'HUB_PARTY_BK__HOSPITAL_CODE'},
            {'src_expr': 'cheque_no', 'tgt': 'HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO'},
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_TPA_CLAIM_DETAILS_WS'
    },
    {
        'model': 'stg_ec_mem_dtls_extn',
        'alias': 't16',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claimed_for', 'tgt': 'ailment_description'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': 'member_no', 'tgt': 'HUB_RISK_OBJECT_BK__MEMBER_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_grp_hlt_maternity_dtls',
        'alias': 't17',
        'key_column': 'HUB_POLICY_BK__REG_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'ambulance_charges', 'tgt': 'ambulance_charges'},
            {'src': 'room_rent', 'tgt': 'room_rent_amount'}
        ],
        'hub_key_columns': [
            {'src_expr': 'reg_no', 'tgt': 'HUB_POLICY_BK__REG_NO'},
            {'src_expr': 'product', 'tgt': 'HUB_PRODUCT_BK__PRODUCT'},
            {'src_expr': 'quote_sub_no', 'tgt': 'HUB_QUOTE_BK__QUOTE_SUB_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_GRP_HLT_MATERNITY_DTLS'
    },
    {
        'model': 'stg_hm_gmc_ahc',
        'alias': 't18',
        'key_column': 'HUB_POLICY_BK__POLICY_NO',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'doa', 'tgt': 'admission_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'policy_no', 'tgt': 'HUB_POLICY_BK__POLICY_NO'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_HM_GMC_AHC'
    },
    {
        'model': 'stg_sh_mem_dtls_extn',
        'alias': 't19',
        'key_column': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'period_treatment', 'tgt': 'admission_date'}
        ],
        'hub_key_columns': [
            {'src_expr': 'partner_id', 'tgt': 'HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID'},
            {'src_expr': 'medical_report', 'tgt': 'HUB_DOCUMENT_BK__MEDICAL_REPORT'},
            {'src_expr': 'member_no', 'tgt': 'HUB_PARTY_BK__MEMBER_NO'},
            {'src_expr': 'contract_id', 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'}
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BJAZ_SH_MEM_DTLS_EXTN'
    }
] -%}

{%- set output_columns = [
    'actual_package_amount', 'admission_date', 'admission_time', 'admission_type', 'ailment_description', 'ailment_duration_days', 'ambulance_charges', 'anaesthetist_fee', 'approved_package_amount', 'attendant_contact_number', 'attendant_name', 'availed_room_rent_per_day', 'cardiology_charges_amount', 'cashless_authorisation_number', 'clinical_findings_description', 'co_pay_amount', 'co_pay_type', 'consultant_charges', 'corporate_buffer_amount', 'corporate_buffer_utilised_amount', 'corporate_group_reference', 'delivery_date', 'diagnosis_code', 'diagnostic_test_conducted_indicator', 'disallowance_reason', 'disallowed_amount', 'discharge_date', 'disease_category', 'doctor_charges_amount', 'drug_administration_detail', 'eligible_icu_rent_amount', 'eligible_room_category', 'eligible_room_rent', 'equipment_charges_amount', 'expected_discharge_date', 'expected_length_of_stay_days', 'family_physician_contact_number', 'family_physician_indicator', 'family_physician_name', 'final_bill_amount', 'first_consultation_date', 'hospital_reference', 'hospitalisation_type', 'icd_code', 'icu_charges_amount', 'icu_days', 'icu_rent_amount', 'icu_stay_days', 'ipd_number', 'imaging_studies_charges', 'implant_cost', 'injury_circumstance_description', 'injury_or_disease_indicator', 'insured_disallowance_reason', 'insured_disallowed_amount', 'investigation_and_medical_management_detail', 'investigation_charges', 'last_consultation_date', 'last_menstrual_period_date', 'major_disease_category', 'miscellaneous_charges_amount', 'neonatal_charges_amount', 'network_discount_amount', 'network_hospital_indicator', 'non_medical_charges_amount', 'non_network_co_pay_amount', 'normal_room_days', 'not_covered_amount', 'nursing_charges', 'ot_charges', 'other_deduction_amount', 'other_health_cover_declared_indicator', 'other_health_cover_detail', 'other_insurer_name', 'other_treatment_detail', 'pathology_charges_amount', 'patient_paid_amount', 'pharmacy_amount', 'physician_fees', 'police_report_indicator', 'post_hospitalisation_amount', 'pre_authorisation_amount', 'pre_authorisation_remarks', 'pre_hospitalisation_amount', 'primary_diagnosis_classification', 'procedure_code', 'procedure_description', 'provisional_diagnosis', 'provisional_diagnosis_description', 'radiology_charges_amount', 'road_traffic_accident_indicator', 'room_category', 'room_grade', 'room_rent_amount', 'room_rent_difference_co_pay_amount', 'room_rent_eligibility_percentage', 'room_rent_per_day', 'room_stay_days', 'service_charges_amount', 'specialist_charges', 'sum_insured_exhausted_amount', 'surgeon_fee', 'surgery_indicator', 'surgery_name', 'total_claimed_amount', 'treating_doctor_contact_number', 'treating_doctor_name', 'treatment_type'
] -%}

{%- set coalesce_rules = {
    'actual_package_amount': ['t4', 't5', 't7', 't13'],
    'admission_date': ['t6', 't8', 't11', 't3', 't18', 't7', 't19', 't15'],
    'admission_time': ['t11'],
    'admission_type': ['t7'],
    'ailment_description': ['t8', 't11', 't16', 't3', 't7', 't15'],
    'ailment_duration_days': ['t11'],
    'ambulance_charges': ['t17', 't7', 't15'],
    'anaesthetist_fee': ['t15'],
    'approved_package_amount': ['t13'],
    'attendant_contact_number': ['t11'],
    'attendant_name': ['t11'],
    'availed_room_rent_per_day': ['t1'],
    'cardiology_charges_amount': ['t7'],
    'cashless_authorisation_number': ['t2', 't9', 't13', 't15', 't14'],
    'clinical_findings_description': ['t11'],
    'co_pay_amount': ['t3', 't7', 't13', 't15'],
    'co_pay_type': ['t13'],
    'consultant_charges': ['t15'],
    'corporate_buffer_amount': ['t7'],
    'corporate_buffer_utilised_amount': ['t3'],
    'corporate_group_reference': ['t11'],
    'delivery_date': ['t11'],
    'diagnosis_code': ['t3', 't7', 't15'],
    'diagnostic_test_conducted_indicator': ['t11'],
    'disallowance_reason': ['t3', 't7', 't15'],
    'disallowed_amount': ['t3', 't7'],
    'discharge_date': ['t6', 't8', 't3', 't7', 't15'],
    'disease_category': ['t3', 't7'],
    'doctor_charges_amount': ['t7'],
    'drug_administration_detail': ['t11'],
    'eligible_icu_rent_amount': ['t6'],
    'eligible_room_category': ['t0', 't1', 't7'],
    'eligible_room_rent': ['t6', 't0', 't1', 't7'],
    'equipment_charges_amount': ['t7'],
    'expected_discharge_date': ['t11', 't7', 't10'],
    'expected_length_of_stay_days': ['t11'],
    'family_physician_contact_number': ['t11'],
    'family_physician_indicator': ['t11'],
    'family_physician_name': ['t11'],
    'final_bill_amount': ['t3', 't7', 't12', 't13', 't15'],
    'first_consultation_date': ['t8', 't11'],
    'hospital_reference': ['t3'],
    'hospitalisation_type': ['t11'],
    'icd_code': ['t8', 't11', 't3', 't7'],
    'icu_charges_amount': ['t7', 't15'],
    'icu_days': ['t6'],
    'icu_rent_amount': ['t6', 't0', 't1', 't7'],
    'icu_stay_days': ['t11'],
    'ipd_number': ['t0', 't1', 't7', 't14'],
    'imaging_studies_charges': ['t15'],
    'implant_cost': ['t7'],
    'injury_circumstance_description': ['t11'],
    'injury_or_disease_indicator': ['t11'],
    'insured_disallowance_reason': ['t7'],
    'insured_disallowed_amount': ['t7'],
    'investigation_and_medical_management_detail': ['t11'],
    'investigation_charges': ['t15'],
    'last_consultation_date': ['t8'],
    'last_menstrual_period_date': ['t11'],
    'major_disease_category': ['t3'],
    'miscellaneous_charges_amount': ['t7', 't15'],
    'neonatal_charges_amount': ['t7'],
    'network_discount_amount': ['t1', 't7'],
    'network_hospital_indicator': ['t3'],
    'non_medical_charges_amount': ['t7'],
    'non_network_co_pay_amount': ['t7'],
    'normal_room_days': ['t6'],
    'not_covered_amount': ['t3'],
    'nursing_charges': ['t7', 't15'],
    'ot_charges': ['t7', 't15'],
    'other_deduction_amount': ['t3', 't7'],
    'other_health_cover_declared_indicator': ['t11'],
    'other_health_cover_detail': ['t11'],
    'other_insurer_name': ['t11'],
    'other_treatment_detail': ['t11'],
    'pathology_charges_amount': ['t7'],
    'patient_paid_amount': ['t13'],
    'pharmacy_amount': ['t7', 't15'],
    'physician_fees': ['t15'],
    'police_report_indicator': ['t11'],
    'post_hospitalisation_amount': ['t7'],
    'pre_authorisation_amount': ['t13', 't15'],
    'pre_authorisation_remarks': ['t13'],
    'pre_hospitalisation_amount': ['t7'],
    'primary_diagnosis_classification': ['t3'],
    'procedure_code': ['t3', 't15'],
    'procedure_description': ['t7', 't15'],
    'provisional_diagnosis': ['t7'],
    'provisional_diagnosis_description': ['t8', 't11'],
    'radiology_charges_amount': ['t7'],
    'road_traffic_accident_indicator': ['t11'],
    'room_category': ['t11', 't0', 't1', 't7'],
    'room_grade': ['t0'],
    'room_rent_amount': ['t6', 't17', 't0', 't1', 't7', 't15'],
    'room_rent_difference_co_pay_amount': ['t7'],
    'room_rent_eligibility_percentage': ['t0', 't1'],
    'room_rent_per_day': ['t7'],
    'room_stay_days': ['t11'],
    'service_charges_amount': ['t7'],
    'specialist_charges': ['t15'],
    'sum_insured_exhausted_amount': ['t3'],
    'surgeon_fee': ['t7', 't15'],
    'surgery_indicator': ['t7'],
    'surgery_name': ['t11'],
    'total_claimed_amount': ['t13'],
    'treating_doctor_contact_number': ['t11'],
    'treating_doctor_name': ['t8', 't11'],
    'treatment_type': ['t8', 't11', 't3', 't7', 't15']
} -%}

{%- set hub_keys = [
    {'name': 'HUB_AGREEMENT_BK', 'expr': 't13.HUB_AGREEMENT_BK__REMEDINET_PROVIDER_CODE'},
    {'name': 'HUB_ASSESSMENT_BK', 'expr': 'coalesce(t4.HUB_ASSESSMENT_BK__DOCASESS_ID, t5.HUB_ASSESSMENT_BK__DOCASESS_ID, t12.HUB_ASSESSMENT_BK__ASSESS_ID)'},
    {'name': 'HUB_CASE_BK', 'expr': 'coalesce(t9.HUB_CASE_BK__ALLOCATE_ID, t10.HUB_CASE_BK__ENHANCE_REF_ID)'},
    {'name': 'HUB_CLAIM_BK', 'expr': 'coalesce(t0.HUB_CLAIM_BK__CLAIM_ID, t1.HUB_CLAIM_BK__CLAIM_ID, t2.HUB_CLAIM_BK__CLAIM_ID, t3.HUB_CLAIM_BK__CLAIM_ID, t4.HUB_CLAIM_BK__CLAIM_ID, t5.HUB_CLAIM_BK__CLAIM_ID, t6.HUB_CLAIM_BK__CLAIM_ID, t7.HUB_CLAIM_BK__CLID, t8.HUB_CLAIM_BK__CLAIM_ID, t9.HUB_CLAIM_BK__CLAIM_ID, t10.HUB_CLAIM_BK__CLID, t11.HUB_CLAIM_BK__CLAIM_ID, t12.HUB_CLAIM_BK__CLAIM_ID, t13.HUB_CLAIM_BK__CLAIM_NO, t14.HUB_CLAIM_BK__REMEDINET_REQ_REQUESTID, t15.HUB_CLAIM_BK__BJAZ_CLAIM_ID)'},
    {'name': 'HUB_COVERAGE_BK', 'expr': 't5.HUB_COVERAGE_BK__COVER_SECTION'},
    {'name': 'HUB_DISTRIBUTION_CHANNEL_BK', 'expr': 'coalesce(t7.HUB_DISTRIBUTION_CHANNEL_BK__IMD_CODE, t15.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t16.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID, t19.HUB_DISTRIBUTION_CHANNEL_BK__PARTNER_ID)'},
    {'name': 'HUB_DOCUMENT_BK', 'expr': 'coalesce(t9.HUB_DOCUMENT_BK__OMNI_INWARD_NO, t10.HUB_DOCUMENT_BK__OMNI_INWARD_NO, t13.HUB_DOCUMENT_BK__OMNI_INWARD_NO, t16.HUB_DOCUMENT_BK__MEDICAL_REPORT, t19.HUB_DOCUMENT_BK__MEDICAL_REPORT)'},
    {'name': 'HUB_FINANCIAL_ACCOUNT_BK', 'expr': 't7.HUB_FINANCIAL_ACCOUNT_BK__BANK_AC_NO'},
    {'name': 'HUB_FINANCIAL_TRANSACTION_BK', 'expr': 'coalesce(t7.HUB_FINANCIAL_TRANSACTION_BK__UTR_NO, t15.HUB_FINANCIAL_TRANSACTION_BK__TPA_TRANS_KEY)'},
    {'name': 'HUB_LOCATION_BK', 'expr': 't14.HUB_LOCATION_BK__ADDRESS1_ADDRESS2_ADDRESS3_CITY'},
    {'name': 'HUB_LOSS_EVENT_BK', 'expr': 'coalesce(t7.HUB_LOSS_EVENT_BK__CLAIM_NO, t15.HUB_LOSS_EVENT_BK__TPA_CLAIM_NO)'},
    {'name': 'HUB_PARTY_BK', 'expr': 'coalesce(t2.HUB_PARTY_BK__HOSPITAL_ID, t3.HUB_PARTY_BK__LDR_PID, t7.HUB_PARTY_BK__HOSPITAL_ID, t10.HUB_PARTY_BK__HOSP_ID, t14.HUB_PARTY_BK__MEMBER_MEMBER_NO, t16.HUB_PARTY_BK__MEMBER_NO, t19.HUB_PARTY_BK__MEMBER_NO)'},
    {'name': 'HUB_PAYMENT_INSTRUMENT_BK', 'expr': 'coalesce(t7.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO, t15.HUB_PAYMENT_INSTRUMENT_BK__CHEQUE_NO)'},
    {'name': 'HUB_POLICY_BK', 'expr': 'coalesce(t2.HUB_POLICY_BK__POLICY_REF, t3.HUB_POLICY_BK__POLICY_REF, t7.HUB_POLICY_BK__POLICY, t13.HUB_POLICY_BK__POLICY_NO, t15.HUB_POLICY_BK__POLICY_NO, t16.HUB_POLICY_BK__CONTRACT_ID, t17.HUB_POLICY_BK__REG_NO, t18.HUB_POLICY_BK__POLICY_NO, t19.HUB_POLICY_BK__CONTRACT_ID)'},
    {'name': 'HUB_PRODUCT_BK', 'expr': 'coalesce(t3.HUB_PRODUCT_BK__PROD_CD, t17.HUB_PRODUCT_BK__PRODUCT)'},
    {'name': 'HUB_QUOTE_BK', 'expr': 't17.HUB_QUOTE_BK__QUOTE_SUB_NO'},
    {'name': 'HUB_RISK_OBJECT_BK', 'expr': 'coalesce(t8.HUB_RISK_OBJECT_BK__HEALTHCARD_ID_CARD_NO, t14.HUB_RISK_OBJECT_BK__MEMBER_MEMBER_NO, t16.HUB_RISK_OBJECT_BK__MEMBER_NO)'},
    {'name': 'T7__HUB_LOCATION_BK__LOCATION_CODE', 'expr': 't7.HUB_LOCATION_BK__LOCATION_CODE'},
    {'name': 'T7__HUB_LOCATION_BK__LOCATIONCODE', 'expr': 't7.HUB_LOCATION_BK__LOCATIONCODE'},
    {'name': 'T7__HUB_LOCATION_BK__ORPHAN_LOC', 'expr': 't7.HUB_LOCATION_BK__ORPHAN_LOC'},
    {'name': 'T7__HUB_LOCATION_BK__POLICY_LOCATION', 'expr': 't7.HUB_LOCATION_BK__POLICY_LOCATION'},
    {'name': 'T7__HUB_LOCATION_BK__RISK_LOCATION', 'expr': 't7.HUB_LOCATION_BK__RISK_LOCATION'},
    {'name': 'T11__HUB_DOCUMENT_BK__FIR_FIR_NO', 'expr': 't11.HUB_DOCUMENT_BK__FIR_FIR_NO'},
    {'name': 'T11__HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO', 'expr': 't11.HUB_DOCUMENT_BK__OMNI_INWARD_OMNI_INWARD_NO'},
    {'name': 'T11__HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO', 'expr': 't11.HUB_PARTY_BK__HEALTHCARD_INSURED_CARD_NO'},
    {'name': 'T11__HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD', 'expr': 't11.HUB_PARTY_BK__HEALTHCARD_PATIENT_ID_CARD'},
    {'name': 'T11__HUB_PARTY_BK__HOSPID_HOS_ID', 'expr': 't11.HUB_PARTY_BK__HOSPID_HOS_ID'},
    {'name': 'T13__HUB_PARTY_BK__PAYER_CODE', 'expr': 't13.HUB_PARTY_BK__PAYER_CODE'},
    {'name': 'T13__HUB_PARTY_BK__REMEDINET_PROVIDER_CODE', 'expr': 't13.HUB_PARTY_BK__REMEDINET_PROVIDER_CODE'},
    {'name': 'T15__HUB_ORG_UNIT_BK__CONTROLLING_OFFICE', 'expr': 't15.HUB_ORG_UNIT_BK__CONTROLLING_OFFICE'},
    {'name': 'T15__HUB_ORG_UNIT_BK__OPERATING_OFFICE', 'expr': 't15.HUB_ORG_UNIT_BK__OPERATING_OFFICE'},
    {'name': 'T15__HUB_PARTY_BK__CUSTOMER_ID', 'expr': 't15.HUB_PARTY_BK__CUSTOMER_ID'},
    {'name': 'T15__HUB_PARTY_BK__HOSPITAL_CODE', 'expr': 't15.HUB_PARTY_BK__HOSPITAL_CODE'}
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_claim_health_detail'
) }}
