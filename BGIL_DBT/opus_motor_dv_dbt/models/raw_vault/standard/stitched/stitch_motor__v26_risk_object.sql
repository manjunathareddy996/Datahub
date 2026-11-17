-- CENTRAL VIEW v26_risk_object -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BA_QUOTE_MOT_DTLS
--   BGIL_MOTOR_WEBSERVICE_INFO_EQM
--   BGIL_MOTOR_WS_PLAN_DETAILS_EQM
--   BJAZ_AGENCY_MOT_WAR_DTLS
--   BJAZ_CVTP_WS_DATA
--   BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
--   BJAZ_MOTORTHEFT_CASE_DTLS
--   BJAZ_MOTOR_WEBSERVICE_INFO
--   BJAZ_MOTOR_WS_PLAN_DETAILS
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_RENEWAL_EXTN
--   BJAZ_MOT_RENEWAL_HIST
--   BJAZ_MOT_RNW_VALIDATE_VEH_DTLS
--   BJAZ_MOT_RN_CLS_VEH_DTLS_HIST
--   BJAZ_MOT_WAR_CHILD_DTLS
--   BJAZ_MOT_WINBACK_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_PAYMOTORTHEFT_DTLS
--   BJAZ_SCR_MOT_VEH_DTLS
--   BJAZ_VAHAN_AUTO_ENDT_LOG
--   BJAZ_VAHAN_MOTOR_DTLS
--   BJAZ_WAP_MOT_ADD_QSTN_DTLS
--   VEHICLE_BLOCK_MASTER
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_RISK_MOTOR_VEHICLE
--   SAT_AUG_RISK_MOTOR_VERIFICATION
--   SAT_AUG_RISK_OBJECT_CORE
--   SAT_RISK_MOTOR_VEHICLE
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BA_QUOTE_MOT_DTLS
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '') as RISK_OBJECT_BK,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__CARRIER_TYPE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__HOUR_METER_READING,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__INSURER_VEHICLE_CODE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__INSURER_VEHICLE_MASTER_CODE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__INTERNAL_VEHICLE_CODE,
        t0.misc_veh_type_code as AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_CLASS_CODE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_TYPE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_TYPE_CODE,
        t0.zone as AUG_RISK_MOTOR_VEHICLE__MOTOR_RATING_ZONE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__NEW_INSURER_VEHICLE_CODE_LIST,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__NEW_INTERNAL_VEHICLE_CODE_LIST,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INSURER_VEHICLE_CODE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INSURER_VEHICLE_CODE_LIST,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INTERNAL_VEHICLE_CODE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INTERNAL_VEHICLE_CODE_LIST,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__OTHER_STATE_REGISTRATION_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__OWN_PREMISES_USE_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__PRE_EXISTING_DAMAGE_DESCRIPTION,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__PUC_CERTIFICATE_VALID_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__RATING_ZONE_CODE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_CITY,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_LOCATION_OTHER_TEXT,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_RECORDED_POLICY_NUMBER,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_STATUS,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_YEAR,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__SECONDARY_MOTOR_NUMBER,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__TARIFF_PASSENGER_RANGE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__VEHICLE_DELIVERY_DATE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__VEHICLE_INVOICE_DATE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__VEHICLE_KEY_COUNT,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__VEHICLE_MASTER_CODE,
        cast(null as varchar) as AUG_RISK_MOTOR_VEHICLE__VEHICLE_TYPE_CODE,
        cast(null as varchar) as AUG_RISK_MOTOR_VERIFICATION__BUREAU_ENQUIRY_RECORD_REFERENCE,
        cast(null as varchar) as AUG_RISK_MOTOR_VERIFICATION__CHANGE_APPROVAL_RECEIVED_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_VERIFICATION__CHASSIS_NUMBER_AS_VERIFIED,
        cast(null as varchar) as AUG_RISK_MOTOR_VERIFICATION__ENGINE_NUMBER_AS_VERIFIED,
        cast(null as varchar) as AUG_RISK_MOTOR_VERIFICATION__PREVIOUS_VERIFICATION_STATUS,
        cast(null as varchar) as AUG_RISK_MOTOR_VERIFICATION__REGISTRATION_NUMBER_AS_VERIFIED,
        cast(null as varchar) as AUG_RISK_MOTOR_VERIFICATION__STATUS_CHANGE_DATE,
        cast(null as varchar) as AUG_RISK_MOTOR_VERIFICATION__USER_REMARKS,
        cast(null as varchar) as AUG_RISK_MOTOR_VERIFICATION__VEHICLE_DATA_SERVICE_PROVIDER,
        cast(null as varchar) as AUG_RISK_MOTOR_VERIFICATION__VENDOR_VERIFICATION_REFERENCE,
        cast(null as varchar) as AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_DATA_SOURCE,
        cast(null as varchar) as AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_REQUEST_SOURCE,
        cast(null as varchar) as AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_FROM_DATE,
        cast(null as varchar) as AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_STATUS,
        cast(null as varchar) as AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_TO_DATE,
        t0.multi_veh_ref_id as AUG_RISK_OBJECT_CORE__MULTI_VEHICLE_REQUEST_REFERENCE,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__ANTI_THEFT_DEVICE_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_EXPIRY_DATE,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_NUMBER,
        t0.bh_reg_flag as RISK_MOTOR_VEHICLE__BH_REGISTRATION_INDICATOR,
        t0.veh_manufacturing_type as RISK_MOTOR_VEHICLE__BODY_TYPE,
        t0.carrying_capacity as RISK_MOTOR_VEHICLE__CARRYING_CAPACITY,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__CHASSIS_NUMBER,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__CNG_LPG_KIT_VALUE,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__COLOUR,
        t0.cubic_capacity as RISK_MOTOR_VEHICLE__CUBIC_CAPACITY,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__DRIVEN_BY_TYPE,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        t0.fuel_type as RISK_MOTOR_VEHICLE__FUEL_TYPE,
        t0.vehicle_gvw as RISK_MOTOR_VEHICLE__GROSS_VEHICLE_WEIGHT,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__HYPOTHECATION_BANK_NAME,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__MAKE,
        t0.vehicle_make_code as RISK_MOTOR_VEHICLE__MAKE_CODE,
        t0.year_of_mfg as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__MODEL,
        t0.vehicle_model_code as RISK_MOTOR_VEHICLE__MODEL_CODE,
        t0.current_km as RISK_MOTOR_VEHICLE__ODOMETER_READING,
        t0.registration_date as RISK_MOTOR_VEHICLE__REGISTRATION_DATE,
        t0.vehicle_reg_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        t0.reg_no_flag as RISK_MOTOR_VEHICLE__REGISTRATION_TYPE,
        t0.rta_location as RISK_MOTOR_VEHICLE__RTO_CODE,
        t0.registration_loc as RISK_MOTOR_VEHICLE__RTO_NAME,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__TRAILER_COUNT,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__TRANSMISSION_TYPE,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__VARIANT,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__VARIANT_CODE,
        t0.vehicle_type_code as RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__VEHICLE_INVOICE_NUMBER,
        t0.vehicle_subtype_code as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CATEGORY,
        cast(null as varchar) as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CLASS,
        t0.veh_usage_type as RISK_MOTOR_VEHICLE__VEHICLE_USAGE,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '')) is not null

    union all

    -- branch 1: BGIL_MOTOR_WEBSERVICE_INFO_EQM
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.vehicle_code as AUG_RISK_MOTOR_VEHICLE__VEHICLE_MASTER_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.carrying_capacity as RISK_MOTOR_VEHICLE__CARRYING_CAPACITY,
        t0.chassis_no as RISK_MOTOR_VEHICLE__CHASSIS_NUMBER,
        null, null,
        t0.cubic_capacity as RISK_MOTOR_VEHICLE__CUBIC_CAPACITY,
        null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        t0.fuel_type as RISK_MOTOR_VEHICLE__FUEL_TYPE,
        t0.vehicle_gvw as RISK_MOTOR_VEHICLE__GROSS_VEHICLE_WEIGHT,
        null, null,
        t0.vehicle_make_code as RISK_MOTOR_VEHICLE__MAKE_CODE,
        t0.year_of_mfg as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        null,
        t0.vehicle_model_code as RISK_MOTOR_VEHICLE__MODEL_CODE,
        null,
        t0.registration_date as RISK_MOTOR_VEHICLE__REGISTRATION_DATE,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null, null, null, null,
        t0.misc_veh_type_code as RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE,
        t0.vehicle_type_code as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null, null,
        t0.vehicle_subtype_code as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CLASS,
        null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_webservice_info_eqm') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 2: BGIL_MOTOR_WS_PLAN_DETAILS_EQM
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        t0.misc_veh_type as AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_CLASS_CODE,
        null, null,
        t0.zone as AUG_RISK_MOTOR_VEHICLE__MOTOR_RATING_ZONE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.regi_loc_other as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_LOCATION_OTHER_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.auto_membership as RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_INDICATOR,
        null, null, null,
        t0.carrying_capacity as RISK_MOTOR_VEHICLE__CARRYING_CAPACITY,
        null, null,
        t0.color as RISK_MOTOR_VEHICLE__COLOUR,
        t0.cubic_capacity as RISK_MOTOR_VEHICLE__CUBIC_CAPACITY,
        null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        t0.fuel as RISK_MOTOR_VEHICLE__FUEL_TYPE,
        null, null,
        t0.vehicle_make as RISK_MOTOR_VEHICLE__MAKE,
        t0.vehicle_make_code as RISK_MOTOR_VEHICLE__MAKE_CODE,
        t0.year_manf as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        t0.vehicle_model as RISK_MOTOR_VEHICLE__MODEL,
        t0.vehicle_model_code as RISK_MOTOR_VEHICLE__MODEL_CODE,
        null,
        t0.registration_date as RISK_MOTOR_VEHICLE__REGISTRATION_DATE,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null,
        t0.registration_location as RISK_MOTOR_VEHICLE__RTO_NAME,
        null, null, null, null,
        t0.vehicle_type_code as RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE,
        t0.vehicle_type as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null,
        t0.vehicle_subtype_code as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CATEGORY,
        t0.vehicle_subtype as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CLASS,
        null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_plan_details_eqm') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 3: BJAZ_AGENCY_MOT_WAR_DTLS
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.veh_reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.veh_delivery_date as AUG_RISK_MOTOR_VEHICLE__VEHICLE_DELIVERY_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        t0.fuel_type as RISK_MOTOR_VEHICLE__FUEL_TYPE,
        null, null,
        t0.vehicle_make as RISK_MOTOR_VEHICLE__MAKE,
        null,
        t0.year_of_manufacturing as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        t0.vehicle_model as RISK_MOTOR_VEHICLE__MODEL,
        null,
        t0.current_odometer_reading as RISK_MOTOR_VEHICLE__ODOMETER_READING,
        null,
        t0.veh_reg_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null,
        t0.trans_type as RISK_MOTOR_VEHICLE__TRANSMISSION_TYPE,
        null, null, null,
        t0.vehicle_type as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        t0.invoice_no as RISK_MOTOR_VEHICLE__VEHICLE_INVOICE_NUMBER,
        null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_agency_mot_war_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.veh_reg_no), '')), '')) is not null

    union all

    -- branch 4: BJAZ_CVTP_WS_DATA
    select
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        t0.carriertype as AUG_RISK_MOTOR_VEHICLE__CARRIER_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.isownpremises as AUG_RISK_MOTOR_VEHICLE__OWN_PREMISES_USE_INDICATOR,
        null, null, null, null, null, null, null, null, null,
        t0.tariffpaxrange as AUG_RISK_MOTOR_VEHICLE__TARIFF_PASSENGER_RANGE,
        null, null, null,
        t0.bjaz_veh_code as AUG_RISK_MOTOR_VEHICLE__VEHICLE_MASTER_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.isantitheftattached as RISK_MOTOR_VEHICLE__ANTI_THEFT_DEVICE_INDICATOR,
        t0.aaexpiryperiod as RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_EXPIRY_DATE,
        t0.isaamembership as RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_INDICATOR,
        t0.aamemno as RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_NUMBER,
        null, null,
        t0.carryingcapacity as RISK_MOTOR_VEHICLE__CARRYING_CAPACITY,
        null,
        t0.bifuelkitvalue as RISK_MOTOR_VEHICLE__CNG_LPG_KIT_VALUE,
        null,
        t0.cc as RISK_MOTOR_VEHICLE__CUBIC_CAPACITY,
        null,
        t0.engineno as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        t0.fueltype as RISK_MOTOR_VEHICLE__FUEL_TYPE,
        t0.gvw as RISK_MOTOR_VEHICLE__GROSS_VEHICLE_WEIGHT,
        null,
        t0.make as RISK_MOTOR_VEHICLE__MAKE,
        null,
        t0.yearofmanufacture as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        null,
        t0.modelcode as RISK_MOTOR_VEHICLE__MODEL_CODE,
        null,
        t0.registrationdate as RISK_MOTOR_VEHICLE__REGISTRATION_DATE,
        t0.registrationno as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null,
        t0.rtocode as RISK_MOTOR_VEHICLE__RTO_CODE,
        null,
        t0.nooftrailers as RISK_MOTOR_VEHICLE__TRAILER_COUNT,
        null, null,
        t0.variantcode as RISK_MOTOR_VEHICLE__VARIANT_CODE,
        t0.vehicletype as RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE,
        t0.vehicleclass as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null,
        t0.cvmisctype as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CATEGORY,
        t0.vehiclesubclass as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CLASS,
        null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 5: BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
    select
        nullif(nullif(trim(t0.regno), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.uniq_uui as AUG_RISK_MOTOR_VERIFICATION__BUREAU_ENQUIRY_RECORD_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.class_of_vehicle as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_iib_sudars_policy_dtl_hst_qm') }} t0
    where (nullif(nullif(trim(t0.regno), ''), '')) is not null

    union all

    -- branch 6: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        nullif(nullif(trim(t0.engine_no), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.keys as AUG_RISK_MOTOR_VEHICLE__VEHICLE_KEY_COUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.registration_date as RISK_MOTOR_VEHICLE__REGISTRATION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.engine_no), ''), '')) is not null

    union all

    -- branch 7: BJAZ_MOTOR_WEBSERVICE_INFO
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.vehicle_code as AUG_RISK_MOTOR_VEHICLE__VEHICLE_MASTER_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.carrying_capacity as RISK_MOTOR_VEHICLE__CARRYING_CAPACITY,
        t0.chassis_no as RISK_MOTOR_VEHICLE__CHASSIS_NUMBER,
        null, null,
        t0.cubic_capacity as RISK_MOTOR_VEHICLE__CUBIC_CAPACITY,
        null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        t0.fuel_type as RISK_MOTOR_VEHICLE__FUEL_TYPE,
        t0.vehicle_gvw as RISK_MOTOR_VEHICLE__GROSS_VEHICLE_WEIGHT,
        null, null,
        t0.vehicle_make_code as RISK_MOTOR_VEHICLE__MAKE_CODE,
        t0.year_of_mfg as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        null,
        t0.vehicle_model_code as RISK_MOTOR_VEHICLE__MODEL_CODE,
        null,
        t0.registration_date as RISK_MOTOR_VEHICLE__REGISTRATION_DATE,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null, null, null, null,
        t0.misc_veh_type_code as RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE,
        t0.vehicle_type_code as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null, null,
        t0.vehicle_subtype_code as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CLASS,
        null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_webservice_info') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 8: BJAZ_MOTOR_WS_PLAN_DETAILS
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        t0.misc_veh_type as AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_CLASS_CODE,
        null, null,
        t0.zone as AUG_RISK_MOTOR_VEHICLE__MOTOR_RATING_ZONE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.regi_loc_other as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_LOCATION_OTHER_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.auto_membership as RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_INDICATOR,
        null, null, null,
        t0.carrying_capacity as RISK_MOTOR_VEHICLE__CARRYING_CAPACITY,
        null, null,
        t0.color as RISK_MOTOR_VEHICLE__COLOUR,
        t0.cubic_capacity as RISK_MOTOR_VEHICLE__CUBIC_CAPACITY,
        null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        t0.fuel as RISK_MOTOR_VEHICLE__FUEL_TYPE,
        null, null,
        t0.vehicle_make as RISK_MOTOR_VEHICLE__MAKE,
        t0.vehicle_make_code as RISK_MOTOR_VEHICLE__MAKE_CODE,
        t0.year_manf as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        t0.vehicle_model as RISK_MOTOR_VEHICLE__MODEL,
        t0.vehicle_model_code as RISK_MOTOR_VEHICLE__MODEL_CODE,
        null,
        t0.registration_date as RISK_MOTOR_VEHICLE__REGISTRATION_DATE,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null,
        t0.registration_location as RISK_MOTOR_VEHICLE__RTO_NAME,
        null, null, null, null,
        t0.vehicle_type_code as RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE,
        t0.vehicle_type as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null,
        t0.vehicle_subtype_code as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CATEGORY,
        t0.vehicle_subtype as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CLASS,
        null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_plan_details') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 9: BJAZ_MOT_ONLINE_POL_DTLS
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.damage_details as AUG_RISK_MOTOR_VEHICLE__PRE_EXISTING_DAMAGE_DESCRIPTION,
        null,
        t0.zone as AUG_RISK_MOTOR_VEHICLE__RATING_ZONE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.carrying_capacity as RISK_MOTOR_VEHICLE__CARRYING_CAPACITY,
        null, null,
        t0.colour as RISK_MOTOR_VEHICLE__COLOUR,
        t0.cubic_capacity as RISK_MOTOR_VEHICLE__CUBIC_CAPACITY,
        null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        t0.fuel_type as RISK_MOTOR_VEHICLE__FUEL_TYPE,
        t0.vehicle_gvw as RISK_MOTOR_VEHICLE__GROSS_VEHICLE_WEIGHT,
        t0.hypo_bank as RISK_MOTOR_VEHICLE__HYPOTHECATION_BANK_NAME,
        null,
        t0.vehicle_make_code as RISK_MOTOR_VEHICLE__MAKE_CODE,
        t0.year_of_mfg as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        null,
        t0.vehicle_model_code as RISK_MOTOR_VEHICLE__MODEL_CODE,
        null,
        t0.registration_date as RISK_MOTOR_VEHICLE__REGISTRATION_DATE,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null,
        t0.registration_loc as RISK_MOTOR_VEHICLE__RTO_NAME,
        null, null,
        t0.vehicle_version as RISK_MOTOR_VEHICLE__VARIANT,
        null,
        t0.vehicle_type_code as RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE,
        t0.misc_veh_type_code as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null,
        t0.vehicle_subtype_code as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CATEGORY,
        null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 10: BJAZ_MOT_RENEWAL_EXTN
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null,
        t0.vehicle_code as AUG_RISK_MOTOR_VEHICLE__INSURER_VEHICLE_CODE,
        null, null, null, null, null, null,
        t0.new_vehicle_codes as AUG_RISK_MOTOR_VEHICLE__NEW_INSURER_VEHICLE_CODE_LIST,
        null,
        t0.org_vehicle_code as AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INSURER_VEHICLE_CODE,
        t0.org_vehicle_codes as AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INSURER_VEHICLE_CODE_LIST,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        null, null, null,
        t0.vehicle_make as RISK_MOTOR_VEHICLE__MAKE,
        null,
        t0.year_of_mfg as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        t0.vehicle_model as RISK_MOTOR_VEHICLE__MODEL,
        null, null, null,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_subtype as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CLASS,
        null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 11: BJAZ_MOT_RENEWAL_HIST
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null,
        t0.vehicle_code as AUG_RISK_MOTOR_VEHICLE__INTERNAL_VEHICLE_CODE,
        null, null, null, null, null,
        t0.new_vehicle_codes as AUG_RISK_MOTOR_VEHICLE__NEW_INTERNAL_VEHICLE_CODE_LIST,
        null, null,
        t0.org_vehicle_code as AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INTERNAL_VEHICLE_CODE,
        t0.org_vehicle_codes as AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INTERNAL_VEHICLE_CODE_LIST,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        null, null, null,
        t0.vehicle_make as RISK_MOTOR_VEHICLE__MAKE,
        null,
        t0.year_of_mfg as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        t0.vehicle_model as RISK_MOTOR_VEHICLE__MODEL,
        null, null,
        t0.registration_date as RISK_MOTOR_VEHICLE__REGISTRATION_DATE,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_subtype as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CLASS,
        null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 12: BJAZ_MOT_RNW_VALIDATE_VEH_DTLS
    select
        nullif(coalesce(nullif(trim(t0.chasis_number), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.change_approval_receive as AUG_RISK_MOTOR_VERIFICATION__CHANGE_APPROVAL_RECEIVED_INDICATOR,
        null, null,
        t0.prev_status as AUG_RISK_MOTOR_VERIFICATION__PREVIOUS_VERIFICATION_STATUS,
        null,
        t0.user_status_changes_date as AUG_RISK_MOTOR_VERIFICATION__STATUS_CHANGE_DATE,
        t0.user_remarks as AUG_RISK_MOTOR_VERIFICATION__USER_REMARKS,
        null, null,
        t0.data_served_by as AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_DATA_SOURCE,
        t0.source_name as AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_REQUEST_SOURCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.engine_number as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null, null, null, null,
        t0.veh_type as RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE,
        t0.veh_class_desc as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_rnw_validate_veh_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chasis_number), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 13: BJAZ_MOT_RN_CLS_VEH_DTLS_HIST
    select
        nullif(coalesce(nullif(trim(t0.chasis_number), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.change_approval_receive as AUG_RISK_MOTOR_VERIFICATION__CHANGE_APPROVAL_RECEIVED_INDICATOR,
        null, null,
        t0.prev_status as AUG_RISK_MOTOR_VERIFICATION__PREVIOUS_VERIFICATION_STATUS,
        null,
        t0.user_status_changes_date as AUG_RISK_MOTOR_VERIFICATION__STATUS_CHANGE_DATE,
        t0.user_remarks as AUG_RISK_MOTOR_VERIFICATION__USER_REMARKS,
        null, null,
        t0.data_served_by as AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_DATA_SOURCE,
        t0.source_name as AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_REQUEST_SOURCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.engine_number as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null, null, null, null,
        t0.veh_type as RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE,
        t0.veh_class_desc as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_rn_cls_veh_dtls_hist') }} t0
    where (nullif(coalesce(nullif(trim(t0.chasis_number), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 14: BJAZ_MOT_WAR_CHILD_DTLS
    select
        nullif(coalesce(nullif(trim(t0.vehicle_reg_no), ''), nullif(trim(t0.equipment_serial_no), '')), '') as RISK_OBJECT_BK,
        null,
        t0.present_hour as AUG_RISK_MOTOR_VEHICLE__HOUR_METER_READING,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.motor_no2 as AUG_RISK_MOTOR_VEHICLE__SECONDARY_MOTOR_NUMBER,
        null,
        t0.date_of_veh_delivery as AUG_RISK_MOTOR_VEHICLE__VEHICLE_DELIVERY_DATE,
        t0.invoice_date as AUG_RISK_MOTOR_VEHICLE__VEHICLE_INVOICE_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        t0.fuel_type as RISK_MOTOR_VEHICLE__FUEL_TYPE,
        null, null,
        t0.make_name as RISK_MOTOR_VEHICLE__MAKE,
        null,
        t0.year_of_manufacturing as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        t0.model_name as RISK_MOTOR_VEHICLE__MODEL,
        null,
        t0.present_km as RISK_MOTOR_VEHICLE__ODOMETER_READING,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.invoice_no as RISK_MOTOR_VEHICLE__VEHICLE_INVOICE_NUMBER,
        null, null, null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.vehicle_reg_no), ''), nullif(trim(t0.equipment_serial_no), '')), '')) is not null

    union all

    -- branch 15: BJAZ_MOT_WINBACK_DTLS
    select
        nullif(nullif(trim(t0.registration_no), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.registration_year as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_YEAR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.make as RISK_MOTOR_VEHICLE__MAKE,
        t0.make_code as RISK_MOTOR_VEHICLE__MAKE_CODE,
        t0.year_of_manufacturing as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        t0.model as RISK_MOTOR_VEHICLE__MODEL,
        t0.model_code as RISK_MOTOR_VEHICLE__MODEL_CODE,
        null, null, null, null, null, null, null, null,
        t0.variant as RISK_MOTOR_VEHICLE__VARIANT,
        null, null, null, null,
        t0.sub_type_code as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CATEGORY,
        null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (nullif(nullif(trim(t0.registration_no), ''), '')) is not null

    union all

    -- branch 16: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null,
        t0.vehicle_id as AUG_RISK_MOTOR_VEHICLE__INSURER_VEHICLE_MASTER_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.carrying_capacity as RISK_MOTOR_VEHICLE__CARRYING_CAPACITY,
        null, null,
        t0.colour as RISK_MOTOR_VEHICLE__COLOUR,
        t0.cubic_capacity as RISK_MOTOR_VEHICLE__CUBIC_CAPACITY,
        null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        t0.fuel_type as RISK_MOTOR_VEHICLE__FUEL_TYPE,
        t0.vehicle_gvw as RISK_MOTOR_VEHICLE__GROSS_VEHICLE_WEIGHT,
        t0.hypo_bank as RISK_MOTOR_VEHICLE__HYPOTHECATION_BANK_NAME,
        null,
        t0.vehicle_make_code as RISK_MOTOR_VEHICLE__MAKE_CODE,
        t0.year_of_mfg as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        null,
        t0.vehicle_model_code as RISK_MOTOR_VEHICLE__MODEL_CODE,
        null,
        t0.registration_date as RISK_MOTOR_VEHICLE__REGISTRATION_DATE,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null, null, null,
        t0.vehicle_version as RISK_MOTOR_VEHICLE__VARIANT_CODE,
        t0.misc_veh_type_code as RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE,
        t0.vehicle_type_code as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null, null,
        t0.vehicle_subtype_code as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CLASS,
        null,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 17: BJAZ_PAYMOTORTHEFT_DTLS
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        null, null, null,
        t0.vehicle_make as RISK_MOTOR_VEHICLE__MAKE,
        null,
        t0.manufacture_year as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        t0.vehicle_model as RISK_MOTOR_VEHICLE__MODEL,
        null, null, null,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null, null, null, null, null,
        t0.vehicle_type as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null, null, null, null,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_paymotortheft_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 18: BJAZ_SCR_MOT_VEH_DTLS
    select
        nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null,
        t0.misc_veh_type as AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_TYPE,
        t0.misc_veh_type_code as AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_TYPE_CODE,
        null, null, null, null, null, null, null,
        t0.otr_reg_no_flg as AUG_RISK_MOTOR_VEHICLE__OTHER_STATE_REGISTRATION_INDICATOR,
        null, null, null,
        t0.veh_zone as AUG_RISK_MOTOR_VEHICLE__RATING_ZONE_CODE,
        t0.reg_city as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_CITY,
        null,
        t0.reg_policy_no as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_RECORDED_POLICY_NUMBER,
        null, null, null, null,
        t0.delivery_date as AUG_RISK_MOTOR_VEHICLE__VEHICLE_DELIVERY_DATE,
        null, null, null,
        t0.vehicle_type_code as AUG_RISK_MOTOR_VEHICLE__VEHICLE_TYPE_CODE,
        null, null, null, null, null, null, null, null,
        t0.veh_data_serverd_by as AUG_RISK_MOTOR_VERIFICATION__VEHICLE_DATA_SERVICE_PROVIDER,
        t0.zoop_refno as AUG_RISK_MOTOR_VERIFICATION__VENDOR_VERIFICATION_REFERENCE,
        null, null, null, null, null, null,
        t0.antitheft_device as RISK_MOTOR_VEHICLE__ANTI_THEFT_DEVICE_INDICATOR,
        null,
        t0.aam_member as RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_INDICATOR,
        null,
        t0.bh_reg_flag as RISK_MOTOR_VEHICLE__BH_REGISTRATION_INDICATOR,
        null,
        t0.carrying_cap as RISK_MOTOR_VEHICLE__CARRYING_CAPACITY,
        null, null, null,
        t0.cubic_capacity as RISK_MOTOR_VEHICLE__CUBIC_CAPACITY,
        null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        t0.veh_fuel as RISK_MOTOR_VEHICLE__FUEL_TYPE,
        null, null, null,
        t0.vehicle_make_code as RISK_MOTOR_VEHICLE__MAKE_CODE,
        t0.year_of_manf as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
        null,
        t0.vehicle_model_code as RISK_MOTOR_VEHICLE__MODEL_CODE,
        null,
        t0.registration_date as RISK_MOTOR_VEHICLE__REGISTRATION_DATE,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null, null, null, null,
        t0.vehicle_code as RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE,
        null, null,
        t0.vehicle_subtype_code as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CATEGORY,
        null, null,
        18 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_scr_mot_veh_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 19: BJAZ_VAHAN_AUTO_ENDT_LOG
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.reg_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        19 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_vahan_auto_endt_log') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.reg_no), '')), '')) is not null

    union all

    -- branch 20: BJAZ_VAHAN_MOTOR_DTLS
    select
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pucc_flag as AUG_RISK_MOTOR_VEHICLE__PUC_CERTIFICATE_VALID_INDICATOR,
        null, null, null, null,
        t0.status as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_STATUS,
        null, null, null, null, null, null, null, null, null, null,
        t0.chasis_no_res as AUG_RISK_MOTOR_VERIFICATION__CHASSIS_NUMBER_AS_VERIFIED,
        t0.engine_no_res as AUG_RISK_MOTOR_VERIFICATION__ENGINE_NUMBER_AS_VERIFIED,
        null,
        t0.regn_no_res as AUG_RISK_MOTOR_VERIFICATION__REGISTRATION_NUMBER_AS_VERIFIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.engine_no as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        null, null, null,
        t0.maker_name as RISK_MOTOR_VEHICLE__MAKE,
        null, null,
        t0.model_name as RISK_MOTOR_VEHICLE__MODEL,
        null, null, null,
        t0.reg_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null, null, null, null, null,
        t0.vehicle_class as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null, null, null, null,
        20 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_vahan_motor_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.reg_no), '')), '')) is not null

    union all

    -- branch 21: BJAZ_WAP_MOT_ADD_QSTN_DTLS
    select
        nullif(nullif(trim(coalesce(t0.reg_no_part1, '') || coalesce(t0.reg_no_part2, '') || coalesce(t0.reg_no_part3, '') || coalesce(t0.reg_no_part4, '')), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.veh_driver as RISK_MOTOR_VEHICLE__DRIVEN_BY_TYPE,
        null, null, null, null, null, null, null, null, null,
        t0.km_reading as RISK_MOTOR_VEHICLE__ODOMETER_READING,
        null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_type as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
        null, null, null, null,
        21 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wap_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(coalesce(t0.reg_no_part1, '') || coalesce(t0.reg_no_part2, '') || coalesce(t0.reg_no_part3, '') || coalesce(t0.reg_no_part4, '')), ''), '')) is not null

    union all

    -- branch 22: VEHICLE_BLOCK_MASTER
    select
        nullif(coalesce(nullif(trim(t0.chassis_number), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.start_date as AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_FROM_DATE,
        t0.status as AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_STATUS,
        t0.end_date as AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_TO_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.engine_number as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.registration_no as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        22 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__vehicle_block_master') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_number), ''), nullif(trim(t0.registration_no), '')), '')) is not null

)

select
    RISK_OBJECT_BK,
    first_value(AUG_RISK_MOTOR_VEHICLE__CARRIER_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__CARRIER_TYPE,
    first_value(AUG_RISK_MOTOR_VEHICLE__HOUR_METER_READING) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__HOUR_METER_READING,
    first_value(AUG_RISK_MOTOR_VEHICLE__INSURER_VEHICLE_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__INSURER_VEHICLE_CODE,
    first_value(AUG_RISK_MOTOR_VEHICLE__INSURER_VEHICLE_MASTER_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__INSURER_VEHICLE_MASTER_CODE,
    first_value(AUG_RISK_MOTOR_VEHICLE__INTERNAL_VEHICLE_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__INTERNAL_VEHICLE_CODE,
    first_value(AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_CLASS_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_CLASS_CODE,
    first_value(AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_TYPE,
    first_value(AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_TYPE_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__MISCELLANEOUS_VEHICLE_TYPE_CODE,
    first_value(AUG_RISK_MOTOR_VEHICLE__MOTOR_RATING_ZONE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__MOTOR_RATING_ZONE,
    first_value(AUG_RISK_MOTOR_VEHICLE__NEW_INSURER_VEHICLE_CODE_LIST) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__NEW_INSURER_VEHICLE_CODE_LIST,
    first_value(AUG_RISK_MOTOR_VEHICLE__NEW_INTERNAL_VEHICLE_CODE_LIST) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__NEW_INTERNAL_VEHICLE_CODE_LIST,
    first_value(AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INSURER_VEHICLE_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INSURER_VEHICLE_CODE,
    first_value(AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INSURER_VEHICLE_CODE_LIST) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INSURER_VEHICLE_CODE_LIST,
    first_value(AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INTERNAL_VEHICLE_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INTERNAL_VEHICLE_CODE,
    first_value(AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INTERNAL_VEHICLE_CODE_LIST) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__ORIGINAL_INTERNAL_VEHICLE_CODE_LIST,
    first_value(AUG_RISK_MOTOR_VEHICLE__OTHER_STATE_REGISTRATION_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__OTHER_STATE_REGISTRATION_INDICATOR,
    first_value(AUG_RISK_MOTOR_VEHICLE__OWN_PREMISES_USE_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__OWN_PREMISES_USE_INDICATOR,
    first_value(AUG_RISK_MOTOR_VEHICLE__PRE_EXISTING_DAMAGE_DESCRIPTION) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__PRE_EXISTING_DAMAGE_DESCRIPTION,
    first_value(AUG_RISK_MOTOR_VEHICLE__PUC_CERTIFICATE_VALID_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__PUC_CERTIFICATE_VALID_INDICATOR,
    first_value(AUG_RISK_MOTOR_VEHICLE__RATING_ZONE_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__RATING_ZONE_CODE,
    first_value(AUG_RISK_MOTOR_VEHICLE__REGISTRATION_CITY) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_CITY,
    first_value(AUG_RISK_MOTOR_VEHICLE__REGISTRATION_LOCATION_OTHER_TEXT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_LOCATION_OTHER_TEXT,
    first_value(AUG_RISK_MOTOR_VEHICLE__REGISTRATION_RECORDED_POLICY_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_RECORDED_POLICY_NUMBER,
    first_value(AUG_RISK_MOTOR_VEHICLE__REGISTRATION_STATUS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_STATUS,
    first_value(AUG_RISK_MOTOR_VEHICLE__REGISTRATION_YEAR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__REGISTRATION_YEAR,
    first_value(AUG_RISK_MOTOR_VEHICLE__SECONDARY_MOTOR_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__SECONDARY_MOTOR_NUMBER,
    first_value(AUG_RISK_MOTOR_VEHICLE__TARIFF_PASSENGER_RANGE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__TARIFF_PASSENGER_RANGE,
    first_value(AUG_RISK_MOTOR_VEHICLE__VEHICLE_DELIVERY_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__VEHICLE_DELIVERY_DATE,
    first_value(AUG_RISK_MOTOR_VEHICLE__VEHICLE_INVOICE_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__VEHICLE_INVOICE_DATE,
    first_value(AUG_RISK_MOTOR_VEHICLE__VEHICLE_KEY_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__VEHICLE_KEY_COUNT,
    first_value(AUG_RISK_MOTOR_VEHICLE__VEHICLE_MASTER_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__VEHICLE_MASTER_CODE,
    first_value(AUG_RISK_MOTOR_VEHICLE__VEHICLE_TYPE_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VEHICLE__VEHICLE_TYPE_CODE,
    first_value(AUG_RISK_MOTOR_VERIFICATION__BUREAU_ENQUIRY_RECORD_REFERENCE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__BUREAU_ENQUIRY_RECORD_REFERENCE,
    first_value(AUG_RISK_MOTOR_VERIFICATION__CHANGE_APPROVAL_RECEIVED_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__CHANGE_APPROVAL_RECEIVED_INDICATOR,
    first_value(AUG_RISK_MOTOR_VERIFICATION__CHASSIS_NUMBER_AS_VERIFIED) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__CHASSIS_NUMBER_AS_VERIFIED,
    first_value(AUG_RISK_MOTOR_VERIFICATION__ENGINE_NUMBER_AS_VERIFIED) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__ENGINE_NUMBER_AS_VERIFIED,
    first_value(AUG_RISK_MOTOR_VERIFICATION__PREVIOUS_VERIFICATION_STATUS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__PREVIOUS_VERIFICATION_STATUS,
    first_value(AUG_RISK_MOTOR_VERIFICATION__REGISTRATION_NUMBER_AS_VERIFIED) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__REGISTRATION_NUMBER_AS_VERIFIED,
    first_value(AUG_RISK_MOTOR_VERIFICATION__STATUS_CHANGE_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__STATUS_CHANGE_DATE,
    first_value(AUG_RISK_MOTOR_VERIFICATION__USER_REMARKS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__USER_REMARKS,
    first_value(AUG_RISK_MOTOR_VERIFICATION__VEHICLE_DATA_SERVICE_PROVIDER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__VEHICLE_DATA_SERVICE_PROVIDER,
    first_value(AUG_RISK_MOTOR_VERIFICATION__VENDOR_VERIFICATION_REFERENCE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__VENDOR_VERIFICATION_REFERENCE,
    first_value(AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_DATA_SOURCE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_DATA_SOURCE,
    first_value(AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_REQUEST_SOURCE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_REQUEST_SOURCE,
    first_value(AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_FROM_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_FROM_DATE,
    first_value(AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_STATUS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_STATUS,
    first_value(AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_TO_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_TO_DATE,
    first_value(AUG_RISK_OBJECT_CORE__MULTI_VEHICLE_REQUEST_REFERENCE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_CORE__MULTI_VEHICLE_REQUEST_REFERENCE,
    first_value(RISK_MOTOR_VEHICLE__ANTI_THEFT_DEVICE_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__ANTI_THEFT_DEVICE_INDICATOR,
    first_value(RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_EXPIRY_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_EXPIRY_DATE,
    first_value(RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_INDICATOR,
    first_value(RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__ASSOCIATION_MEMBERSHIP_NUMBER,
    first_value(RISK_MOTOR_VEHICLE__BH_REGISTRATION_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__BH_REGISTRATION_INDICATOR,
    first_value(RISK_MOTOR_VEHICLE__BODY_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__BODY_TYPE,
    first_value(RISK_MOTOR_VEHICLE__CARRYING_CAPACITY) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__CARRYING_CAPACITY,
    first_value(RISK_MOTOR_VEHICLE__CHASSIS_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__CHASSIS_NUMBER,
    first_value(RISK_MOTOR_VEHICLE__CNG_LPG_KIT_VALUE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__CNG_LPG_KIT_VALUE,
    first_value(RISK_MOTOR_VEHICLE__COLOUR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__COLOUR,
    first_value(RISK_MOTOR_VEHICLE__CUBIC_CAPACITY) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__CUBIC_CAPACITY,
    first_value(RISK_MOTOR_VEHICLE__DRIVEN_BY_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__DRIVEN_BY_TYPE,
    first_value(RISK_MOTOR_VEHICLE__ENGINE_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__ENGINE_NUMBER,
    first_value(RISK_MOTOR_VEHICLE__FUEL_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__FUEL_TYPE,
    first_value(RISK_MOTOR_VEHICLE__GROSS_VEHICLE_WEIGHT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__GROSS_VEHICLE_WEIGHT,
    first_value(RISK_MOTOR_VEHICLE__HYPOTHECATION_BANK_NAME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__HYPOTHECATION_BANK_NAME,
    first_value(RISK_MOTOR_VEHICLE__MAKE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__MAKE,
    first_value(RISK_MOTOR_VEHICLE__MAKE_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__MAKE_CODE,
    first_value(RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__MANUFACTURING_YEAR,
    first_value(RISK_MOTOR_VEHICLE__MODEL) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__MODEL,
    first_value(RISK_MOTOR_VEHICLE__MODEL_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__MODEL_CODE,
    first_value(RISK_MOTOR_VEHICLE__ODOMETER_READING) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__ODOMETER_READING,
    first_value(RISK_MOTOR_VEHICLE__REGISTRATION_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__REGISTRATION_DATE,
    first_value(RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__REGISTRATION_NUMBER,
    first_value(RISK_MOTOR_VEHICLE__REGISTRATION_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__REGISTRATION_TYPE,
    first_value(RISK_MOTOR_VEHICLE__RTO_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__RTO_CODE,
    first_value(RISK_MOTOR_VEHICLE__RTO_NAME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__RTO_NAME,
    first_value(RISK_MOTOR_VEHICLE__TRAILER_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__TRAILER_COUNT,
    first_value(RISK_MOTOR_VEHICLE__TRANSMISSION_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__TRANSMISSION_TYPE,
    first_value(RISK_MOTOR_VEHICLE__VARIANT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__VARIANT,
    first_value(RISK_MOTOR_VEHICLE__VARIANT_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__VARIANT_CODE,
    first_value(RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__VEHICLE_CATEGORY_CODE,
    first_value(RISK_MOTOR_VEHICLE__VEHICLE_CLASS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__VEHICLE_CLASS,
    first_value(RISK_MOTOR_VEHICLE__VEHICLE_INVOICE_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__VEHICLE_INVOICE_NUMBER,
    first_value(RISK_MOTOR_VEHICLE__VEHICLE_SUB_CATEGORY) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CATEGORY,
    first_value(RISK_MOTOR_VEHICLE__VEHICLE_SUB_CLASS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__VEHICLE_SUB_CLASS,
    first_value(RISK_MOTOR_VEHICLE__VEHICLE_USAGE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VEHICLE__VEHICLE_USAGE
from merged
