{{ config(materialized='view') }}
-- This part feeds SAT_CLAIM_HEALTH_DETAIL only. Original precedence comments are kept below (from stitch_v10_claim).
-- CENTRAL VIEW v10_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_GPA_BILL_DTLS (opus_health_v2)
--   BJAZ_HM_HCS_TECH_ASSESS_COV (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_HM_BILL_DETAIL (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL_OCR (opus_health_legacy_v4)
--   BJAZ_HM_CASHLESS_INWARD (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_DOCTOR_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_DOCTOR_MULTI_ASSESS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_AUTOALLOCATION (opus_health_legacy_v4)
--   BJAZ_HM_PREAUTH_ENHANCE (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_REMEDINET_PATIENT_DETAILS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_HEALTH_DETAIL
--   SAT_AUG_CLAIM_TPA_INTERACTION
--   SAT_CLAIM_HEALTH_DETAIL
--   SAT_CLAIM_TPA_INTERACTION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CASE_DOCUMENT
--   LNK_CASE_PARTY
--   LNK_CLAIM_CASE
--   LNK_CLAIM_DOCUMENT
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_POLICY
--   LNK_PARTY_DOCUMENT
--   LNK_POLICY_PARTY
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_gpa_bill_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcs_tech_assess_cov') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_preauth_request') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_bill_detail') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_bill_detail_ocr') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_cashless_inward') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_doctor_assess') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_doctor_multi_assess') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_inward_autoallocation') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_pro_assessment') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_claim_details') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_patient_details') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': 'hosp_doa', 'tgt': 'claim_health_detail__admission_date'},
        {'src': 'hosp_dod', 'tgt': 'claim_health_detail__discharge_date'},
        {'src': 'hosp_norm_elgiamt', 'tgt': 'claim_health_detail__eligible_room_rent'},
        {'src': 'hosp_icu_room_amt', 'tgt': 'claim_health_detail__icu_rent_amount'},
        {'src': 'hosp_normal_room_amt', 'tgt': 'claim_health_detail__room_rent_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't1',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': 'actual_doa', 'tgt': 'claim_health_detail__admission_date'},
        {'src': 'final_diag', 'tgt': 'claim_health_detail__ailment_description'},
        {'src': 'actual_dod', 'tgt': 'claim_health_detail__discharge_date'},
        {'src': 'icd_code', 'tgt': 'claim_health_detail__icd_code'},
        {'src': 'treat_dr', 'tgt': 'claim_health_detail__treating_doctor_name'},
        {'src': 'treat_type', 'tgt': 'claim_health_detail__treatment_type'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_preauth_request',
      'alias': 't2',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_REQUEST',
      'columns': [
        {'src': 'patient_admission_dt', 'tgt': 'claim_health_detail__admission_date'},
        {'src': 'patient_admission_time', 'tgt': 'claim_health_detail__admission_time'},
        {'src': 'illness_nature', 'tgt': 'claim_health_detail__ailment_description'},
        {'src': 'expected_dod', 'tgt': 'claim_health_detail__expected_discharge_date'},
        {'src': 'icd_code', 'tgt': 'claim_health_detail__icd_code'},
        {'src': 'room_type', 'tgt': 'claim_health_detail__room_category'},
        {'src': 'surgery_name', 'tgt': 'claim_health_detail__surgery_name'},
        {'src': 'treating_doc_name', 'tgt': 'claim_health_detail__treating_doctor_name'},
        {'src': 'line_of_treatment', 'tgt': 'claim_health_detail__treatment_type'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_bill_detail',
      'alias': 't3',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_BILL_DETAIL',
      'columns': [
        {'src': 'eligible_room_category', 'tgt': 'claim_health_detail__eligible_room_category'},
        {'src': 'eligible_room_rent', 'tgt': 'claim_health_detail__eligible_room_rent'},
        {'src': 'criti_unit_room_rent_per_day', 'tgt': 'claim_health_detail__icu_rent_amount'},
        {'src': 'ip_no', 'tgt': 'claim_health_detail__ipd_number'},
        {'src': 'availed_room_category', 'tgt': 'claim_health_detail__room_category'},
        {'src': 'availed_room_rent_per_day', 'tgt': 'claim_health_detail__room_rent_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_bill_detail_ocr',
      'alias': 't4',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_BILL_DETAIL_OCR',
      'columns': [
        {'src': 'eligible_room_category', 'tgt': 'claim_health_detail__eligible_room_category'},
        {'src': 'eligible_room_rent', 'tgt': 'claim_health_detail__eligible_room_rent'},
        {'src': 'criti_unit_room_rent_per_day', 'tgt': 'claim_health_detail__icu_rent_amount'},
        {'src': 'ip_no', 'tgt': 'claim_health_detail__ipd_number'},
        {'src': 'discount', 'tgt': 'claim_health_detail__network_discount_amount'},
        {'src': 'availed_room_category', 'tgt': 'claim_health_detail__room_category'},
        {'src': 'room_rent', 'tgt': 'claim_health_detail__room_rent_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_cashless_inward',
      'alias': 't5',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_CASHLESS_INWARD',
      'columns': [
        {'src': 'cashless_in_no', 'tgt': 'claim_health_detail__cashless_authorisation_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_coinsu_clm_dtls',
      'alias': 't6',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_COINSU_CLM_DTLS',
      'columns': [
        {'src': 'date_admission', 'tgt': 'claim_health_detail__admission_date'},
        {'src': 'ailment', 'tgt': 'claim_health_detail__ailment_description'},
        {'src': 'co_paymnt_deduction', 'tgt': 'claim_health_detail__co_pay_amount'},
        {'src': 'final_diagnosis', 'tgt': 'claim_health_detail__diagnosis_code'},
        {'src': 'reasons', 'tgt': 'claim_health_detail__disallowance_reason'},
        {'src': 'not_payable_exp', 'tgt': 'claim_health_detail__disallowed_amount'},
        {'src': 'date_of_discharge', 'tgt': 'claim_health_detail__discharge_date'},
        {'src': 'final_bill_amt', 'tgt': 'claim_health_detail__final_bill_amount'},
        {'src': 'provider_no', 'tgt': 'claim_health_detail__hospital_reference'},
        {'src': 'icd_code', 'tgt': 'claim_health_detail__icd_code'},
        {'src': 'network', 'tgt': 'claim_health_detail__network_hospital_indicator'},
        {'src': 'non_payable_def_amt', 'tgt': 'claim_health_detail__other_deduction_amount'},
        {'src': 'primary_proc', 'tgt': 'claim_health_detail__procedure_code'},
        {'src': 'level_of_care', 'tgt': 'claim_health_detail__treatment_type'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_doctor_assess',
      'alias': 't7',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_DOCTOR_ASSESS',
      'columns': [
        {'src': 'package_charge', 'tgt': 'claim_health_detail__actual_package_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_doctor_multi_assess',
      'alias': 't8',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_DOCTOR_MULTI_ASSESS',
      'columns': [
        {'src': 'package_charge', 'tgt': 'claim_health_detail__actual_package_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't9',
      'key_column': 'clid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'package_charges', 'tgt': 'claim_health_detail__actual_package_amount'},
        {'src': 'actual_doa', 'tgt': 'claim_health_detail__admission_date'},
        {'src': 'diagnosis_detail', 'tgt': 'claim_health_detail__ailment_description'},
        {'src': 'ambulance', 'tgt': 'claim_health_detail__ambulance_charges'},
        {'src': 'co_payment', 'tgt': 'claim_health_detail__co_pay_amount'},
        {'src': 'final_diagnosis', 'tgt': 'claim_health_detail__diagnosis_code'},
        {'src': 'hospital_disallow_amt_reason', 'tgt': 'claim_health_detail__disallowance_reason'},
        {'src': 'hospital_disallowed_amt', 'tgt': 'claim_health_detail__disallowed_amount'},
        {'src': 'actual_dod', 'tgt': 'claim_health_detail__discharge_date'},
        {'src': 'eligible_room_category', 'tgt': 'claim_health_detail__eligible_room_category'},
        {'src': 'eligible_room_rent', 'tgt': 'claim_health_detail__eligible_room_rent'},
        {'src': 'expected_dod', 'tgt': 'claim_health_detail__expected_discharge_date'},
        {'src': 'total_bill', 'tgt': 'claim_health_detail__final_bill_amount'},
        {'src': 'icd_code', 'tgt': 'claim_health_detail__icd_code'},
        {'src': 'icu_charges', 'tgt': 'claim_health_detail__icu_charges_amount'},
        {'src': 'criti_unit_room_rent_per_day', 'tgt': 'claim_health_detail__icu_rent_amount'},
        {'src': 'implant_charges', 'tgt': 'claim_health_detail__implant_cost'},
        {'src': 'ip_no', 'tgt': 'claim_health_detail__ipd_number'},
        {'src': 'miscellaneous', 'tgt': 'claim_health_detail__miscellaneous_charges_amount'},
        {'src': 'discount', 'tgt': 'claim_health_detail__network_discount_amount'},
        {'src': 'nursing_charges', 'tgt': 'claim_health_detail__nursing_charges'},
        {'src': 'other_deduction', 'tgt': 'claim_health_detail__other_deduction_amount'},
        {'src': 'ot_charges', 'tgt': 'claim_health_detail__ot_charges'},
        {'src': 'pharmacy', 'tgt': 'claim_health_detail__pharmacy_amount'},
        {'src': 'post_hosp_charges', 'tgt': 'claim_health_detail__post_hospitalisation_amount'},
        {'src': 'pre_hosp_charges', 'tgt': 'claim_health_detail__pre_hospitalisation_amount'},
        {'src': 'dig_procedure', 'tgt': 'claim_health_detail__procedure_description'},
        {'src': 'room_category', 'tgt': 'claim_health_detail__room_category'},
        {'src': 'room_charges', 'tgt': 'claim_health_detail__room_rent_amount'},
        {'src': 'surgeon_charges', 'tgt': 'claim_health_detail__surgeon_fee'},
        {'src': 'medical_or_surgical', 'tgt': 'claim_health_detail__surgery_indicator'},
        {'src': 'treatment_type', 'tgt': 'claim_health_detail__treatment_type'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_inward_autoallocation',
      'alias': 't10',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_INWARD_AUTOALLOCATION',
      'columns': [
        {'src': 'cashless_in_no', 'tgt': 'claim_health_detail__cashless_authorisation_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_preauth_enhance',
      'alias': 't11',
      'key_column': 'clid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_ENHANCE',
      'columns': [
        {'src': 'expected_dod', 'tgt': 'claim_health_detail__expected_discharge_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_pro_assessment',
      'alias': 't12',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PRO_ASSESSMENT',
      'columns': [
        {'src': 'tot_claimed_amt', 'tgt': 'claim_health_detail__final_bill_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_claim_details',
      'alias': 't13',
      'key_column': 'claim_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_CLAIM_DETAILS',
      'columns': [
        {'src': 'actual_package_amount', 'tgt': 'claim_health_detail__actual_package_amount'},
        {'src': 'preauth_no', 'tgt': 'claim_health_detail__cashless_authorisation_number'},
        {'src': 'copay_amount', 'tgt': 'claim_health_detail__co_pay_amount'},
        {'src': 'total_bill_amount', 'tgt': 'claim_health_detail__final_bill_amount'},
        {'src': 'preauth_amount', 'tgt': 'claim_health_detail__pre_authorisation_amount'},
        {'src': 'provider_remarks', 'tgt': 'claim_health_detail__pre_authorisation_remarks'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't14',
      'key_column': 'bjaz_claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'doa', 'tgt': 'claim_health_detail__admission_date'},
        {'src': 'diagnosis', 'tgt': 'claim_health_detail__ailment_description'},
        {'src': 'ambulance_charges', 'tgt': 'claim_health_detail__ambulance_charges'},
        {'src': 'anesthesia_fees', 'tgt': 'claim_health_detail__anaesthetist_fee'},
        {'src': 'pre_auth_letter_no', 'tgt': 'claim_health_detail__cashless_authorisation_number'},
        {'src': 'co_pay_amount', 'tgt': 'claim_health_detail__co_pay_amount'},
        {'src': 'diagnosis_code_level1', 'tgt': 'claim_health_detail__diagnosis_code'},
        {'src': 'deduction_reason', 'tgt': 'claim_health_detail__disallowance_reason'},
        {'src': 'dod', 'tgt': 'claim_health_detail__discharge_date'},
        {'src': 'claim_amount', 'tgt': 'claim_health_detail__final_bill_amount'},
        {'src': 'icucharges', 'tgt': 'claim_health_detail__icu_charges_amount'},
        {'src': 'investigation_charges', 'tgt': 'claim_health_detail__investigation_charges'},
        {'src': 'misc', 'tgt': 'claim_health_detail__miscellaneous_charges_amount'},
        {'src': 'nursing_fees', 'tgt': 'claim_health_detail__nursing_charges'},
        {'src': 'otcharges', 'tgt': 'claim_health_detail__ot_charges'},
        {'src': 'medicines', 'tgt': 'claim_health_detail__pharmacy_amount'},
        {'src': 'pre_auth_amount', 'tgt': 'claim_health_detail__pre_authorisation_amount'},
        {'src': 'procedure_codes_level1', 'tgt': 'claim_health_detail__procedure_code'},
        {'src': 'procedure_description_level1', 'tgt': 'claim_health_detail__procedure_description'},
        {'src': 'room_charges', 'tgt': 'claim_health_detail__room_rent_amount'},
        {'src': 'surgeon_charges', 'tgt': 'claim_health_detail__surgeon_fee'},
        {'src': 'treatment', 'tgt': 'claim_health_detail__treatment_type'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_patient_details',
      'alias': 't15',
      'key_column': "nullif('REMEDINET_REQ:' || nullif(trim(requestid),''), 'REMEDINET_REQ:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_PATIENT_DETAILS',
      'columns': [
        {'src': 'preauth_no', 'tgt': 'claim_health_detail__cashless_authorisation_number'},
        {'src': 'patient_hospital_no', 'tgt': 'claim_health_detail__ipd_number'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_health_detail__admission_date',
    'claim_health_detail__discharge_date',
    'claim_health_detail__eligible_room_rent',
    'claim_health_detail__icu_rent_amount',
    'claim_health_detail__room_rent_amount',
    'claim_health_detail__ailment_description',
    'claim_health_detail__icd_code',
    'claim_health_detail__treating_doctor_name',
    'claim_health_detail__treatment_type',
    'claim_health_detail__admission_time',
    'claim_health_detail__expected_discharge_date',
    'claim_health_detail__room_category',
    'claim_health_detail__surgery_name',
    'claim_health_detail__eligible_room_category',
    'claim_health_detail__ipd_number',
    'claim_health_detail__network_discount_amount',
    'claim_health_detail__cashless_authorisation_number',
    'claim_health_detail__co_pay_amount',
    'claim_health_detail__diagnosis_code',
    'claim_health_detail__disallowance_reason',
    'claim_health_detail__disallowed_amount',
    'claim_health_detail__final_bill_amount',
    'claim_health_detail__hospital_reference',
    'claim_health_detail__network_hospital_indicator',
    'claim_health_detail__other_deduction_amount',
    'claim_health_detail__procedure_code',
    'claim_health_detail__actual_package_amount',
    'claim_health_detail__ambulance_charges',
    'claim_health_detail__icu_charges_amount',
    'claim_health_detail__implant_cost',
    'claim_health_detail__miscellaneous_charges_amount',
    'claim_health_detail__nursing_charges',
    'claim_health_detail__ot_charges',
    'claim_health_detail__pharmacy_amount',
    'claim_health_detail__post_hospitalisation_amount',
    'claim_health_detail__pre_hospitalisation_amount',
    'claim_health_detail__procedure_description',
    'claim_health_detail__surgeon_fee',
    'claim_health_detail__surgery_indicator',
    'claim_health_detail__pre_authorisation_amount',
    'claim_health_detail__pre_authorisation_remarks',
    'claim_health_detail__anaesthetist_fee',
    'claim_health_detail__investigation_charges'
] -%}
{%- set coalesce_rules = {
    'claim_health_detail__admission_date': ['t0', 't1', 't2', 't6', 't9', 't14'],
    'claim_health_detail__discharge_date': ['t0', 't1', 't6', 't9', 't14'],
    'claim_health_detail__eligible_room_rent': ['t0', 't3', 't4', 't9'],
    'claim_health_detail__icu_rent_amount': ['t0', 't3', 't4', 't9'],
    'claim_health_detail__room_rent_amount': ['t0', 't3', 't4', 't9', 't14'],
    'claim_health_detail__ailment_description': ['t1', 't2', 't6', 't9', 't14'],
    'claim_health_detail__icd_code': ['t1', 't2', 't6', 't9'],
    'claim_health_detail__treating_doctor_name': ['t1', 't2'],
    'claim_health_detail__treatment_type': ['t1', 't2', 't6', 't9', 't14'],
    'claim_health_detail__admission_time': ['t2'],
    'claim_health_detail__expected_discharge_date': ['t2', 't9', 't11'],
    'claim_health_detail__room_category': ['t2', 't3', 't4', 't9'],
    'claim_health_detail__surgery_name': ['t2'],
    'claim_health_detail__eligible_room_category': ['t3', 't4', 't9'],
    'claim_health_detail__ipd_number': ['t3', 't4', 't9', 't15'],
    'claim_health_detail__network_discount_amount': ['t4', 't9'],
    'claim_health_detail__cashless_authorisation_number': ['t5', 't10', 't13', 't14', 't15'],
    'claim_health_detail__co_pay_amount': ['t6', 't9', 't13', 't14'],
    'claim_health_detail__diagnosis_code': ['t6', 't9', 't14'],
    'claim_health_detail__disallowance_reason': ['t6', 't9', 't14'],
    'claim_health_detail__disallowed_amount': ['t6', 't9'],
    'claim_health_detail__final_bill_amount': ['t6', 't9', 't12', 't13', 't14'],
    'claim_health_detail__hospital_reference': ['t6'],
    'claim_health_detail__network_hospital_indicator': ['t6'],
    'claim_health_detail__other_deduction_amount': ['t6', 't9'],
    'claim_health_detail__procedure_code': ['t6', 't14'],
    'claim_health_detail__actual_package_amount': ['t7', 't8', 't9', 't13'],
    'claim_health_detail__ambulance_charges': ['t9', 't14'],
    'claim_health_detail__icu_charges_amount': ['t9', 't14'],
    'claim_health_detail__implant_cost': ['t9'],
    'claim_health_detail__miscellaneous_charges_amount': ['t9', 't14'],
    'claim_health_detail__nursing_charges': ['t9', 't14'],
    'claim_health_detail__ot_charges': ['t9', 't14'],
    'claim_health_detail__pharmacy_amount': ['t9', 't14'],
    'claim_health_detail__post_hospitalisation_amount': ['t9'],
    'claim_health_detail__pre_hospitalisation_amount': ['t9'],
    'claim_health_detail__procedure_description': ['t9', 't14'],
    'claim_health_detail__surgeon_fee': ['t9', 't14'],
    'claim_health_detail__surgery_indicator': ['t9'],
    'claim_health_detail__pre_authorisation_amount': ['t13', 't14'],
    'claim_health_detail__pre_authorisation_remarks': ['t13'],
    'claim_health_detail__anaesthetist_fee': ['t14'],
    'claim_health_detail__investigation_charges': ['t14']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_claim_health_detail'
) }}
