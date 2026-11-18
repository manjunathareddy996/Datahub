{{ config(materialized='view') }}

-- UNPIVOT for SAT_PARTY_PROVIDER_CAPABILITY from BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- 135 row(s), ONE PER INSTANCE of FACILITYCODE.
-- The instance label is the mapper's own child_key_value, which keeps this in the
-- vocabulary partner_dv_dbt already writes.

    select
        bagic_employee_code as parent_bk,
        'AMBULANCE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        ambulance as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(ambulance)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'BIOCHEMISTRY_LAB' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        bio_chemistry as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(bio_chemistry)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'BIOMEDICAL_WASTE_FACILITY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        biomedical_waste_facility as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(biomedical_waste_facility)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'BLOOD_BANK_24_HR' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        blood_bank_24_hrs as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(blood_bank_24_hrs)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'BOYLES_APPARATUS' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        boyles_apparatus as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(boyles_apparatus)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'BRONCHOSCOPY_LAB' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        bronchoscopy_lab as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(bronchoscopy_lab)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'BURNS_SPECIALITY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        burn as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(burn)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'BURN_WARD' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        burn_ward as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(burn_ward)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'CARDIOLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cardiology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(cardiology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'CASE_OPINION_CAPABILITY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        ability_to_give_opinion_on_cases as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(ability_to_give_opinion_on_cases)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'CATH_LAB' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cath_lab as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(cath_lab)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'CENTRALISED_OXYGEN_SUPPLY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        centralized_oxygen_connections as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(centralized_oxygen_connections)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'CHEMOTHERAPY_UNIT' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        chemotherapy_unit as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(chemotherapy_unit)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'CLINICAL_PATHOLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        clinical_pathology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(clinical_pathology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'COBALT_UNIT' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cobalt_unit as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(cobalt_unit)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'COMPUTER@TOTAL' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        no_of_computerstotal as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(no_of_computerstotal)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'CRITICAL_CARE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        critical_care as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(critical_care)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'CSSD' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        centralize_sterile_supply_department as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(centralize_sterile_supply_department)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'CT_SCAN' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        ct_scan as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(ct_scan)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'Computer' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        no_of_computersfor_bagic as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(no_of_computersfor_bagic)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'DAY_CARE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        day_care as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(day_care)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'DAY_CARE_BED' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        day_care_bed as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(day_care_bed)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'DELUXE_BED' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        deluxe_beds as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(deluxe_beds)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'DENTAL' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        dental as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(dental)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'DERMATOLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        dermatology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(dermatology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'DIALYSIS_UNIT' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        dialysis_unit as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(dialysis_unit)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'DISASTER_CRISIS_MANAGEMENT' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        disaster_or_crisis_management as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(disaster_or_crisis_management)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ECG' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        ecg as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(ecg)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ECHOCARDIOGRAPHY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        echo as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(echo)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'EEG' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        eeg as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(eeg)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ELECTRONIC_GADGET_SPY_CAM_RECORDER@BAGIC' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        electronic_gadgetsspy_cam_recorderfor_bagic as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(electronic_gadgetsspy_cam_recorderfor_bagic)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ELECTRONIC_GADGET_SPY_CAM_RECORDER@TOTAL' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        electronic_gadgetsspy_cam_recordertotal as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(electronic_gadgetsspy_cam_recordertotal)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'EMERGENCY_CASUALTY_BED' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        emergencycasuality_bed as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(emergencycasuality_bed)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'EMERGENCY_SERVICE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        emergency as available_indicator,
        emergency_value as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(emergency)), '') is not null or nullif(trim(to_varchar(emergency_value)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'EMG' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        emg as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(emg)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ENDOCRINOLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        endocrinology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(endocrinology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ENT' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        ent as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(ent)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'FIRE_SAFETY_EQUIPMENT' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        fire_safety_equipment as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(fire_safety_equipment)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'FOS_FEET_ON_STREET' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        fosfeet_on_street as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(fosfeet_on_street)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'FOS_FEET_ON_STREET@BAGIC' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        fosfeet_on_street_for_bagic as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(fosfeet_on_street_for_bagic)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'FOS_FEET_ON_STREET@TOTAL' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        fosfeet_on_street_total as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(fosfeet_on_street_total)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'FULL_TIME_DOCTOR_MCI_QUALIFIED' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        total_no_of_full_time_doctors_with_qualification_approved_by_mci_in_the_rolls_of_the_hospital as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(total_no_of_full_time_doctors_with_qualification_approved_by_mci_in_the_rolls_of_the_hospital)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'GAMMA_KNIFE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        gamma_knife as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(gamma_knife)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'GASTROENTEROLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        gastroenterology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(gastroenterology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'GENERAL_MEDICINE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        general_medicine as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(general_medicine)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'GENERAL_SURGERY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        general_surgery as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(general_surgery)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'GENERAL_WARD_BED_AC' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        general_ward_ac as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(general_ward_ac)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'GENERAL_WARD_BED_NON_AC' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        general_ward_non_ac as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(general_ward_non_ac)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'GENITOURINARY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        genitourinary as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(genitourinary)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'HAEMATOLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        hematology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(hematology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'HDU' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        hdu as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(hdu)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'HEALTH_VIDEO' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        health_video as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(health_video)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'HELP_DESK' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        help_desk as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(help_desk)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'HOLTER_MONITORING' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        holter as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(holter)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ICD_10_CODING' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        use_of_icd_10 as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(use_of_icd_10)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ICD_DEFIBRILLATOR' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        icd as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(icd)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ICU_BED' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        icu_beds as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(icu_beds)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'INCUBATOR' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        incubators as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(incubators)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'INFECTION_CONTROL' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        hospital_infection_control_measures as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(hospital_infection_control_measures)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'INFECTIOUS_DISEASE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        infectious_disease as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(infectious_disease)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'INFRASTRUCTURE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        infrastructure as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(infrastructure)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'INTERNET_ACCESS' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        internet_access as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(internet_access)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'INTERNET_ACCESS@DFADVOCATE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        internet_accessdfadvocate as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(internet_accessdfadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'INTERNET_ACCESS@HCADVOCATE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        internet_accesshcadvocate as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(internet_accesshcadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'INTERNET_ACCESS@LAWYER' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        internet_accesslawyer as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(internet_accesslawyer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'INTERNET_ACCESS@RETAINER' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        internet_accessretainer as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(internet_accessretainer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'INTERNET_ACCESS@STADVOCATE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        internet_accessstadvocate as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(internet_accessstadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'INTERNET_ACCESS@TRADVOCATE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        internet_accesstradvocate as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(internet_accesstradvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'IN_HOUSE_DOCTORS' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        availability_of_in_house_doctors as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(availability_of_in_house_doctors)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'IN_HOUSE_PHARMACY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        in_house_pharmacy as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(in_house_pharmacy)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ISOLATION_WARD' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        isolation_wards as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(isolation_wards)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'JCI_ACCREDITATION' as facilitycode,
        jci_accreditation as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(jci_accreditation)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LAPAROSCOPIC_SURGERY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        laparoscopic_surgery as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(laparoscopic_surgery)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LASER' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        lasers as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(lasers)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LIBRARY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        availability_of_library as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(availability_of_library)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LIBRARY@DFADVOCATE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        availability_librarydfadvocate as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(availability_librarydfadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LIBRARY@HCADVOCATE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        availability_libraryhcadvocate as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(availability_libraryhcadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LIBRARY@LAWYER' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        availability_librarylawyer as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(availability_librarylawyer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LIBRARY@RETAINER' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        availability_libraryretainer as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(availability_libraryretainer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LIBRARY@STADVOCATE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        availability_librarystadvocate as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(availability_librarystadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LIBRARY@TRADVOCATE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        availability_librarytradvocate as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(availability_librarytradvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LINEAR_ACCELERATOR' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        linear_accelerator as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(linear_accelerator)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'MBBS_DOCTOR_ICU' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        no_of_doctors_with_the_qualification_of_mbbs_available_for_icu_exclusively_taking_all_the_shifts_together as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(no_of_doctors_with_the_qualification_of_mbbs_available_for_icu_exclusively_taking_all_the_shifts_together)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'MEDICAL_RECORDS_DEPARTMENT' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        medical_records_dept as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(medical_records_dept)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'MRI' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        mri as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(mri)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'NEPHROLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        nephrology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(nephrology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'NEUROLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        neurology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(neurology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'NICU_BED' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        nicu_beds as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(nicu_beds)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'NURSES' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        availability_of_nurses as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(availability_of_nurses)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'OBSTETRICS_GYNAECOLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        obs_and_gynecology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(obs_and_gynecology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'OFFICE_YARD_SPACE_SQ_FT@TOTAL' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        office_yard_space_in_sq_ft_total as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(office_yard_space_in_sq_ft_total)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ONCOLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        oncology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(oncology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ONLINE_JOURNAL_ACCESS' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        access_to_online_journal as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(access_to_online_journal)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ONLINE_JOURNAL_ACCESS@DFADVOCATE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        access_online_journaldfadvocate as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(access_online_journaldfadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ONLINE_JOURNAL_ACCESS@HCADVOCATE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        access_online_journalhcadvocate as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(access_online_journalhcadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ONLINE_JOURNAL_ACCESS@LAWYER' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        access_online_journallawyer as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(access_online_journallawyer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ONLINE_JOURNAL_ACCESS@RETAINER' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        access_online_journalretainer as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(access_online_journalretainer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ONLINE_JOURNAL_ACCESS@STADVOCATE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        access_online_journalstadvocate as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(access_online_journalstadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ONLINE_JOURNAL_ACCESS@TRADVOCATE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        access_online_journaltradvocate as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(access_online_journaltradvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'OPERATION_THEATRE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        no_of_operation_theatre as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(no_of_operation_theatre)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'OPERATION_THEATRE_MAJOR' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        no_of_operation_theatre_major as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(no_of_operation_theatre_major)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'OPERATION_THEATRE_MINOR' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        no_of_operation_theatre_minor as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(no_of_operation_theatre_minor)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'OPHTHALMOLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        ophthalmology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(ophthalmology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ORTHOPAEDICS' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        orthopedics as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(orthopedics)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'OT_LAMINAR_AIR_FLOW' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        ot_laminar_air_flow as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(ot_laminar_air_flow)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'PAEDIATRICS' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        pediatric as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(pediatric)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'PAEDIATRIC_NEONATAL' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        pediatricneonatal as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(pediatricneonatal)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'PFT_SPIROMETRY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        pft_spirometry as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(pft_spirometry)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'PHOTOTHERAPY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        phototherapy as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(phototherapy)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'PHYSIOTHERAPY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        physiotherapy as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(physiotherapy)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'PICU_BED' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        picu_bed as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(picu_bed)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'PLASTIC_SURGERY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        plastic_surgery as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(plastic_surgery)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'PORTABLE_ECG_CARDIAC_MONITOR' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        portable_ecg_cardiac_monitor as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(portable_ecg_cardiac_monitor)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'PORTABLE_X_RAY_IN_OT' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        portable_x_ray_within_ot as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(portable_x_ray_within_ot)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'POST_GRADUATE_DOCTOR_ICU' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        total_no_of_post_graduate_md_anesthesia_gen_med_etc_qualified_doctors_exclusively_available_for_icu as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(total_no_of_post_graduate_md_anesthesia_gen_med_etc_qualified_doctors_exclusively_available_for_icu)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'POWER_BACKUP_24_HR' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        "24_HR_POWER_BACKUP" as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar("24_HR_POWER_BACKUP")), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'PRINTER@TOTAL' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        no_of_printerstotal as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(no_of_printerstotal)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'PROVIDER_ACCREDITATION' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        accreditation as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(accreditation)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'PULMONOLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        pulmonology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(pulmonology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'Printer' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        no_of_printersfor_bagic as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(no_of_printersfor_bagic)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'QUALIFIED_NURSE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        total_no_of_qualified_nurses_bsc_nursing_gnm_in_the_hospital as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(total_no_of_qualified_nurses_bsc_nursing_gnm_in_the_hospital)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'RADIO_IMMUNO_ASSAY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        radio_immuno_assay as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(radio_immuno_assay)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'RECOVERY_ROOM' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        recovery_rooms as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(recovery_rooms)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'RHEUMATOLOGY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        rheumatology as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(rheumatology)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'SCANNER@TOTAL' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        no_of_scannerstotal as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(no_of_scannerstotal)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'STERILISATION_AREA' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        separate_sterilization_area as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(separate_sterilization_area)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'SURGERY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        surgery_details as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(surgery_details)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'SURGICAL_ICU' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        surgical_icu as available_indicator,
        cast(null as varchar) as capability_remarks,
        sicu_bed as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(surgical_icu)), '') is not null or nullif(trim(to_varchar(sicu_bed)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'Scanner' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        no_of_scannersfor_bagic as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(no_of_scannersfor_bagic)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'TOTAL_BED' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        total_beds as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(total_beds)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'TRAUMA' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        trauma as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(trauma)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'TREADMILL_TEST' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        treadmill_test as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(treadmill_test)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'ULTRASOUND' as facilitycode,
        ultrasoundscanning_facility_register_with_district_health_and_family_welfare_officer as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        ultra_sound as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(ultra_sound)), '') is not null or nullif(trim(to_varchar(ultrasoundscanning_facility_register_with_district_health_and_family_welfare_officer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'X_KNIFE' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        x_knife as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(x_knife)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'X_RAY' as facilitycode,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        x_ray as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_count,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(x_ray)), '') is not null
