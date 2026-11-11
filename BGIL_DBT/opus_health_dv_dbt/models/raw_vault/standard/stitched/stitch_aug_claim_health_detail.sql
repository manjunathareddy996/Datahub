{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_HEALTH_DETAIL only. Original precedence comments are kept below (from stitch_v10_claim).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_claim_details') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': 'hosp_icu_elgiamt', 'tgt': 'aug_claim_health_detail__eligible_icu_rent_amount'},
        {'src': 'hosp_icu_days', 'tgt': 'aug_claim_health_detail__icu_days'},
        {'src': 'hosp_norm_room', 'tgt': 'aug_claim_health_detail__normal_room_days'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't1',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': 'first_consult_date', 'tgt': 'aug_claim_health_detail__first_consultation_date'},
        {'src': 'last_consult_date', 'tgt': 'aug_claim_health_detail__last_consultation_date'},
        {'src': 'prov_diag', 'tgt': 'aug_claim_health_detail__provisional_diagnosis_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_preauth_request',
      'alias': 't2',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_REQUEST',
      'columns': [
        {'src': 'ailment_duration', 'tgt': 'aug_claim_health_detail__ailment_duration_days'},
        {'src': 'attendant_contact_no', 'tgt': 'aug_claim_health_detail__attendant_contact_number'},
        {'src': 'attendant_name', 'tgt': 'aug_claim_health_detail__attendant_name'},
        {'src': 'clinical', 'tgt': 'aug_claim_health_detail__clinical_findings_description'},
        {'src': 'corporate_name', 'tgt': 'aug_claim_health_detail__corporate_group_reference'},
        {'src': 'delivery_date', 'tgt': 'aug_claim_health_detail__delivery_date'},
        {'src': 'test_conducted', 'tgt': 'aug_claim_health_detail__diagnostic_test_conducted_indicator'},
        {'src': 'drug_administration', 'tgt': 'aug_claim_health_detail__drug_administration_detail'},
        {'src': 'exp_len_stay', 'tgt': 'aug_claim_health_detail__expected_length_of_stay_days'},
        {'src': 'fam_contact_no', 'tgt': 'aug_claim_health_detail__family_physician_contact_number'},
        {'src': 'fam_phy_yn', 'tgt': 'aug_claim_health_detail__family_physician_indicator'},
        {'src': 'fam_phy_name', 'tgt': 'aug_claim_health_detail__family_physician_name'},
        {'src': 'first_consulation_date', 'tgt': 'aug_claim_health_detail__first_consultation_date'},
        {'src': 'hospitalization_type', 'tgt': 'aug_claim_health_detail__hospitalisation_type'},
        {'src': 'icu_stay', 'tgt': 'aug_claim_health_detail__icu_stay_days'},
        {'src': 'injury_occur', 'tgt': 'aug_claim_health_detail__injury_circumstance_description'},
        {'src': 'injury_disease', 'tgt': 'aug_claim_health_detail__injury_or_disease_indicator'},
        {'src': 'invest_med_dtls', 'tgt': 'aug_claim_health_detail__investigation_and_medical_management_detail'},
        {'src': 'lmp', 'tgt': 'aug_claim_health_detail__last_menstrual_period_date'},
        {'src': 'curr_medclaim', 'tgt': 'aug_claim_health_detail__other_health_cover_declared_indicator'},
        {'src': 'curr_comp_dtls', 'tgt': 'aug_claim_health_detail__other_health_cover_detail'},
        {'src': 'curr_comp_name', 'tgt': 'aug_claim_health_detail__other_insurer_name'},
        {'src': 'other_treatment', 'tgt': 'aug_claim_health_detail__other_treatment_detail'},
        {'src': 'police_report', 'tgt': 'aug_claim_health_detail__police_report_indicator'},
        {'src': 'provisional_diagnosis', 'tgt': 'aug_claim_health_detail__provisional_diagnosis_description'},
        {'src': 'rta_status', 'tgt': 'aug_claim_health_detail__road_traffic_accident_indicator'},
        {'src': 'room_stay', 'tgt': 'aug_claim_health_detail__room_stay_days'},
        {'src': 'doc_contact_no', 'tgt': 'aug_claim_health_detail__treating_doctor_contact_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_bill_detail',
      'alias': 't3',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_BILL_DETAIL',
      'columns': [
        {'src': 'grade', 'tgt': 'aug_claim_health_detail__room_grade'},
        {'src': 'room_rent_perc', 'tgt': 'aug_claim_health_detail__room_rent_eligibility_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_bill_detail_ocr',
      'alias': 't4',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_BILL_DETAIL_OCR',
      'columns': [
        {'src': 'availed_room_rent_per_day', 'tgt': 'aug_claim_health_detail__availed_room_rent_per_day'},
        {'src': 'room_rent_perc', 'tgt': 'aug_claim_health_detail__room_rent_eligibility_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_coinsu_clm_dtls',
      'alias': 't5',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_COINSU_CLM_DTLS',
      'columns': [
        {'src': 'buffer_utilised_amt', 'tgt': 'aug_claim_health_detail__corporate_buffer_utilised_amount'},
        {'src': 'disease_catagory', 'tgt': 'aug_claim_health_detail__disease_category'},
        {'src': 'major_diseases', 'tgt': 'aug_claim_health_detail__major_disease_category'},
        {'src': 'not_covered_amt', 'tgt': 'aug_claim_health_detail__not_covered_amount'},
        {'src': 'primary_classification', 'tgt': 'aug_claim_health_detail__primary_diagnosis_classification'},
        {'src': 'si_exhausted_amt', 'tgt': 'aug_claim_health_detail__sum_insured_exhausted_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't6',
      'key_column': 'clid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'ip_type', 'tgt': 'aug_claim_health_detail__admission_type'},
        {'src': 'cardiology', 'tgt': 'aug_claim_health_detail__cardiology_charges_amount'},
        {'src': 'corporate_buffer_amt', 'tgt': 'aug_claim_health_detail__corporate_buffer_amount'},
        {'src': 'disease_category', 'tgt': 'aug_claim_health_detail__disease_category'},
        {'src': 'doctor_charges', 'tgt': 'aug_claim_health_detail__doctor_charges_amount'},
        {'src': 'equipement', 'tgt': 'aug_claim_health_detail__equipment_charges_amount'},
        {'src': 'insured_disallow_amt_reason', 'tgt': 'aug_claim_health_detail__insured_disallowance_reason'},
        {'src': 'insured_disallowed_amt', 'tgt': 'aug_claim_health_detail__insured_disallowed_amount'},
        {'src': 'neo_natal_charges', 'tgt': 'aug_claim_health_detail__neonatal_charges_amount'},
        {'src': 'non_medical', 'tgt': 'aug_claim_health_detail__non_medical_charges_amount'},
        {'src': 'non_network_co_pay', 'tgt': 'aug_claim_health_detail__non_network_co_pay_amount'},
        {'src': 'pathology', 'tgt': 'aug_claim_health_detail__pathology_charges_amount'},
        {'src': 'provisional_diagnosis', 'tgt': 'aug_claim_health_detail__provisional_diagnosis'},
        {'src': 'radiology', 'tgt': 'aug_claim_health_detail__radiology_charges_amount'},
        {'src': 'room_rent_diff_co_pay', 'tgt': 'aug_claim_health_detail__room_rent_difference_co_pay_amount'},
        {'src': 'coalesce(availed_room_rent_per_day, availed_room_rent_per_day_h)', 'tgt': 'aug_claim_health_detail__room_rent_per_day'},
        {'src': 'service_charges', 'tgt': 'aug_claim_health_detail__service_charges_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_claim_details',
      'alias': 't7',
      'key_column': 'claim_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_CLAIM_DETAILS',
      'columns': [
        {'src': 'approved_package_amount', 'tgt': 'aug_claim_health_detail__approved_package_amount'},
        {'src': 'copay_type', 'tgt': 'aug_claim_health_detail__co_pay_type'},
        {'src': 'patient_paid_amount', 'tgt': 'aug_claim_health_detail__patient_paid_amount'},
        {'src': 'total_claimed_amount', 'tgt': 'aug_claim_health_detail__total_claimed_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't8',
      'key_column': 'bjaz_claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'consultant_charges', 'tgt': 'aug_claim_health_detail__consultant_charges'},
        {'src': 'diagnosis_code_level2', 'tgt': 'aug_claim_health_detail__diagnosis_code'},
        {'src': 'coalesce(diagnosis_description_level1, diagnosis_description_level2)', 'tgt': 'aug_claim_health_detail__diagnosis_description'},
        {'src': 'imaging_studies_charges', 'tgt': 'aug_claim_health_detail__imaging_studies_charges'},
        {'src': 'physician_fees', 'tgt': 'aug_claim_health_detail__physician_fees'},
        {'src': 'procedure_codes_level2', 'tgt': 'aug_claim_health_detail__procedure_code'},
        {'src': 'procedure_description_level2', 'tgt': 'aug_claim_health_detail__procedure_description'},
        {'src': 'specialist_charges', 'tgt': 'aug_claim_health_detail__specialist_charges'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_claim_health_detail__eligible_icu_rent_amount',
    'aug_claim_health_detail__icu_days',
    'aug_claim_health_detail__normal_room_days',
    'aug_claim_health_detail__first_consultation_date',
    'aug_claim_health_detail__last_consultation_date',
    'aug_claim_health_detail__provisional_diagnosis_description',
    'aug_claim_health_detail__ailment_duration_days',
    'aug_claim_health_detail__attendant_contact_number',
    'aug_claim_health_detail__attendant_name',
    'aug_claim_health_detail__clinical_findings_description',
    'aug_claim_health_detail__corporate_group_reference',
    'aug_claim_health_detail__delivery_date',
    'aug_claim_health_detail__diagnostic_test_conducted_indicator',
    'aug_claim_health_detail__drug_administration_detail',
    'aug_claim_health_detail__expected_length_of_stay_days',
    'aug_claim_health_detail__family_physician_contact_number',
    'aug_claim_health_detail__family_physician_indicator',
    'aug_claim_health_detail__family_physician_name',
    'aug_claim_health_detail__hospitalisation_type',
    'aug_claim_health_detail__icu_stay_days',
    'aug_claim_health_detail__injury_circumstance_description',
    'aug_claim_health_detail__injury_or_disease_indicator',
    'aug_claim_health_detail__investigation_and_medical_management_detail',
    'aug_claim_health_detail__last_menstrual_period_date',
    'aug_claim_health_detail__other_health_cover_declared_indicator',
    'aug_claim_health_detail__other_health_cover_detail',
    'aug_claim_health_detail__other_insurer_name',
    'aug_claim_health_detail__other_treatment_detail',
    'aug_claim_health_detail__police_report_indicator',
    'aug_claim_health_detail__road_traffic_accident_indicator',
    'aug_claim_health_detail__room_stay_days',
    'aug_claim_health_detail__treating_doctor_contact_number',
    'aug_claim_health_detail__room_grade',
    'aug_claim_health_detail__room_rent_eligibility_percentage',
    'aug_claim_health_detail__availed_room_rent_per_day',
    'aug_claim_health_detail__corporate_buffer_utilised_amount',
    'aug_claim_health_detail__disease_category',
    'aug_claim_health_detail__major_disease_category',
    'aug_claim_health_detail__not_covered_amount',
    'aug_claim_health_detail__primary_diagnosis_classification',
    'aug_claim_health_detail__sum_insured_exhausted_amount',
    'aug_claim_health_detail__admission_type',
    'aug_claim_health_detail__cardiology_charges_amount',
    'aug_claim_health_detail__corporate_buffer_amount',
    'aug_claim_health_detail__doctor_charges_amount',
    'aug_claim_health_detail__equipment_charges_amount',
    'aug_claim_health_detail__insured_disallowance_reason',
    'aug_claim_health_detail__insured_disallowed_amount',
    'aug_claim_health_detail__neonatal_charges_amount',
    'aug_claim_health_detail__non_medical_charges_amount',
    'aug_claim_health_detail__non_network_co_pay_amount',
    'aug_claim_health_detail__pathology_charges_amount',
    'aug_claim_health_detail__provisional_diagnosis',
    'aug_claim_health_detail__radiology_charges_amount',
    'aug_claim_health_detail__room_rent_difference_co_pay_amount',
    'aug_claim_health_detail__room_rent_per_day',
    'aug_claim_health_detail__service_charges_amount',
    'aug_claim_health_detail__approved_package_amount',
    'aug_claim_health_detail__co_pay_type',
    'aug_claim_health_detail__patient_paid_amount',
    'aug_claim_health_detail__total_claimed_amount',
    'aug_claim_health_detail__consultant_charges',
    'aug_claim_health_detail__diagnosis_code',
    'aug_claim_health_detail__diagnosis_description',
    'aug_claim_health_detail__imaging_studies_charges',
    'aug_claim_health_detail__physician_fees',
    'aug_claim_health_detail__procedure_code',
    'aug_claim_health_detail__procedure_description',
    'aug_claim_health_detail__specialist_charges'
] -%}
{%- set coalesce_rules = {
    'aug_claim_health_detail__eligible_icu_rent_amount': ['t0'],
    'aug_claim_health_detail__icu_days': ['t0'],
    'aug_claim_health_detail__normal_room_days': ['t0'],
    'aug_claim_health_detail__first_consultation_date': ['t1', 't2'],
    'aug_claim_health_detail__last_consultation_date': ['t1'],
    'aug_claim_health_detail__provisional_diagnosis_description': ['t1', 't2'],
    'aug_claim_health_detail__ailment_duration_days': ['t2'],
    'aug_claim_health_detail__attendant_contact_number': ['t2'],
    'aug_claim_health_detail__attendant_name': ['t2'],
    'aug_claim_health_detail__clinical_findings_description': ['t2'],
    'aug_claim_health_detail__corporate_group_reference': ['t2'],
    'aug_claim_health_detail__delivery_date': ['t2'],
    'aug_claim_health_detail__diagnostic_test_conducted_indicator': ['t2'],
    'aug_claim_health_detail__drug_administration_detail': ['t2'],
    'aug_claim_health_detail__expected_length_of_stay_days': ['t2'],
    'aug_claim_health_detail__family_physician_contact_number': ['t2'],
    'aug_claim_health_detail__family_physician_indicator': ['t2'],
    'aug_claim_health_detail__family_physician_name': ['t2'],
    'aug_claim_health_detail__hospitalisation_type': ['t2'],
    'aug_claim_health_detail__icu_stay_days': ['t2'],
    'aug_claim_health_detail__injury_circumstance_description': ['t2'],
    'aug_claim_health_detail__injury_or_disease_indicator': ['t2'],
    'aug_claim_health_detail__investigation_and_medical_management_detail': ['t2'],
    'aug_claim_health_detail__last_menstrual_period_date': ['t2'],
    'aug_claim_health_detail__other_health_cover_declared_indicator': ['t2'],
    'aug_claim_health_detail__other_health_cover_detail': ['t2'],
    'aug_claim_health_detail__other_insurer_name': ['t2'],
    'aug_claim_health_detail__other_treatment_detail': ['t2'],
    'aug_claim_health_detail__police_report_indicator': ['t2'],
    'aug_claim_health_detail__road_traffic_accident_indicator': ['t2'],
    'aug_claim_health_detail__room_stay_days': ['t2'],
    'aug_claim_health_detail__treating_doctor_contact_number': ['t2'],
    'aug_claim_health_detail__room_grade': ['t3'],
    'aug_claim_health_detail__room_rent_eligibility_percentage': ['t3', 't4'],
    'aug_claim_health_detail__availed_room_rent_per_day': ['t4'],
    'aug_claim_health_detail__corporate_buffer_utilised_amount': ['t5'],
    'aug_claim_health_detail__disease_category': ['t5', 't6'],
    'aug_claim_health_detail__major_disease_category': ['t5'],
    'aug_claim_health_detail__not_covered_amount': ['t5'],
    'aug_claim_health_detail__primary_diagnosis_classification': ['t5'],
    'aug_claim_health_detail__sum_insured_exhausted_amount': ['t5'],
    'aug_claim_health_detail__admission_type': ['t6'],
    'aug_claim_health_detail__cardiology_charges_amount': ['t6'],
    'aug_claim_health_detail__corporate_buffer_amount': ['t6'],
    'aug_claim_health_detail__doctor_charges_amount': ['t6'],
    'aug_claim_health_detail__equipment_charges_amount': ['t6'],
    'aug_claim_health_detail__insured_disallowance_reason': ['t6'],
    'aug_claim_health_detail__insured_disallowed_amount': ['t6'],
    'aug_claim_health_detail__neonatal_charges_amount': ['t6'],
    'aug_claim_health_detail__non_medical_charges_amount': ['t6'],
    'aug_claim_health_detail__non_network_co_pay_amount': ['t6'],
    'aug_claim_health_detail__pathology_charges_amount': ['t6'],
    'aug_claim_health_detail__provisional_diagnosis': ['t6'],
    'aug_claim_health_detail__radiology_charges_amount': ['t6'],
    'aug_claim_health_detail__room_rent_difference_co_pay_amount': ['t6'],
    'aug_claim_health_detail__room_rent_per_day': ['t6'],
    'aug_claim_health_detail__service_charges_amount': ['t6'],
    'aug_claim_health_detail__approved_package_amount': ['t7'],
    'aug_claim_health_detail__co_pay_type': ['t7'],
    'aug_claim_health_detail__patient_paid_amount': ['t7'],
    'aug_claim_health_detail__total_claimed_amount': ['t7'],
    'aug_claim_health_detail__consultant_charges': ['t8'],
    'aug_claim_health_detail__diagnosis_code': ['t8'],
    'aug_claim_health_detail__diagnosis_description': ['t8'],
    'aug_claim_health_detail__imaging_studies_charges': ['t8'],
    'aug_claim_health_detail__physician_fees': ['t8'],
    'aug_claim_health_detail__procedure_code': ['t8'],
    'aug_claim_health_detail__procedure_description': ['t8'],
    'aug_claim_health_detail__specialist_charges': ['t8']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_aug_claim_health_detail'
) }}
