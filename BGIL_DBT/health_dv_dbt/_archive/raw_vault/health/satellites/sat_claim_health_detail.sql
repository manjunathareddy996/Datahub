{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CLAIM_HEALTH_DETAIL
-- Parent: HUB_CLAIM
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_claim_health_detail') }}. No joins in THIS load.

with source_data as (

    select parent_bk, actual_package_amount, admission_date, admission_time, ailment_description, ambulance_charges, anaesthetist_fee, cashless_authorisation_number, co_pay_amount, diagnosis_code, disallowance_reason, disallowed_amount, discharge_date, discharge_time, eligible_room_category, eligible_room_rent, expected_discharge_date, final_bill_amount, health_claim_remarks, hospital_reference, icd_code, icu_charges_amount, icu_rent_amount, implant_cost, implant_indicator, investigation_charges, ipd_number, length_of_stay, miscellaneous_charges_amount, network_discount_amount, network_hospital_indicator, nursing_charges, ot_charges, other_deduction_amount, pharmacy_amount, post_hospitalisation_amount, pre_authorisation_amount, pre_authorisation_remarks, pre_hospitalisation_amount, procedure_code, procedure_description, room_category, room_rent_amount, specialty, surgeon_fee, surgery_indicator, treating_doctor_name, treatment_type, record_source
    from {{ ref('int_health__sat_claim_health_detail') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'parent_bk']) }} as claim_hkey,
        parent_bk,
        actual_package_amount, admission_date, admission_time, ailment_description, ambulance_charges, anaesthetist_fee, cashless_authorisation_number, co_pay_amount, diagnosis_code, disallowance_reason, disallowed_amount, discharge_date, discharge_time, eligible_room_category, eligible_room_rent, expected_discharge_date, final_bill_amount, health_claim_remarks, hospital_reference, icd_code, icu_charges_amount, icu_rent_amount, implant_cost, implant_indicator, investigation_charges, ipd_number, length_of_stay, miscellaneous_charges_amount, network_discount_amount, network_hospital_indicator, nursing_charges, ot_charges, other_deduction_amount, pharmacy_amount, post_hospitalisation_amount, pre_authorisation_amount, pre_authorisation_remarks, pre_hospitalisation_amount, procedure_code, procedure_description, room_category, room_rent_amount, specialty, surgeon_fee, surgery_indicator, treating_doctor_name, treatment_type,
        record_source
    from source_data

),

hashed as (

    select
        claim_hkey,
        actual_package_amount, admission_date, admission_time, ailment_description, ambulance_charges, anaesthetist_fee, cashless_authorisation_number, co_pay_amount, diagnosis_code, disallowance_reason, disallowed_amount, discharge_date, discharge_time, eligible_room_category, eligible_room_rent, expected_discharge_date, final_bill_amount, health_claim_remarks, hospital_reference, icd_code, icu_charges_amount, icu_rent_amount, implant_cost, implant_indicator, investigation_charges, ipd_number, length_of_stay, miscellaneous_charges_amount, network_discount_amount, network_hospital_indicator, nursing_charges, ot_charges, other_deduction_amount, pharmacy_amount, post_hospitalisation_amount, pre_authorisation_amount, pre_authorisation_remarks, pre_hospitalisation_amount, procedure_code, procedure_description, room_category, room_rent_amount, specialty, surgeon_fee, surgery_indicator, treating_doctor_name, treatment_type,
        {{ dbt_utils.generate_surrogate_key(['actual_package_amount', 'admission_date', 'admission_time', 'ailment_description', 'ambulance_charges', 'anaesthetist_fee', 'cashless_authorisation_number', 'co_pay_amount', 'diagnosis_code', 'disallowance_reason', 'disallowed_amount', 'discharge_date', 'discharge_time', 'eligible_room_category', 'eligible_room_rent', 'expected_discharge_date', 'final_bill_amount', 'health_claim_remarks', 'hospital_reference', 'icd_code', 'icu_charges_amount', 'icu_rent_amount', 'implant_cost', 'implant_indicator', 'investigation_charges', 'ipd_number', 'length_of_stay', 'miscellaneous_charges_amount', 'network_discount_amount', 'network_hospital_indicator', 'nursing_charges', 'ot_charges', 'other_deduction_amount', 'pharmacy_amount', 'post_hospitalisation_amount', 'pre_authorisation_amount', 'pre_authorisation_remarks', 'pre_hospitalisation_amount', 'procedure_code', 'procedure_description', 'room_category', 'room_rent_amount', 'specialty', 'surgeon_fee', 'surgery_indicator', 'treating_doctor_name', 'treatment_type']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by claim_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    claim_hkey,
    actual_package_amount, admission_date, admission_time, ailment_description, ambulance_charges, anaesthetist_fee, cashless_authorisation_number, co_pay_amount, diagnosis_code, disallowance_reason, disallowed_amount, discharge_date, discharge_time, eligible_room_category, eligible_room_rent, expected_discharge_date, final_bill_amount, health_claim_remarks, hospital_reference, icd_code, icu_charges_amount, icu_rent_amount, implant_cost, implant_indicator, investigation_charges, ipd_number, length_of_stay, miscellaneous_charges_amount, network_discount_amount, network_hospital_indicator, nursing_charges, ot_charges, other_deduction_amount, pharmacy_amount, post_hospitalisation_amount, pre_authorisation_amount, pre_authorisation_remarks, pre_hospitalisation_amount, procedure_code, procedure_description, room_category, room_rent_amount, specialty, surgeon_fee, surgery_indicator, treating_doctor_name, treatment_type,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.claim_hkey = d.claim_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
