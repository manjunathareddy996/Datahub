{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_CLAIM_HEALTH_DETAIL (HUB_CLAIM grain).
-- Attribute-level merge across 25 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_claim_health_detail.sql stage() model.

select parent_bk, actual_package_amount, admission_date, admission_time, ailment_description, ambulance_charges, anaesthetist_fee, cashless_authorisation_number, co_pay_amount, diagnosis_code, disallowance_reason, disallowed_amount, discharge_date, discharge_time, eligible_room_category, eligible_room_rent, expected_discharge_date, final_bill_amount, health_claim_remarks, hospital_reference, icd_code, icu_charges_amount, icu_rent_amount, implant_cost, implant_indicator, investigation_charges, ipd_number, length_of_stay, miscellaneous_charges_amount, network_discount_amount, network_hospital_indicator, nursing_charges, ot_charges, other_deduction_amount, pharmacy_amount, post_hospitalisation_amount, pre_authorisation_amount, pre_authorisation_remarks, pre_hospitalisation_amount, procedure_code, procedure_description, room_category, room_rent_amount, specialty, surgeon_fee, surgery_indicator, treating_doctor_name, treatment_type, record_source
from (
    with t0 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(expected_doa)), '') as admission_date,
            nullif(trim(to_varchar(prov_diagnosis)), '') as ailment_description,
            nullif(trim(to_varchar(pre_auth_no)), '') as cashless_authorisation_number,
            nullif(trim(to_varchar(expected_dod)), '') as expected_discharge_date,
            nullif(trim(to_varchar(doctor_name)), '') as treating_doctor_name
        from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by admission_date, ailment_description, cashless_authorisation_number, expected_discharge_date, treating_doctor_name) = 1
    ),
         t1 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(diagonsis_remarks)), '') as ailment_description
        from {{ ref('stg_health__bjaz_clm_wg_trans_dtls') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by ailment_description) = 1
    ),
         t2 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(diagonsis_remarks)), '') as ailment_description
        from {{ ref('stg_health__bjaz_clm_wg_trans_dtls_hist') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by ailment_description) = 1
    ),
         t3 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(ambulance_dtls)), '') as ambulance_charges,
            nullif(trim(to_varchar(add_info_hosp)), '') as health_claim_remarks,
            nullif(trim(to_varchar(after_hospital_visit)), '') as post_hospitalisation_amount,
            nullif(trim(to_varchar(meeting_pm_doctor)), '') as treating_doctor_name,
            nullif(trim(to_varchar(type_treatment)), '') as treatment_type
        from {{ ref('stg_health__bjaz_fplm_od_hospital_details') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by ambulance_charges, health_claim_remarks, post_hospitalisation_amount, treating_doctor_name, treatment_type) = 1
    ),
         t4 as (
        select distinct
            case_id as parent_bk,
            nullif(trim(to_varchar(non_payable_total)), '') as disallowed_amount,
            nullif(trim(to_varchar(disc_total)), '') as network_discount_amount
        from {{ ref('stg_health__bjaz_hat_dedution_summary') }}
        where case_id is not null
        qualify row_number() over (partition by parent_bk order by disallowed_amount, network_discount_amount) = 1
    ),
         t5 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(eligible_room_category)), '') as eligible_room_category,
            nullif(trim(to_varchar(eligible_room_rent)), '') as eligible_room_rent,
            nullif(trim(to_varchar(criti_unit_room_rent_per_day)), '') as icu_rent_amount,
            nullif(trim(to_varchar(ip_no)), '') as ipd_number,
            nullif(trim(to_varchar(availed_room_category)), '') as room_category,
            nullif(trim(to_varchar(availed_room_rent_per_day)), '') as room_rent_amount
        from {{ ref('stg_health__bjaz_hm_bill_detail') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by eligible_room_category, eligible_room_rent, icu_rent_amount, ipd_number, room_category, room_rent_amount) = 1
    ),
         t6 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(eligible_room_category)), '') as eligible_room_category,
            nullif(trim(to_varchar(eligible_room_rent)), '') as eligible_room_rent,
            nullif(trim(to_varchar(criti_unit_room_rent_per_day)), '') as icu_rent_amount,
            nullif(trim(to_varchar(ip_no)), '') as ipd_number,
            nullif(trim(to_varchar(discount)), '') as network_discount_amount,
            nullif(trim(to_varchar(availed_room_category)), '') as room_category,
            nullif(trim(to_varchar(room_rent)), '') as room_rent_amount
        from {{ ref('stg_health__bjaz_hm_bill_detail_ocr') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by eligible_room_category, eligible_room_rent, icu_rent_amount, ipd_number, network_discount_amount, room_category, room_rent_amount) = 1
    ),
         t7 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(cashless_in_no)), '') as cashless_authorisation_number
        from {{ ref('stg_health__bjaz_hm_cashless_inward') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by cashless_authorisation_number) = 1
    ),
         t8 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(disallow_amt)), '') as disallowed_amount
        from {{ ref('stg_health__bjaz_hm_claim_payment') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by disallowed_amount) = 1
    ),
         t9 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(actual_doa)), '') as admission_date,
            nullif(trim(to_varchar(opd_final_diagnosis)), '') as ailment_description,
            nullif(trim(to_varchar(cashless_in_id)), '') as cashless_authorisation_number,
            nullif(trim(to_varchar(actual_dod)), '') as discharge_date,
            nullif(trim(to_varchar(adverse_hist)), '') as health_claim_remarks,
            nullif(trim(to_varchar(implant_yn)), '') as implant_indicator,
            nullif(trim(to_varchar(hos_network_type)), '') as network_hospital_indicator,
            nullif(trim(to_varchar(room_desc)), '') as room_category,
            nullif(trim(to_varchar(bariatric_surgery)), '') as surgery_indicator,
            nullif(trim(to_varchar(treating_type)), '') as treatment_type
        from {{ ref('stg_health__bjaz_hm_clm_register') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by admission_date, ailment_description, cashless_authorisation_number, discharge_date, health_claim_remarks, implant_indicator, network_hospital_indicator, room_category, surgery_indicator, treatment_type) = 1
    ),
         t10 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(anaesthetis)), '') as anaesthetist_fee,
            nullif(trim(to_varchar(eligible_room_category)), '') as eligible_room_category,
            nullif(trim(to_varchar(icu_rent)), '') as icu_rent_amount,
            nullif(trim(to_varchar(nursing_charges)), '') as nursing_charges,
            nullif(trim(to_varchar(ot)), '') as ot_charges,
            nullif(trim(to_varchar(room_rent)), '') as room_rent_amount,
            nullif(trim(to_varchar(surgeon_fees)), '') as surgeon_fee,
            nullif(trim(to_varchar(mode_of_treatment)), '') as treatment_type
        from {{ ref('stg_health__bjaz_hm_clm_register_extn') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by anaesthetist_fee, eligible_room_category, icu_rent_amount, nursing_charges, ot_charges, room_rent_amount, surgeon_fee, treatment_type) = 1
    ),
         t11 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(date_admission)), '') as admission_date,
            nullif(trim(to_varchar(ailment)), '') as ailment_description,
            nullif(trim(to_varchar(co_paymnt_deduction)), '') as co_pay_amount,
            nullif(trim(to_varchar(final_diagnosis)), '') as diagnosis_code,
            nullif(trim(to_varchar(reasons)), '') as disallowance_reason,
            nullif(trim(to_varchar(not_payable_exp)), '') as disallowed_amount,
            nullif(trim(to_varchar(date_of_discharge)), '') as discharge_date,
            nullif(trim(to_varchar(final_bill_amt)), '') as final_bill_amount,
            nullif(trim(to_varchar(provider_no)), '') as hospital_reference,
            nullif(trim(to_varchar(icd_code)), '') as icd_code,
            nullif(trim(to_varchar(network)), '') as network_hospital_indicator,
            nullif(trim(to_varchar(non_payable_def_amt)), '') as other_deduction_amount,
            nullif(trim(to_varchar(primary_proc)), '') as procedure_code,
            nullif(trim(to_varchar(level_of_care)), '') as treatment_type
        from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by admission_date, ailment_description, co_pay_amount, diagnosis_code, disallowance_reason, disallowed_amount, discharge_date, final_bill_amount, hospital_reference, icd_code, network_hospital_indicator, other_deduction_amount, procedure_code, treatment_type) = 1
    ),
         t12 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(package_charge)), '') as actual_package_amount
        from {{ ref('stg_health__bjaz_hm_doctor_assess') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by actual_package_amount) = 1
    ),
         t13 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(package_charge)), '') as actual_package_amount
        from {{ ref('stg_health__bjaz_hm_doctor_multi_assess') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by actual_package_amount) = 1
    ),
         t14 as (
        select distinct
            clid as parent_bk,
            nullif(trim(to_varchar(package_charges)), '') as actual_package_amount,
            nullif(trim(to_varchar(actual_doa)), '') as admission_date,
            nullif(trim(to_varchar(diagnosis_detail)), '') as ailment_description,
            nullif(trim(to_varchar(ambulance)), '') as ambulance_charges,
            nullif(trim(to_varchar(co_payment)), '') as co_pay_amount,
            nullif(trim(to_varchar(final_diagnosis)), '') as diagnosis_code,
            nullif(trim(to_varchar(hospital_disallow_amt_reason)), '') as disallowance_reason,
            nullif(trim(to_varchar(hospital_disallowed_amt)), '') as disallowed_amount,
            nullif(trim(to_varchar(actual_dod)), '') as discharge_date,
            nullif(trim(to_varchar(eligible_room_category)), '') as eligible_room_category,
            nullif(trim(to_varchar(eligible_room_rent)), '') as eligible_room_rent,
            nullif(trim(to_varchar(expected_dod)), '') as expected_discharge_date,
            nullif(trim(to_varchar(total_bill)), '') as final_bill_amount,
            nullif(trim(to_varchar(icd_code)), '') as icd_code,
            nullif(trim(to_varchar(icu_charges)), '') as icu_charges_amount,
            nullif(trim(to_varchar(criti_unit_room_rent_per_day)), '') as icu_rent_amount,
            nullif(trim(to_varchar(implant_charges)), '') as implant_cost,
            nullif(trim(to_varchar(ip_no)), '') as ipd_number,
            nullif(trim(to_varchar(miscellaneous)), '') as miscellaneous_charges_amount,
            nullif(trim(to_varchar(discount)), '') as network_discount_amount,
            nullif(trim(to_varchar(nursing_charges)), '') as nursing_charges,
            nullif(trim(to_varchar(ot_charges)), '') as ot_charges,
            nullif(trim(to_varchar(other_deduction)), '') as other_deduction_amount,
            nullif(trim(to_varchar(pharmacy)), '') as pharmacy_amount,
            nullif(trim(to_varchar(post_hosp_charges)), '') as post_hospitalisation_amount,
            nullif(trim(to_varchar(pre_hosp_charges)), '') as pre_hospitalisation_amount,
            nullif(trim(to_varchar(dig_procedure)), '') as procedure_description,
            nullif(trim(to_varchar(room_category)), '') as room_category,
            nullif(trim(to_varchar(room_charges)), '') as room_rent_amount,
            nullif(trim(to_varchar(surgeon_charges)), '') as surgeon_fee,
            nullif(trim(to_varchar(medical_or_surgical)), '') as surgery_indicator,
            nullif(trim(to_varchar(treatment_type)), '') as treatment_type
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where clid is not null
        qualify row_number() over (partition by parent_bk order by actual_package_amount, admission_date, ailment_description, ambulance_charges, co_pay_amount, diagnosis_code, disallowance_reason, disallowed_amount, discharge_date, eligible_room_category, eligible_room_rent, expected_discharge_date, final_bill_amount, icd_code, icu_charges_amount, icu_rent_amount, implant_cost, ipd_number, miscellaneous_charges_amount, network_discount_amount, nursing_charges, ot_charges, other_deduction_amount, pharmacy_amount, post_hospitalisation_amount, pre_hospitalisation_amount, procedure_description, room_category, room_rent_amount, surgeon_fee, surgery_indicator, treatment_type) = 1
    ),
         t15 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(cashless_in_no)), '') as cashless_authorisation_number
        from {{ ref('stg_health__bjaz_hm_inward_autoallocation') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by cashless_authorisation_number) = 1
    ),
         t16 as (
        select distinct
            clid as parent_bk,
            nullif(trim(to_varchar(expected_dod)), '') as expected_discharge_date
        from {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
        where clid is not null
        qualify row_number() over (partition by parent_bk order by expected_discharge_date) = 1
    ),
         t17 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(tot_claimed_amt)), '') as final_bill_amount
        from {{ ref('stg_health__bjaz_hm_pro_assessment') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by final_bill_amount) = 1
    ),
         t18 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(date_admission)), '') as admission_date,
            nullif(trim(to_varchar(present_complain)), '') as ailment_description,
            nullif(trim(to_varchar(date_discharge)), '') as discharge_date,
            nullif(trim(to_varchar(cost_of_treatment)), '') as final_bill_amount,
            nullif(trim(to_varchar(bill_remarks)), '') as health_claim_remarks,
            nullif(trim(to_varchar(pat_days_in_hospit)), '') as length_of_stay,
            nullif(trim(to_varchar(treating_doctor_name)), '') as treating_doctor_name,
            nullif(trim(to_varchar(line_of_treatment)), '') as treatment_type
        from {{ ref('stg_health__bjaz_investigation_reports') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by admission_date, ailment_description, discharge_date, final_bill_amount, health_claim_remarks, length_of_stay, treating_doctor_name, treatment_type) = 1
    ),
         t19 as (
        select distinct
            claim_no as parent_bk,
            nullif(trim(to_varchar(actual_package_amount)), '') as actual_package_amount,
            nullif(trim(to_varchar(preauth_no)), '') as cashless_authorisation_number,
            nullif(trim(to_varchar(copay_amount)), '') as co_pay_amount,
            nullif(trim(to_varchar(total_bill_amount)), '') as final_bill_amount,
            nullif(trim(to_varchar(preauth_amount)), '') as pre_authorisation_amount,
            nullif(trim(to_varchar(provider_remarks)), '') as pre_authorisation_remarks
        from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
        where claim_no is not null
        qualify row_number() over (partition by parent_bk order by actual_package_amount, cashless_authorisation_number, co_pay_amount, final_bill_amount, pre_authorisation_amount, pre_authorisation_remarks) = 1
    ),
         t20 as (
        select distinct
            bjaz_claim_id as parent_bk,
            nullif(trim(to_varchar(doa)), '') as admission_date,
            nullif(trim(to_varchar(diagnosis)), '') as ailment_description,
            nullif(trim(to_varchar(ambulance_charges)), '') as ambulance_charges,
            nullif(trim(to_varchar(anesthesia_fees)), '') as anaesthetist_fee,
            nullif(trim(to_varchar(pre_auth_letter_no)), '') as cashless_authorisation_number,
            nullif(trim(to_varchar(co_pay_amount)), '') as co_pay_amount,
            nullif(trim(to_varchar(diagnosis_code_level1)), '') as diagnosis_code,
            nullif(trim(to_varchar(deduction_reason)), '') as disallowance_reason,
            nullif(trim(to_varchar(dod)), '') as discharge_date,
            nullif(trim(to_varchar(claim_amount)), '') as final_bill_amount,
            nullif(trim(to_varchar(icucharges)), '') as icu_charges_amount,
            nullif(trim(to_varchar(investigation_charges)), '') as investigation_charges,
            nullif(trim(to_varchar(misc)), '') as miscellaneous_charges_amount,
            nullif(trim(to_varchar(nursing_fees)), '') as nursing_charges,
            nullif(trim(to_varchar(otcharges)), '') as ot_charges,
            nullif(trim(to_varchar(medicines)), '') as pharmacy_amount,
            nullif(trim(to_varchar(pre_auth_amount)), '') as pre_authorisation_amount,
            nullif(trim(to_varchar(procedure_codes_level1)), '') as procedure_code,
            nullif(trim(to_varchar(procedure_description_level1)), '') as procedure_description,
            nullif(trim(to_varchar(room_charges)), '') as room_rent_amount,
            nullif(trim(to_varchar(surgeon_charges)), '') as surgeon_fee,
            nullif(trim(to_varchar(treatment)), '') as treatment_type
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where bjaz_claim_id is not null
        qualify row_number() over (partition by parent_bk order by admission_date, ailment_description, ambulance_charges, anaesthetist_fee, cashless_authorisation_number, co_pay_amount, diagnosis_code, disallowance_reason, discharge_date, final_bill_amount, icu_charges_amount, investigation_charges, miscellaneous_charges_amount, nursing_charges, ot_charges, pharmacy_amount, pre_authorisation_amount, procedure_code, procedure_description, room_rent_amount, surgeon_fee, treatment_type) = 1
    ),
         t21 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(treating_doctor)), '') as treating_doctor_name
        from {{ ref('stg_health__bjaz_tpclm_court_dtl_extn') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by treating_doctor_name) = 1
    ),
         t22 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(final_bill)), '') as final_bill_amount
        from {{ ref('stg_health__bjaz_tpclm_hospital_dtl') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by final_bill_amount) = 1
    ),
         t23 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(admission_date)), '') as admission_date,
            nullif(trim(to_varchar(admission_time)), '') as admission_time,
            nullif(trim(to_varchar(reason_bill_rejection)), '') as disallowance_reason,
            nullif(trim(to_varchar(discharge_date)), '') as discharge_date,
            nullif(trim(to_varchar(discharge_time)), '') as discharge_time,
            nullif(trim(to_varchar(treatment_type)), '') as treatment_type
        from {{ ref('stg_health__bjaz_tpclm_hospital_tran_dtl') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by admission_date, admission_time, disallowance_reason, discharge_date, discharge_time, treatment_type) = 1
    ),
         t24 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(diagnosis_remarks)), '') as ailment_description
        from {{ ref('stg_health__bjaz_wg_inspection_dtls') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by ailment_description) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk, t9.parent_bk, t10.parent_bk, t11.parent_bk, t12.parent_bk, t13.parent_bk, t14.parent_bk, t15.parent_bk, t16.parent_bk, t17.parent_bk, t18.parent_bk, t19.parent_bk, t20.parent_bk, t21.parent_bk, t22.parent_bk, t23.parent_bk, t24.parent_bk) as parent_bk,
        coalesce(t12.actual_package_amount, t13.actual_package_amount, t14.actual_package_amount, t19.actual_package_amount) as actual_package_amount,
        coalesce(t0.admission_date, t9.admission_date, t11.admission_date, t14.admission_date, t18.admission_date, t20.admission_date, t23.admission_date) as admission_date,
        coalesce(t23.admission_time) as admission_time,
        coalesce(t0.ailment_description, t1.ailment_description, t2.ailment_description, t9.ailment_description, t11.ailment_description, t14.ailment_description, t18.ailment_description, t20.ailment_description, t24.ailment_description) as ailment_description,
        coalesce(t3.ambulance_charges, t14.ambulance_charges, t20.ambulance_charges) as ambulance_charges,
        coalesce(t10.anaesthetist_fee, t20.anaesthetist_fee) as anaesthetist_fee,
        coalesce(t0.cashless_authorisation_number, t7.cashless_authorisation_number, t9.cashless_authorisation_number, t15.cashless_authorisation_number, t19.cashless_authorisation_number, t20.cashless_authorisation_number) as cashless_authorisation_number,
        coalesce(t11.co_pay_amount, t14.co_pay_amount, t19.co_pay_amount, t20.co_pay_amount) as co_pay_amount,
        coalesce(t11.diagnosis_code, t14.diagnosis_code, t20.diagnosis_code) as diagnosis_code,
        coalesce(t11.disallowance_reason, t14.disallowance_reason, t20.disallowance_reason, t23.disallowance_reason) as disallowance_reason,
        coalesce(t4.disallowed_amount, t8.disallowed_amount, t11.disallowed_amount, t14.disallowed_amount) as disallowed_amount,
        coalesce(t9.discharge_date, t11.discharge_date, t14.discharge_date, t18.discharge_date, t20.discharge_date, t23.discharge_date) as discharge_date,
        coalesce(t23.discharge_time) as discharge_time,
        coalesce(t5.eligible_room_category, t6.eligible_room_category, t10.eligible_room_category, t14.eligible_room_category) as eligible_room_category,
        coalesce(t5.eligible_room_rent, t6.eligible_room_rent, t14.eligible_room_rent) as eligible_room_rent,
        coalesce(t0.expected_discharge_date, t14.expected_discharge_date, t16.expected_discharge_date) as expected_discharge_date,
        coalesce(t11.final_bill_amount, t14.final_bill_amount, t17.final_bill_amount, t18.final_bill_amount, t19.final_bill_amount, t20.final_bill_amount, t22.final_bill_amount) as final_bill_amount,
        coalesce(t3.health_claim_remarks, t9.health_claim_remarks, t18.health_claim_remarks) as health_claim_remarks,
        coalesce(t11.hospital_reference) as hospital_reference,
        coalesce(t11.icd_code, t14.icd_code) as icd_code,
        coalesce(t14.icu_charges_amount, t20.icu_charges_amount) as icu_charges_amount,
        coalesce(t5.icu_rent_amount, t6.icu_rent_amount, t10.icu_rent_amount, t14.icu_rent_amount) as icu_rent_amount,
        coalesce(t14.implant_cost) as implant_cost,
        coalesce(t9.implant_indicator) as implant_indicator,
        coalesce(t20.investigation_charges) as investigation_charges,
        coalesce(t5.ipd_number, t6.ipd_number, t14.ipd_number) as ipd_number,
        coalesce(t18.length_of_stay) as length_of_stay,
        coalesce(t14.miscellaneous_charges_amount, t20.miscellaneous_charges_amount) as miscellaneous_charges_amount,
        coalesce(t4.network_discount_amount, t6.network_discount_amount, t14.network_discount_amount) as network_discount_amount,
        coalesce(t9.network_hospital_indicator, t11.network_hospital_indicator) as network_hospital_indicator,
        coalesce(t10.nursing_charges, t14.nursing_charges, t20.nursing_charges) as nursing_charges,
        coalesce(t10.ot_charges, t14.ot_charges, t20.ot_charges) as ot_charges,
        coalesce(t11.other_deduction_amount, t14.other_deduction_amount) as other_deduction_amount,
        coalesce(t14.pharmacy_amount, t20.pharmacy_amount) as pharmacy_amount,
        coalesce(t3.post_hospitalisation_amount, t14.post_hospitalisation_amount) as post_hospitalisation_amount,
        coalesce(t19.pre_authorisation_amount, t20.pre_authorisation_amount) as pre_authorisation_amount,
        coalesce(t19.pre_authorisation_remarks) as pre_authorisation_remarks,
        coalesce(t14.pre_hospitalisation_amount) as pre_hospitalisation_amount,
        coalesce(t11.procedure_code, t20.procedure_code) as procedure_code,
        coalesce(t14.procedure_description, t20.procedure_description) as procedure_description,
        coalesce(t5.room_category, t6.room_category, t9.room_category, t14.room_category) as room_category,
        coalesce(t5.room_rent_amount, t6.room_rent_amount, t10.room_rent_amount, t14.room_rent_amount, t20.room_rent_amount) as room_rent_amount,
        cast(null as varchar) as specialty,
        coalesce(t10.surgeon_fee, t14.surgeon_fee, t20.surgeon_fee) as surgeon_fee,
        coalesce(t9.surgery_indicator, t14.surgery_indicator) as surgery_indicator,
        coalesce(t0.treating_doctor_name, t3.treating_doctor_name, t18.treating_doctor_name, t21.treating_doctor_name) as treating_doctor_name,
        coalesce(t3.treatment_type, t9.treatment_type, t10.treatment_type, t11.treatment_type, t14.treatment_type, t18.treatment_type, t20.treatment_type, t23.treatment_type) as treatment_type,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_CLM_PRE_AUTH_HLT_DTLS' end, case when t1.parent_bk is not null then 'BJAZ_CLM_WG_TRANS_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_CLM_WG_TRANS_DTLS_HIST' end, case when t3.parent_bk is not null then 'BJAZ_FPLM_OD_HOSPITAL_DETAILS' end, case when t4.parent_bk is not null then 'BJAZ_HAT_DEDUTION_SUMMARY' end, case when t5.parent_bk is not null then 'BJAZ_HM_BILL_DETAIL' end, case when t6.parent_bk is not null then 'BJAZ_HM_BILL_DETAIL_OCR' end, case when t7.parent_bk is not null then 'BJAZ_HM_CASHLESS_INWARD' end, case when t8.parent_bk is not null then 'BJAZ_HM_CLAIM_PAYMENT' end, case when t9.parent_bk is not null then 'BJAZ_HM_CLM_REGISTER' end, case when t10.parent_bk is not null then 'BJAZ_HM_CLM_REGISTER_EXTN' end, case when t11.parent_bk is not null then 'BJAZ_HM_COINSU_CLM_DTLS' end, case when t12.parent_bk is not null then 'BJAZ_HM_DOCTOR_ASSESS' end, case when t13.parent_bk is not null then 'BJAZ_HM_DOCTOR_MULTI_ASSESS' end, case when t14.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t15.parent_bk is not null then 'BJAZ_HM_INWARD_AUTOALLOCATION' end, case when t16.parent_bk is not null then 'BJAZ_HM_PREAUTH_ENHANCE' end, case when t17.parent_bk is not null then 'BJAZ_HM_PRO_ASSESSMENT' end, case when t18.parent_bk is not null then 'BJAZ_INVESTIGATION_REPORTS' end, case when t19.parent_bk is not null then 'BJAZ_REMEDINET_CLAIM_DETAILS' end, case when t20.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end, case when t21.parent_bk is not null then 'BJAZ_TPCLM_COURT_DTL_EXTN' end, case when t22.parent_bk is not null then 'BJAZ_TPCLM_HOSPITAL_DTL' end, case when t23.parent_bk is not null then 'BJAZ_TPCLM_HOSPITAL_TRAN_DTL' end, case when t24.parent_bk is not null then 'BJAZ_WG_INSPECTION_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    full outer join t7 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk) = t7.parent_bk
    full outer join t8 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk) = t8.parent_bk
    full outer join t9 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk) = t9.parent_bk
    full outer join t10 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk) = t10.parent_bk
    full outer join t11 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk) = t11.parent_bk
    full outer join t12 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk) = t12.parent_bk
    full outer join t13 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk) = t13.parent_bk
    full outer join t14 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk) = t14.parent_bk
    full outer join t15 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk) = t15.parent_bk
    full outer join t16 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk) = t16.parent_bk
    full outer join t17 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk) = t17.parent_bk
    full outer join t18 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk) = t18.parent_bk
    full outer join t19 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk) = t19.parent_bk
    full outer join t20 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk) = t20.parent_bk
    full outer join t21 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk) = t21.parent_bk
    full outer join t22 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk) = t22.parent_bk
    full outer join t23 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk) = t23.parent_bk
    full outer join t24 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk) = t24.parent_bk
    )
