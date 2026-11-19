-- CENTRAL VIEW v25_risk_object -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BA_QUOTE_MOT_DTLS
--   BGIL_MOTOR_WEBSERVICE_INFO_EQM
--   BGIL_MOTOR_WS_PLAN_DETAILS_EQM
--   BJAZ_CVTP_WS_DATA
--   BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
--   BJAZ_MOTOR_WEBSERVICE_INFO
--   BJAZ_MOTOR_WS_PLAN_DETAILS
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_RENEWAL_EXTN
--   BJAZ_MOT_RENEWAL_HIST
--   BJAZ_MOT_RNW_LOADER_DATA
--   BJAZ_MOT_WINBACK_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_SCR_MOT_VEH_DTLS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_RISK_MOTOR_IDV
--   SAT_MOTOR_AUG_RISK_MOTOR_LIABILITY_ADDON
--   SAT_MOTOR_AUG_RISK_MOTOR_NCB_HISTORY
--   SAT_MOTOR_AUG_RISK_MOTOR_TELEMATICS
--   SAT_POLICY_EXTERNAL_TP_LINK
--   SAT_RISK_MOTOR_ADDON
--   SAT_RISK_MOTOR_CPA
--   SAT_RISK_MOTOR_FITMENTS
--   SAT_RISK_MOTOR_NCB_HISTORY
--   SAT_RISK_MOTOR_TELEMATICS
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BA_QUOTE_MOT_DTLS
    select
        cast(null as varchar) as POLICY_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '') as RISK_OBJECT_BK,
        cast(null as varchar) as AUG_RISK_MOTOR_IDV__BODY_IDV,
        cast(null as varchar) as AUG_RISK_MOTOR_IDV__COMPUTED_IDV_ACCEPTED_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_IDV__CUSTOMER_PROPOSED_IDV,
        cast(null as varchar) as AUG_RISK_MOTOR_IDV__IDV_DERIVATION_STATUS,
        cast(null as varchar) as AUG_RISK_MOTOR_IDV__IDV_RANGE_LOWER_BOUND,
        cast(null as varchar) as AUG_RISK_MOTOR_IDV__IDV_RANGE_UPPER_BOUND,
        cast(null as varchar) as AUG_RISK_MOTOR_IDV__MAXIMUM_PERMITTED_IDV,
        cast(null as varchar) as AUG_RISK_MOTOR_IDV__MINIMUM_PERMITTED_IDV,
        t0.original_idv as AUG_RISK_MOTOR_IDV__ORIGINAL_IDV_BEFORE_ADJUSTMENT,
        cast(null as varchar) as AUG_RISK_MOTOR_IDV__SYSTEM_IDV_ACCEPTED_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_IDV__VEHICLE_AGE_BAND,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CLEANER_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CLEANER_PREMIUM,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CONDUCTOR_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CONDUCTOR_PREMIUM,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_HELPER_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_HELPER_PREMIUM,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_PREMIUM,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CLEANER_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CLEANER_PREMIUM,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CONDUCTOR_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CONDUCTOR_PREMIUM,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_EMPLOYEE_OCCUPANT_SUM_INSURED,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_HELPER_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_HELPER_PREMIUM,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_PAID_DRIVER_PREMIUM,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_PILLION_RIDER_PREMIUM,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_DRIVER_PREMIUM,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PASSENGER_COUNT,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PASSENGER_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PASSENGER_SUM_INSURED_PER_PERSON,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PERSON_PREMIUM,
        cast(null as varchar) as AUG_RISK_MOTOR_LIABILITY_ADDON__THIRD_PARTY_PROPERTY_DAMAGE_RESTRICTED_INDICATOR,
        cast(null as varchar) as AUG_RISK_MOTOR_NCB_HISTORY__BUREAU_REPORTED_PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_RISK_MOTOR_NCB_HISTORY__CLAIM_COUNT_TWO_YEAR,
        cast(null as varchar) as AUG_RISK_MOTOR_NCB_HISTORY__CLAIM_DATES_LIST,
        cast(null as varchar) as AUG_RISK_MOTOR_NCB_HISTORY__ELIGIBLE_NCB_PERCENTAGE,
        cast(null as varchar) as AUG_RISK_MOTOR_NCB_HISTORY__LAST_CLAIM_TRANSACTION_DATE,
        cast(null as varchar) as AUG_RISK_MOTOR_NCB_HISTORY__NCB_CARRY_FORWARD_PREVIOUS_POLICY_NUMBER,
        t0.ncb_source as AUG_RISK_MOTOR_NCB_HISTORY__NCB_SOURCE_CODE,
        t0.ncb_amount as AUG_RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_AMOUNT,
        cast(null as varchar) as AUG_RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_PATTERN,
        cast(null as varchar) as AUG_RISK_MOTOR_NCB_HISTORY__PREVIOUS_NCB_AMOUNT,
        cast(null as varchar) as AUG_RISK_MOTOR_NCB_HISTORY__REQUOTED_CLAIM_COUNT,
        t0.applicable_range_from as AUG_RISK_MOTOR_TELEMATICS__APPLICABLE_KILOMETRE_RANGE_FROM,
        t0.applicable_range_to as AUG_RISK_MOTOR_TELEMATICS__APPLICABLE_KILOMETRE_RANGE_TO,
        t0.bonus_km as AUG_RISK_MOTOR_TELEMATICS__BONUS_KILOMETRES,
        t0.payg_rid_time as AUG_RISK_MOTOR_TELEMATICS__PLAN_EFFECTIVE_TIME,
        t0.payg_red as AUG_RISK_MOTOR_TELEMATICS__PLAN_EXPIRY_DATE,
        cast(null as varchar) as AUG_RISK_MOTOR_TELEMATICS__TELEMATICS_OWN_DAMAGE_DISCOUNT_PERCENTAGE,
        t0.trip_to as AUG_RISK_MOTOR_TELEMATICS__TRIP_DESTINATION,
        t0.trip_to_date as AUG_RISK_MOTOR_TELEMATICS__TRIP_END_DATE,
        t0.trip_from as AUG_RISK_MOTOR_TELEMATICS__TRIP_ORIGIN,
        t0.trip_from_date as AUG_RISK_MOTOR_TELEMATICS__TRIP_START_DATE,
        cast(null as varchar) as POLICY_EXTERNAL_TP_LINK__STANDALONE_TP_INDICATOR,
        cast(null as varchar) as POLICY_EXTERNAL_TP_LINK__TP_FINANCE_TYPE,
        cast(null as varchar) as POLICY_EXTERNAL_TP_LINK__TP_POLICY_END_DATE,
        cast(null as varchar) as POLICY_EXTERNAL_TP_LINK__TP_POLICY_START_DATE,
        cast(null as varchar) as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        cast(null as varchar) as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_ADDON__ADD_ON_PACKAGE_CODE,
        cast(null as varchar) as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        cast(null as varchar) as RISK_MOTOR_ADDON__ADD_ON_SUM_INSURED,
        cast(null as varchar) as RISK_MOTOR_CPA__COMPULSORY_PA_EFFECTIVE_DATE,
        cast(null as varchar) as RISK_MOTOR_CPA__COMPULSORY_PA_EXPIRY_DATE,
        t0.pa_dft_flag as RISK_MOTOR_CPA__COMPULSORY_PA_OWNER_DRIVER_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_CPA__COMPULSORY_PA_PREMIUM,
        cast(null as varchar) as RISK_MOTOR_CPA__COMPULSORY_PA_SUM_INSURED,
        t0.pa_exemption_flag as RISK_MOTOR_CPA__COMPULSORY_PA_WAIVER_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        cast(null as varchar) as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        cast(null as varchar) as RISK_MOTOR_FITMENTS__FITMENT_VALUE,
        cast(null as varchar) as RISK_MOTOR_FITMENTS__SUM_INSURED,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__BREAK_IN_INSURANCE_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__IDV_PREVIOUS_YEAR,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__NCB_CARRIED_FORWARD_PERCENTAGE,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__NCB_ELIGIBLE_INDICATOR,
        t0.ncb_rate as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_COUNT,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_ADDRESS,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_CODE,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_NAME,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_NCB_PERCENTAGE,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EFFECTIVE_FROM_DATE,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_NUMBER,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as RISK_MOTOR_NCB_HISTORY__TRANSFER_OF_NCB_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_TELEMATICS__DRIVING_BEHAVIOUR_SCORE,
        t0.total_km_benefit as RISK_MOTOR_TELEMATICS__INCLUDED_KILOMETRES,
        t0.decl_km_as_on_date as RISK_MOTOR_TELEMATICS__ODOMETER_READING,
        t0.payg_rid as RISK_MOTOR_TELEMATICS__PLAN_EFFECTIVE_DATE,
        cast(null as varchar) as RISK_MOTOR_TELEMATICS__SCORE_DATE,
        t0.km_top_up as RISK_MOTOR_TELEMATICS__TOP_UP_KILOMETRE_SLAB,
        t0.pay_c_km_type as RISK_MOTOR_TELEMATICS__USAGE_BASED_PLAN_TYPE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '')) is not null

    union all

    -- branch 1: BA_QUOTE_MOT_DTLS | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=PACKAGE
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'PACKAGE' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        null,
        t0.addon_package_id as RISK_MOTOR_ADDON__ADD_ON_PACKAGE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '')) is not null

    union all

    -- branch 2: BA_QUOTE_MOT_DTLS | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.total_elec_acc_iev as RISK_MOTOR_FITMENTS__FITMENT_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '')) is not null

    union all

    -- branch 3: BA_QUOTE_MOT_DTLS | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=NON_ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.total_nonelec_acc_iev as RISK_MOTOR_FITMENTS__FITMENT_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '')) is not null

    union all

    -- branch 4: BGIL_MOTOR_WEBSERVICE_INFO_EQM
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.elgncb_rate as AUG_RISK_MOTOR_NCB_HISTORY__ELIGIBLE_NCB_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.breakin_policy as RISK_MOTOR_NCB_HISTORY__BREAK_IN_INSURANCE_INDICATOR,
        null, null, null,
        t0.ncb_rate as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_webservice_info_eqm') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 5: BGIL_MOTOR_WS_PLAN_DETAILS_EQM | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.elec_acc_total as RISK_MOTOR_FITMENTS__FITMENT_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_plan_details_eqm') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 6: BGIL_MOTOR_WS_PLAN_DETAILS_EQM | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=NON_ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.non_elec_acc_total as RISK_MOTOR_FITMENTS__FITMENT_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_plan_details_eqm') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 7: BGIL_MOTOR_WS_PLAN_DETAILS_EQM
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.ncb as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
        null,
        t0.prv_claim_status as RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_INDICATOR,
        null, null, null,
        t0.prv_ncb as RISK_MOTOR_NCB_HISTORY__PREVIOUS_NCB_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_plan_details_eqm') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 8: BJAZ_CVTP_WS_DATA
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        t0.bodyidv as AUG_RISK_MOTOR_IDV__BODY_IDV,
        null, null, null, null, null, null, null, null, null, null,
        t0.isllcleaner as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CLEANER_INDICATOR,
        t0.llcleanerpremium as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CLEANER_PREMIUM,
        t0.isllconductor as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CONDUCTOR_INDICATOR,
        t0.llconductorpremium as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CONDUCTOR_PREMIUM,
        t0.isllhelper as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_HELPER_INDICATOR,
        t0.llhelperpremium as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_HELPER_PREMIUM,
        t0.isllnfpp as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_INDICATOR,
        t0.llnfpppremium as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_PREMIUM,
        t0.ispacleaner as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CLEANER_INDICATOR,
        t0.pacoverpremcleaner as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CLEANER_PREMIUM,
        t0.ispaconductor as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CONDUCTOR_INDICATOR,
        t0.pacoverpremconductor as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CONDUCTOR_PREMIUM,
        t0.pasuminsuredperemployee as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_EMPLOYEE_OCCUPANT_SUM_INSURED,
        t0.ispahelper as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_HELPER_INDICATOR,
        t0.pacoverpremhelper as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_HELPER_PREMIUM,
        t0.pacoverprempaiddriver as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_PAID_DRIVER_PREMIUM,
        t0.pacoverpillionrider as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_PILLION_RIDER_PREMIUM,
        t0.pacoverunnameddriver as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_DRIVER_PREMIUM,
        null, null, null,
        t0.pacoverpremunnamedperson as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PERSON_PREMIUM,
        null, null, null, null, null, null,
        t0.ncbcf_prevpolicyno as AUG_RISK_MOTOR_NCB_HISTORY__NCB_CARRY_FORWARD_PREVIOUS_POLICY_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.telematics_oddiscper as AUG_RISK_MOTOR_TELEMATICS__TELEMATICS_OWN_DAMAGE_DISCOUNT_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pacoverpremownerdriver as RISK_MOTOR_CPA__COMPULSORY_PA_PREMIUM,
        null, null, null, null, null, null, null, null, null,
        t0.ncbflag as RISK_MOTOR_NCB_HISTORY__NCB_ELIGIBLE_INDICATOR,
        t0.ncbper as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
        null, null,
        t0.ncbcf_previnsurcompanyadd as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_ADDRESS,
        t0.ncbcf_previnsurcompanycode as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_CODE,
        t0.ncbcf_previnsurcompanyname as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_NAME,
        null,
        t0.ncbcf_prevpolicyeffectivedate as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EFFECTIVE_FROM_DATE,
        t0.ncbcf_prevpolicyexpirydate as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EXPIRY_DATE,
        t0.prevpolicyno as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_NUMBER,
        null,
        t0.isncbcarryforward as RISK_MOTOR_NCB_HISTORY__TRANSFER_OF_NCB_INDICATOR,
        t0.telematics_score as RISK_MOTOR_TELEMATICS__DRIVING_BEHAVIOUR_SCORE,
        null, null, null,
        t0.telematics_score_date as RISK_MOTOR_TELEMATICS__SCORE_DATE,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 9: BJAZ_CVTP_WS_DATA | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=NIL_DEPRECIATION
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'NIL_DEPRECIATION' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.addonisnildep as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null,
        t0.addonnildepamt as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 10: BJAZ_CVTP_WS_DATA | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=ADDITIONAL_TOWING
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'ADDITIONAL_TOWING' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.addonisaddtowing as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null,
        t0.addonaddtowingamt as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 11: BJAZ_CVTP_WS_DATA | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=EMI_PROTECTION
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'EMI_PROTECTION' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.addonisemicover as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null,
        t0.addonemicoveramt as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 12: BJAZ_CVTP_WS_DATA | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=RETURN_TO_INVOICE
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'RETURN_TO_INVOICE' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.addonisrti as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null,
        t0.addonrtiamt as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 13: BJAZ_CVTP_WS_DATA | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=NCB_PROTECTION
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'NCB_PROTECTION' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.addonisncbprot as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null,
        t0.addonncbprotamt as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 14: BJAZ_CVTP_WS_DATA | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=CONSUMABLES
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'CONSUMABLES' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.addonisconsumable as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null,
        t0.addonconsumablesamt as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 15: BJAZ_CVTP_WS_DATA | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=ENGINE_PROTECTION
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'ENGINE_PROTECTION' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.addonisengineprot as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null,
        t0.addonengineprotamt as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 16: BJAZ_CVTP_WS_DATA | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=PERSONAL_BELONGINGS
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'PERSONAL_BELONGINGS' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.addonispersonalbelonging as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null,
        t0.addonpersonalbelongingamt as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 17: BJAZ_CVTP_WS_DATA | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=COURTESY_CAR
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'COURTESY_CAR' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.addoniscourtesycar as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null,
        t0.addoncourtesycaramt as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 18: BJAZ_CVTP_WS_DATA | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=NON_ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        null,
        t0.nonelectricaccidv as RISK_MOTOR_FITMENTS__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 19: BJAZ_CVTP_WS_DATA | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        null,
        t0.electricaccidv as RISK_MOTOR_FITMENTS__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 20: BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
    select
        nullif(nullif('IIB:' || nullif(trim(t0.policy_no), ''), 'IIB:'), '') as POLICY_BK,
        nullif(nullif(trim(t0.regno), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.tp_policy_flag as POLICY_EXTERNAL_TP_LINK__STANDALONE_TP_INDICATOR,
        null,
        t0.tp_policy_end_date as POLICY_EXTERNAL_TP_LINK__TP_POLICY_END_DATE,
        t0.tp_policy_start_date as POLICY_EXTERNAL_TP_LINK__TP_POLICY_START_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.idv as RISK_MOTOR_NCB_HISTORY__IDV_PREVIOUS_YEAR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_iib_sudars_policy_dtl_hst_qm') }} t0
    where (coalesce(nullif(nullif('IIB:' || nullif(trim(t0.policy_no), ''), 'IIB:'), ''), nullif(nullif(trim(t0.regno), ''), ''))) is not null

    union all

    -- branch 21: BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=NIL_DEPRECIATION
    select
        null,
        nullif(nullif(trim(t0.regno), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'NIL_DEPRECIATION' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.nil_dep_flag as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_iib_sudars_policy_dtl_hst_qm') }} t0
    where (nullif(nullif(trim(t0.regno), ''), '')) is not null

    union all

    -- branch 22: BJAZ_MOTOR_WEBSERVICE_INFO
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.elgncb_rate as AUG_RISK_MOTOR_NCB_HISTORY__ELIGIBLE_NCB_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.breakin_policy as RISK_MOTOR_NCB_HISTORY__BREAK_IN_INSURANCE_INDICATOR,
        null, null, null,
        t0.ncb_rate as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_webservice_info') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 23: BJAZ_MOTOR_WS_PLAN_DETAILS | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.elec_acc_total as RISK_MOTOR_FITMENTS__FITMENT_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_plan_details') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 24: BJAZ_MOTOR_WS_PLAN_DETAILS | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=NON_ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.non_elec_acc_total as RISK_MOTOR_FITMENTS__FITMENT_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_plan_details') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 25: BJAZ_MOTOR_WS_PLAN_DETAILS
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.ncb as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
        null,
        t0.prv_claim_status as RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_INDICATOR,
        null, null, null,
        t0.prv_ncb as RISK_MOTOR_NCB_HISTORY__PREVIOUS_NCB_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_plan_details') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 26: BJAZ_MOT_ONLINE_POL_DTLS
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null,
        t0.agree_idv_calculated_yn as AUG_RISK_MOTOR_IDV__COMPUTED_IDV_ACCEPTED_INDICATOR,
        null, null, null, null,
        t0.vehicle_iev_to as AUG_RISK_MOTOR_IDV__MAXIMUM_PERMITTED_IDV,
        t0.vehicle_iev_from as AUG_RISK_MOTOR_IDV__MINIMUM_PERMITTED_IDV,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pa_no_of_passengers as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PASSENGER_COUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.prev_ncb_amt as AUG_RISK_MOTOR_NCB_HISTORY__PREVIOUS_NCB_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.tp_fin_type as POLICY_EXTERNAL_TP_LINK__TP_FINANCE_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.ncb_rate as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
        null, null,
        t0.prev_insurer_add as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_ADDRESS,
        null,
        t0.prev_insurer_name as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_NAME,
        t0.prev_ncb_rate as RISK_MOTOR_NCB_HISTORY__PREVIOUS_NCB_PERCENTAGE,
        null,
        t0.prev_policy_expiry_date as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EXPIRY_DATE,
        t0.prev_policy_no as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_NUMBER,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(nullif(trim(t0.policy_ref), ''), ''))) is not null

    union all

    -- branch 27: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=ACCESSORIES_COVER
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'ACCESSORIES_COVER' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.cover_accessories_yn as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 28: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=DRIVER_AND_PASSENGER_COVER
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'DRIVER_AND_PASSENGER_COVER' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.cover_driver_pass_yn as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 29: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=DRIVER_COVER
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'DRIVER_COVER' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.cover_driver_yn as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 30: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=DRIVE_ASSURE
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'DRIVE_ASSURE' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.drive_assure_cover_yn as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 31: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        null,
        t0.total_elec_iev as RISK_MOTOR_FITMENTS__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 32: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=NON_ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        null,
        t0.total_non_elec_iev as RISK_MOTOR_FITMENTS__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 33: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=CNG_KIT, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CNG_KIT' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        null,
        t0.cng_value as RISK_MOTOR_FITMENTS__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 34: BJAZ_MOT_RENEWAL_EXTN
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_age_prof as AUG_RISK_MOTOR_IDV__VEHICLE_AGE_BAND,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.claim_cnt_2yr as AUG_RISK_MOTOR_NCB_HISTORY__CLAIM_COUNT_TWO_YEAR,
        null, null,
        t0.claims_trans_date as AUG_RISK_MOTOR_NCB_HISTORY__LAST_CLAIM_TRANSACTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.pa_rid as RISK_MOTOR_CPA__COMPULSORY_PA_EFFECTIVE_DATE,
        t0.pa_red as RISK_MOTOR_CPA__COMPULSORY_PA_EXPIRY_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.claim_cnt_calc as RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_COUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 35: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=PACKAGE
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'PACKAGE' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        null,
        t0.addon_pkg_id as RISK_MOTOR_ADDON__ADD_ON_PACKAGE_CODE,
        t0.addon_pkg_prem as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 36: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=PACKAGE_URM
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'PACKAGE_URM' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        null,
        t0.addon_pkg_id_urm as RISK_MOTOR_ADDON__ADD_ON_PACKAGE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 37: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=DRIVE_ASSURE
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'DRIVE_ASSURE' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        null, null,
        t0.drive_asur_prem as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 38: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=AH_PACKAGE
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'AH_PACKAGE' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        null, null,
        t0.ah_addon_premium as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        t0.ah_sum_insured as RISK_MOTOR_ADDON__ADD_ON_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 39: BJAZ_MOT_RENEWAL_HIST
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null,
        t0.status as AUG_RISK_MOTOR_IDV__IDV_DERIVATION_STATUS,
        null, null, null, null,
        t0.veh_idv_org as AUG_RISK_MOTOR_IDV__ORIGINAL_IDV_BEFORE_ADJUSTMENT,
        null,
        t0.vehicle_age_prof as AUG_RISK_MOTOR_IDV__VEHICLE_AGE_BAND,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.date_of_clms as AUG_RISK_MOTOR_NCB_HISTORY__CLAIM_DATES_LIST,
        null, null, null, null, null, null, null,
        t0.no_of_clms as AUG_RISK_MOTOR_NCB_HISTORY__REQUOTED_CLAIM_COUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.ncb_rate1 as RISK_MOTOR_NCB_HISTORY__NCB_CARRIED_FORWARD_PERCENTAGE,
        null,
        t0.ncb_rate as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
        t0.no_of_claims as RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_COUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 40: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=PACKAGE
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'PACKAGE' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        null,
        t0.addon_pkg_id as RISK_MOTOR_ADDON__ADD_ON_PACKAGE_CODE,
        t0.addon_pkg_prem as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 41: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=DRIVE_ASSURE
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'DRIVE_ASSURE' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        null, null,
        t0.drive_asur_prem as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 42: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.elecacc_iev as RISK_MOTOR_FITMENTS__FITMENT_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 43: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=NON_ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.non_elecacc_iev as RISK_MOTOR_FITMENTS__FITMENT_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 44: BJAZ_MOT_RNW_LOADER_DATA | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=PACKAGE
    select
        null,
        nullif(nullif(trim(t0.reg_no), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'PACKAGE' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        null, null,
        t0.addon_prem as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_rnw_loader_data') }} t0
    where (nullif(nullif(trim(t0.reg_no), ''), '')) is not null

    union all

    -- branch 45: BJAZ_MOT_RNW_LOADER_DATA
    select
        null,
        nullif(nullif(trim(t0.reg_no), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.ncb as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
        null,
        t0.ncb_claim as RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_INDICATOR,
        null, null, null, null, null,
        t0.iib_end_date as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EXPIRY_DATE,
        t0.prev_policyno as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_NUMBER,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_rnw_loader_data') }} t0
    where (nullif(nullif(trim(t0.reg_no), ''), '')) is not null

    union all

    -- branch 46: BJAZ_MOT_WINBACK_DTLS
    select
        null,
        nullif(nullif(trim(t0.registration_no), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.tppd_res_yn as AUG_RISK_MOTOR_LIABILITY_ADDON__THIRD_PARTY_PROPERTY_DAMAGE_RESTRICTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.cpa_flag as RISK_MOTOR_CPA__COMPULSORY_PA_OWNER_DRIVER_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.ncb as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
        null,
        t0.claim_yn as RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_INDICATOR,
        null, null,
        t0.previous_insurer_name as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_NAME,
        null, null,
        t0.risk_expiry_date as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EXPIRY_DATE,
        t0.prev_policyno as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_NUMBER,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (nullif(nullif(trim(t0.registration_no), ''), '')) is not null

    union all

    -- branch 47: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null,
        t0.your_idv_value as AUG_RISK_MOTOR_IDV__CUSTOMER_PROPOSED_IDV,
        null,
        t0.vehicle_iev_from as AUG_RISK_MOTOR_IDV__IDV_RANGE_LOWER_BOUND,
        t0.vehicle_iev_to as AUG_RISK_MOTOR_IDV__IDV_RANGE_UPPER_BOUND,
        null, null, null,
        t0.agree_idv_calculated_yn as AUG_RISK_MOTOR_IDV__SYSTEM_IDV_ACCEPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.prev_ncb_amt as AUG_RISK_MOTOR_NCB_HISTORY__PREVIOUS_NCB_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.tp_fin_type as POLICY_EXTERNAL_TP_LINK__TP_FINANCE_TYPE,
        null, null, null, null, null, null, null, null, null,
        t0.cover_driver_yn as RISK_MOTOR_CPA__COMPULSORY_PA_OWNER_DRIVER_INDICATOR,
        null,
        t0.pa_cover_val as RISK_MOTOR_CPA__COMPULSORY_PA_SUM_INSURED,
        null, null, null, null, null, null, null, null, null,
        t0.ncb_rate as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
        null, null,
        t0.prev_insurer_add as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_ADDRESS,
        null,
        t0.prev_insurer_name as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_NAME,
        t0.prev_ncb_rate as RISK_MOTOR_NCB_HISTORY__PREVIOUS_NCB_PERCENTAGE,
        null,
        t0.prev_policy_expiry_date as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EXPIRY_DATE,
        t0.prev_policy_no as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_NUMBER,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(nullif(trim(t0.policy_ref), ''), ''))) is not null

    union all

    -- branch 48: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=ACCESSORIES_COVER
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'ACCESSORIES_COVER' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.cover_accessories_yn as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 49: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=DRIVER_AND_PASSENGER_COVER
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'DRIVER_AND_PASSENGER_COVER' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.cover_driver_pass_yn as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 50: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): RISK_MOTOR_ADDON.Add On Code=DRIVE_ASSURE
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'DRIVE_ASSURE' as RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.drive_assure_cover_yn as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 51: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        null,
        t0.total_elec_iev as RISK_MOTOR_FITMENTS__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 52: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=NON_ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        null,
        t0.total_non_elec_iev as RISK_MOTOR_FITMENTS__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 53: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=CNG_KIT, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CNG_KIT' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        null,
        t0.cng_value as RISK_MOTOR_FITMENTS__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 54: BJAZ_SCR_MOT_VEH_DTLS
    select
        null,
        nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.pa_unamed as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PASSENGER_INDICATOR,
        t0.si_per_person as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PASSENGER_SUM_INSURED_PER_PERSON,
        null, null,
        t0.iib_prev_exp_date as AUG_RISK_MOTOR_NCB_HISTORY__BUREAU_REPORTED_PREVIOUS_POLICY_EXPIRY_DATE,
        null, null, null, null, null, null,
        t0.ncb_amount as AUG_RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_AMOUNT,
        t0.claim_pattern as AUG_RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_PATTERN,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.ncb_percent as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
        null, null, null, null, null, null, null,
        t0.od_prev_pol_red as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EXPIRY_DATE,
        t0.od_prev_pol_no as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_NUMBER,
        t0.od_prev_pol_rid as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_START_DATE,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_scr_mot_veh_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 55: BJAZ_SCR_MOT_VEH_DTLS | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        null,
        t0.elec_access_si as RISK_MOTOR_FITMENTS__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_scr_mot_veh_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 56: BJAZ_SCR_MOT_VEH_DTLS | child-key literal(s): RISK_MOTOR_FITMENTS.Fitment Type=NON_ELECTRICAL_ACCESSORY, RISK_MOTOR_FITMENTS.Sequence=1
    select
        null,
        nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        null,
        t0.non_elec_access_si as RISK_MOTOR_FITMENTS__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_scr_mot_veh_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

)

select
    POLICY_BK,
    RISK_OBJECT_BK,
    first_value(AUG_RISK_MOTOR_IDV__BODY_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_IDV__BODY_IDV,
    first_value(AUG_RISK_MOTOR_IDV__COMPUTED_IDV_ACCEPTED_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_IDV__COMPUTED_IDV_ACCEPTED_INDICATOR,
    first_value(AUG_RISK_MOTOR_IDV__CUSTOMER_PROPOSED_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_IDV__CUSTOMER_PROPOSED_IDV,
    first_value(AUG_RISK_MOTOR_IDV__IDV_DERIVATION_STATUS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_IDV__IDV_DERIVATION_STATUS,
    first_value(AUG_RISK_MOTOR_IDV__IDV_RANGE_LOWER_BOUND) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_IDV__IDV_RANGE_LOWER_BOUND,
    first_value(AUG_RISK_MOTOR_IDV__IDV_RANGE_UPPER_BOUND) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_IDV__IDV_RANGE_UPPER_BOUND,
    first_value(AUG_RISK_MOTOR_IDV__MAXIMUM_PERMITTED_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_IDV__MAXIMUM_PERMITTED_IDV,
    first_value(AUG_RISK_MOTOR_IDV__MINIMUM_PERMITTED_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_IDV__MINIMUM_PERMITTED_IDV,
    first_value(AUG_RISK_MOTOR_IDV__ORIGINAL_IDV_BEFORE_ADJUSTMENT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_IDV__ORIGINAL_IDV_BEFORE_ADJUSTMENT,
    first_value(AUG_RISK_MOTOR_IDV__SYSTEM_IDV_ACCEPTED_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_IDV__SYSTEM_IDV_ACCEPTED_INDICATOR,
    first_value(AUG_RISK_MOTOR_IDV__VEHICLE_AGE_BAND) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_IDV__VEHICLE_AGE_BAND,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CLEANER_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CLEANER_INDICATOR,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CLEANER_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CLEANER_PREMIUM,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CONDUCTOR_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CONDUCTOR_INDICATOR,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CONDUCTOR_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CONDUCTOR_PREMIUM,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_HELPER_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_HELPER_INDICATOR,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_HELPER_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_HELPER_PREMIUM,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_INDICATOR,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_PREMIUM,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CLEANER_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CLEANER_INDICATOR,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CLEANER_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CLEANER_PREMIUM,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CONDUCTOR_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CONDUCTOR_INDICATOR,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CONDUCTOR_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_CONDUCTOR_PREMIUM,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_EMPLOYEE_OCCUPANT_SUM_INSURED) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_EMPLOYEE_OCCUPANT_SUM_INSURED,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_HELPER_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_HELPER_INDICATOR,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_HELPER_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_HELPER_PREMIUM,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_PAID_DRIVER_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_PAID_DRIVER_PREMIUM,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_PILLION_RIDER_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_PILLION_RIDER_PREMIUM,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_DRIVER_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_DRIVER_PREMIUM,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PASSENGER_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PASSENGER_COUNT,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PASSENGER_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PASSENGER_INDICATOR,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PASSENGER_SUM_INSURED_PER_PERSON) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PASSENGER_SUM_INSURED_PER_PERSON,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PERSON_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__PA_UNNAMED_PERSON_PREMIUM,
    first_value(AUG_RISK_MOTOR_LIABILITY_ADDON__THIRD_PARTY_PROPERTY_DAMAGE_RESTRICTED_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LIABILITY_ADDON__THIRD_PARTY_PROPERTY_DAMAGE_RESTRICTED_INDICATOR,
    first_value(AUG_RISK_MOTOR_NCB_HISTORY__BUREAU_REPORTED_PREVIOUS_POLICY_EXPIRY_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_NCB_HISTORY__BUREAU_REPORTED_PREVIOUS_POLICY_EXPIRY_DATE,
    first_value(AUG_RISK_MOTOR_NCB_HISTORY__CLAIM_COUNT_TWO_YEAR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_NCB_HISTORY__CLAIM_COUNT_TWO_YEAR,
    first_value(AUG_RISK_MOTOR_NCB_HISTORY__CLAIM_DATES_LIST) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_NCB_HISTORY__CLAIM_DATES_LIST,
    first_value(AUG_RISK_MOTOR_NCB_HISTORY__ELIGIBLE_NCB_PERCENTAGE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_NCB_HISTORY__ELIGIBLE_NCB_PERCENTAGE,
    first_value(AUG_RISK_MOTOR_NCB_HISTORY__LAST_CLAIM_TRANSACTION_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_NCB_HISTORY__LAST_CLAIM_TRANSACTION_DATE,
    first_value(AUG_RISK_MOTOR_NCB_HISTORY__NCB_CARRY_FORWARD_PREVIOUS_POLICY_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_NCB_HISTORY__NCB_CARRY_FORWARD_PREVIOUS_POLICY_NUMBER,
    first_value(AUG_RISK_MOTOR_NCB_HISTORY__NCB_SOURCE_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_NCB_HISTORY__NCB_SOURCE_CODE,
    first_value(AUG_RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_AMOUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_AMOUNT,
    first_value(AUG_RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_PATTERN) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_PATTERN,
    first_value(AUG_RISK_MOTOR_NCB_HISTORY__PREVIOUS_NCB_AMOUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_NCB_HISTORY__PREVIOUS_NCB_AMOUNT,
    first_value(AUG_RISK_MOTOR_NCB_HISTORY__REQUOTED_CLAIM_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_NCB_HISTORY__REQUOTED_CLAIM_COUNT,
    first_value(AUG_RISK_MOTOR_TELEMATICS__APPLICABLE_KILOMETRE_RANGE_FROM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_TELEMATICS__APPLICABLE_KILOMETRE_RANGE_FROM,
    first_value(AUG_RISK_MOTOR_TELEMATICS__APPLICABLE_KILOMETRE_RANGE_TO) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_TELEMATICS__APPLICABLE_KILOMETRE_RANGE_TO,
    first_value(AUG_RISK_MOTOR_TELEMATICS__BONUS_KILOMETRES) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_TELEMATICS__BONUS_KILOMETRES,
    first_value(AUG_RISK_MOTOR_TELEMATICS__PLAN_EFFECTIVE_TIME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_TELEMATICS__PLAN_EFFECTIVE_TIME,
    first_value(AUG_RISK_MOTOR_TELEMATICS__PLAN_EXPIRY_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_TELEMATICS__PLAN_EXPIRY_DATE,
    first_value(AUG_RISK_MOTOR_TELEMATICS__TELEMATICS_OWN_DAMAGE_DISCOUNT_PERCENTAGE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_TELEMATICS__TELEMATICS_OWN_DAMAGE_DISCOUNT_PERCENTAGE,
    first_value(AUG_RISK_MOTOR_TELEMATICS__TRIP_DESTINATION) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_TELEMATICS__TRIP_DESTINATION,
    first_value(AUG_RISK_MOTOR_TELEMATICS__TRIP_END_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_TELEMATICS__TRIP_END_DATE,
    first_value(AUG_RISK_MOTOR_TELEMATICS__TRIP_ORIGIN) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_TELEMATICS__TRIP_ORIGIN,
    first_value(AUG_RISK_MOTOR_TELEMATICS__TRIP_START_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_TELEMATICS__TRIP_START_DATE,
    first_value(POLICY_EXTERNAL_TP_LINK__STANDALONE_TP_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXTERNAL_TP_LINK__STANDALONE_TP_INDICATOR,
    first_value(POLICY_EXTERNAL_TP_LINK__TP_FINANCE_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXTERNAL_TP_LINK__TP_FINANCE_TYPE,
    first_value(POLICY_EXTERNAL_TP_LINK__TP_POLICY_END_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXTERNAL_TP_LINK__TP_POLICY_END_DATE,
    first_value(POLICY_EXTERNAL_TP_LINK__TP_POLICY_START_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXTERNAL_TP_LINK__TP_POLICY_START_DATE,
    RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
    first_value(RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_ADDON__ADD_ON_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR,
    first_value(RISK_MOTOR_ADDON__ADD_ON_PACKAGE_CODE) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_ADDON__ADD_ON_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_ADDON__ADD_ON_PACKAGE_CODE,
    first_value(RISK_MOTOR_ADDON__ADD_ON_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_ADDON__ADD_ON_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_ADDON__ADD_ON_PREMIUM,
    first_value(RISK_MOTOR_ADDON__ADD_ON_SUM_INSURED) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_ADDON__ADD_ON_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_ADDON__ADD_ON_SUM_INSURED,
    first_value(RISK_MOTOR_CPA__COMPULSORY_PA_EFFECTIVE_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__COMPULSORY_PA_EFFECTIVE_DATE,
    first_value(RISK_MOTOR_CPA__COMPULSORY_PA_EXPIRY_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__COMPULSORY_PA_EXPIRY_DATE,
    first_value(RISK_MOTOR_CPA__COMPULSORY_PA_OWNER_DRIVER_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__COMPULSORY_PA_OWNER_DRIVER_INDICATOR,
    first_value(RISK_MOTOR_CPA__COMPULSORY_PA_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__COMPULSORY_PA_PREMIUM,
    first_value(RISK_MOTOR_CPA__COMPULSORY_PA_SUM_INSURED) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__COMPULSORY_PA_SUM_INSURED,
    first_value(RISK_MOTOR_CPA__COMPULSORY_PA_WAIVER_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__COMPULSORY_PA_WAIVER_INDICATOR,
    RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
    RISK_MOTOR_FITMENTS__SEQUENCE_CK,
    first_value(RISK_MOTOR_FITMENTS__FITMENT_VALUE) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK, RISK_MOTOR_FITMENTS__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_FITMENTS__FITMENT_VALUE,
    first_value(RISK_MOTOR_FITMENTS__SUM_INSURED) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK, RISK_MOTOR_FITMENTS__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_FITMENTS__SUM_INSURED,
    first_value(RISK_MOTOR_NCB_HISTORY__BREAK_IN_INSURANCE_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__BREAK_IN_INSURANCE_INDICATOR,
    first_value(RISK_MOTOR_NCB_HISTORY__IDV_PREVIOUS_YEAR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__IDV_PREVIOUS_YEAR,
    first_value(RISK_MOTOR_NCB_HISTORY__NCB_CARRIED_FORWARD_PERCENTAGE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__NCB_CARRIED_FORWARD_PERCENTAGE,
    first_value(RISK_MOTOR_NCB_HISTORY__NCB_ELIGIBLE_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__NCB_ELIGIBLE_INDICATOR,
    first_value(RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__NO_CLAIM_BONUS_PERCENTAGE,
    first_value(RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_COUNT,
    first_value(RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_CLAIM_INDICATOR,
    first_value(RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_ADDRESS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_ADDRESS,
    first_value(RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_CODE,
    first_value(RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_NAME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_INSURER_NAME,
    first_value(RISK_MOTOR_NCB_HISTORY__PREVIOUS_NCB_PERCENTAGE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_NCB_PERCENTAGE,
    first_value(RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EFFECTIVE_FROM_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EFFECTIVE_FROM_DATE,
    first_value(RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EXPIRY_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_EXPIRY_DATE,
    first_value(RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_NUMBER,
    first_value(RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_START_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__PREVIOUS_POLICY_START_DATE,
    first_value(RISK_MOTOR_NCB_HISTORY__TRANSFER_OF_NCB_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_NCB_HISTORY__TRANSFER_OF_NCB_INDICATOR,
    first_value(RISK_MOTOR_TELEMATICS__DRIVING_BEHAVIOUR_SCORE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_TELEMATICS__DRIVING_BEHAVIOUR_SCORE,
    first_value(RISK_MOTOR_TELEMATICS__INCLUDED_KILOMETRES) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_TELEMATICS__INCLUDED_KILOMETRES,
    first_value(RISK_MOTOR_TELEMATICS__ODOMETER_READING) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_TELEMATICS__ODOMETER_READING,
    first_value(RISK_MOTOR_TELEMATICS__PLAN_EFFECTIVE_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_TELEMATICS__PLAN_EFFECTIVE_DATE,
    first_value(RISK_MOTOR_TELEMATICS__SCORE_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_TELEMATICS__SCORE_DATE,
    first_value(RISK_MOTOR_TELEMATICS__TOP_UP_KILOMETRE_SLAB) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_TELEMATICS__TOP_UP_KILOMETRE_SLAB,
    first_value(RISK_MOTOR_TELEMATICS__USAGE_BASED_PLAN_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_TELEMATICS__USAGE_BASED_PLAN_TYPE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on RISK_OBJECT_BK (SAT_RISK_MOTOR_ADDON, SAT_RISK_MOTOR_FITMENTS):
    -- one load time per RISK_OBJECT_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.RISK_MOTOR_ADDON__ADD_ON_OPTED_INDICATOR, m.RISK_MOTOR_ADDON__ADD_ON_PACKAGE_CODE, m.RISK_MOTOR_ADDON__ADD_ON_PREMIUM, m.RISK_MOTOR_ADDON__ADD_ON_SUM_INSURED, m.RISK_MOTOR_FITMENTS__FITMENT_VALUE, m.RISK_MOTOR_FITMENTS__SUM_INSURED) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.RISK_OBJECT_BK) as RISK_OBJECT_BK__MA_LOAD_DATETIME
from merged m
