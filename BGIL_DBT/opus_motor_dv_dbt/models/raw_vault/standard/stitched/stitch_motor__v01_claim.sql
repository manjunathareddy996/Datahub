-- CENTRAL VIEW v01_claim -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BJAZ_CLM_BASE_MOT_EXT
--   BJAZ_CLM_MOTOR_INTIM_DETAILS
--   BJAZ_CLM_MOT_TAX_DTLS
--   BJAZ_MOT_CLM_CDC_DTLS
--   BJAZ_MOT_CLM_COMPARABLE_DTLS
--   BJAZ_MOT_CLM_IP_DMG_EXTN
--   BJAZ_WB_CLM_BASE_MOT_EXT
--   BJAZ_WB_CLM_IP_MOT_EXT
--   BJAZ_WS_MOTCLM_DETAILS
--   BJAZ_WS_MOTCLM_SURVEY_DTLS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_ASSESSMENT_HEADER
--   SAT_AUG_CLAIM_ASSESSMENT_SUMMARY
--   SAT_AUG_CLAIM_COMPARABLE_CLAIM
--   SAT_AUG_CLAIM_DOC_CHECKLIST
--   SAT_AUG_CLAIM_FNOL
--   SAT_AUG_CLAIM_HEADER
--   SAT_AUG_CLAIM_MOTOR_DETAIL
--   SAT_AUG_CLAIM_SLA_TRACKING
--   SAT_AUG_CLAIM_THIRD_PARTY_LINE
--   SAT_AUG_CLAIM_THIRD_PARTY_MACT
--   SAT_CLAIM_ASSESSMENT_SUMMARY
--   SAT_CLAIM_FNOL
--   SAT_CLAIM_SLA_TRACKING
--   SAT_LOSS_EVENT_DETAIL
--   SAT_LOSS_LOCATION_ADDRESS
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_ASSESSMENT
--   LNK_CLAIM_LOSS_EVENT
--   LNK_CLAIM_POLICY
--   LNK_CLAIM_RISK_OBJECT
--   LNK_LOSS_EVENT_RISK_OBJECT
--   LNK_POLICY_RISK_OBJECT
--   LNK_RISK_OBJECT_ASSESSMENT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_CLM_BASE_MOT_EXT | child-key literal(s): AUG_CLAIM_DOC_CHECKLIST.Document Type=IDENTY_PROFF
    select
        cast(null as varchar) as ASSESSMENT_BK,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        cast(null as varchar) as LOSS_EVENT_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_CLAIM_ASSESSMENT,
        cast(null as number) as __LNK_CLAIM_LOSS_EVENT,
        cast(null as number) as __LNK_CLAIM_POLICY,
        cast(null as number) as __LNK_CLAIM_RISK_OBJECT,
        cast(null as number) as __LNK_LOSS_EVENT_RISK_OBJECT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_ASSESSMENT,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__ASSESSMENT_VERSION_NUMBER,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__INSPECTION_TRANSACTION_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_ASSESSMENT_SUMMARY__VOLUNTARY_EXCESS_DEDUCTED,
        cast(null as varchar) as AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE_CK,
        cast(null as varchar) as AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_COMPARABLE_CLAIM__COMPARISON_SOURCE,
        cast(null as varchar) as AUG_CLAIM_DOC_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
        'IDENTY_PROFF' as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
        cast(null as varchar) as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_NUMBER,
        t0.identy_proff as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_SUBMITTED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE,
        cast(null as varchar) as AUG_CLAIM_FNOL__ALTERNATE_REPORTED_BY_CONTACT,
        cast(null as varchar) as AUG_CLAIM_FNOL__REASON_FOR_NO_CONTACT,
        cast(null as varchar) as AUG_CLAIM_FNOL__REPORTED_BY_EMAIL_ADDRESS,
        cast(null as varchar) as AUG_CLAIM_FNOL__WEB_SUBMISSION_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_HEADER__CLAIM_OBSERVATION_TEXT,
        cast(null as varchar) as AUG_CLAIM_HEADER__CONTACT_PERSON_NAME,
        cast(null as varchar) as AUG_CLAIM_HEADER__DIGITAL_REGISTRATION_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_HEADER__DOCUMENT_CHECK_BY_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_HEADER__DOCUMENT_CHECK_DATE,
        cast(null as varchar) as AUG_CLAIM_HEADER__DOCUMENT_RECEIVED_DATE,
        cast(null as varchar) as AUG_CLAIM_HEADER__DOCUMENT_VERIFIED_BY_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_HEADER__DOCUMENT_VERIFIED_DATE,
        cast(null as varchar) as AUG_CLAIM_HEADER__FAST_TRACK_FLAG_CHANGED_BY_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_HEADER__FAST_TRACK_FLAG_CHANGED_DATE,
        cast(null as varchar) as AUG_CLAIM_HEADER__FLAG_SET_DATE,
        cast(null as varchar) as AUG_CLAIM_HEADER__FPLM_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_HEADER__FPLM_REASON,
        cast(null as varchar) as AUG_CLAIM_HEADER__HOUSEHOLD_IDENTIFIER,
        cast(null as varchar) as AUG_CLAIM_HEADER__LIABILITY_SMS_SENT_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_HEADER__LOSS_EVENT_CODE,
        cast(null as varchar) as AUG_CLAIM_HEADER__NCB_ENDORSEMENT_NUMBER,
        cast(null as varchar) as AUG_CLAIM_HEADER__OTHER_INTIMATION_CHANNEL_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_HEADER__OTHER_REASON_TEXT,
        cast(null as varchar) as AUG_CLAIM_HEADER__POLICY_YEAR_OF_CLAIM,
        cast(null as varchar) as AUG_CLAIM_HEADER__PROCESSOR_REMARKS,
        cast(null as varchar) as AUG_CLAIM_HEADER__REGISTERING_USER_TYPE,
        cast(null as varchar) as AUG_CLAIM_HEADER__RELATED_ENDORSEMENT_APPROVED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_HEADER__RELATED_ENDORSEMENT_VERSION,
        cast(null as varchar) as AUG_CLAIM_HEADER__SUPPLEMENTARY_CLAIM_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_HEADER__UNQUALIFIED_REASON_TEXT,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__CHASSIS_DAMAGE_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__DAMAGED_TYRE_COUNT,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__DAMAGE_CAPTURE_DEVICE_SOURCE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__DENTING_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__DEVICE_MAKE_AND_MODEL,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__DEVICE_SERIAL_NUMBER,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_EXPIRY_DATE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_ISSUE_DATE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_TYPE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__DRIVER_NAME_VERIFIED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__DRIVER_RELATIONSHIP_TO_INSURED,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__FAULT_ATTRIBUTED_TO_PARTY,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__FAULT_ATTRIBUTED_TO_ROLE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__FIRE_DAMAGE_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__FRONT_DAMAGE_CODE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__FUEL_TANK_DAMAGE_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__GOODS_TYPE_CARRIED,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__INSPECTION_LOCATION_TEXT,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__INSURED_VEHICLE_INTERNAL_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__INSURED_VEHICLE_INTERNAL_VERSION,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__JOURNEY_DESTINATION_CITY,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__JOURNEY_ORIGIN_CITY,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__KILOMETRE_LIMIT,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__LEFT_SIDE_DAMAGE_CODE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__METAL_PARTS_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__MISCELLANEOUS_ASSESSED_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__ODOMETER_DISCREPANCY_REASON,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__ODOMETER_READING_AT_LOSS,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__OWN_REPAIRER_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__PARTIAL_THEFT_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__PLASTIC_PARTS_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__REAR_DAMAGE_CODE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__REAR_GLASS_DAMAGE_CODE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__REPAIR_INVOICE_NUMBER,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__RIGHT_SIDE_DAMAGE_CODE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__RIM_WITH_TYRE_DAMAGE_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__ROLL_OVER_DAMAGE_CODE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__ROOF_DAMAGE_CODE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__SILENCER_DAMAGE_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__SPOT_SURVEY_UPDATE_TEXT,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__SURVEYOR_UPDATE_TEXT,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__TRAFFIC_CHALLAN_DATE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__TRAFFIC_CHALLAN_DETAILS,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__TYRE_DAMAGE_CODE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__UNCLASSIFIED_DAMAGE_CODE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__UNDERSIDE_DAMAGE_CODE,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__VEHICLE_INSPECTION_CARRIED_OUT_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__VEHICLE_LYING_LOCATION_TEXT,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__WATER_FLOOD_DAMAGE_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_MOTOR_DETAIL__WEIGHT_CARRIED_AT_LOSS,
        cast(null as varchar) as AUG_CLAIM_SLA_TRACKING__FOLLOW_UP_REQUIRED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_SLA_TRACKING__PROCESSING_DELAY_REASON,
        cast(null as varchar) as AUG_CLAIM_SLA_TRACKING__REQUIREMENT_FULFILLED_DATE,
        cast(null as varchar) as AUG_CLAIM_SLA_TRACKING__REQUIREMENT_FULFILLED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_SLA_TRACKING__WORKFLOW_ACTION,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__DAMAGED_OBJECT,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__DAMAGED_OBJECT_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__DAMAGE_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__DAMAGE_KIND,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__DISABILITY_TYPE,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__INJURY_DETAILS,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__INJURY_TYPE,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__PERIOD_OF_DISABLEMENT,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_DRIVER_LICENCE_EXPIRY_DATE,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_DRIVER_LICENCE_NUMBER,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_BRANCH,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_CONTACT_NUMBER,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_NAME,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_POLICY_NUMBER,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_ADDRESS_TEXT,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_AGE,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_DECLARED_INCOME,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_GENDER_CODE,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_NAME,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_OCCUPATION,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__WORK_CEASED_DATE,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_LINE__WORK_RESUMED_DATE,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_MACT__NEGLIGENCE_DETAILS,
        cast(null as varchar) as CLAIM_ASSESSMENT_SUMMARY__ASSESSED_LOSS_AMOUNT,
        cast(null as varchar) as CLAIM_ASSESSMENT_SUMMARY__EXCESS_DEDUCTED,
        cast(null as varchar) as CLAIM_ASSESSMENT_SUMMARY__SALVAGE_AMOUNT,
        cast(null as varchar) as CLAIM_ASSESSMENT_SUMMARY__TOTAL_DEDUCTION_AMOUNT,
        cast(null as varchar) as CLAIM_FNOL__FNOL_DATE,
        cast(null as varchar) as CLAIM_FNOL__LOCATION_OF_LOSS,
        cast(null as varchar) as CLAIM_FNOL__PRELIMINARY_LOSS_DESCRIPTION,
        cast(null as varchar) as CLAIM_FNOL__PRELIMINARY_LOSS_ESTIMATE,
        cast(null as varchar) as CLAIM_FNOL__RELATIONSHIP_TO_INSURED,
        cast(null as varchar) as CLAIM_FNOL__REPORTED_BY_CONTACT,
        cast(null as varchar) as CLAIM_FNOL__REPORTED_BY_NAME,
        cast(null as varchar) as CLAIM_SLA_TRACKING__LAST_ACTION_DATE,
        cast(null as varchar) as CLAIM_SLA_TRACKING__PENDING_WITH_ROLE,
        cast(null as varchar) as LOSS_EVENT_DETAIL__CAUSE_OF_LOSS,
        cast(null as varchar) as LOSS_EVENT_DETAIL__ESTIMATED_LOSS_AMOUNT,
        cast(null as varchar) as LOSS_EVENT_DETAIL__FIR_NUMBER,
        cast(null as varchar) as LOSS_EVENT_DETAIL__LOSS_DATE,
        cast(null as varchar) as LOSS_EVENT_DETAIL__LOSS_DESCRIPTION,
        cast(null as varchar) as LOSS_EVENT_DETAIL__LOSS_EVENT_TYPE,
        cast(null as varchar) as LOSS_EVENT_DETAIL__LOSS_TIME,
        cast(null as varchar) as LOSS_EVENT_DETAIL__PERIL_CODE,
        cast(null as varchar) as LOSS_EVENT_DETAIL__POLICE_STATION_NAME,
        cast(null as varchar) as LOSS_EVENT_DETAIL__SUB_PERIL_CODE,
        cast(null as varchar) as LOSS_EVENT_DETAIL__THIRD_PARTY_INVOLVED_INDICATOR,
        cast(null as varchar) as LOSS_LOCATION_ADDRESS__ADDRESS_LINE_1,
        cast(null as varchar) as LOSS_LOCATION_ADDRESS__ADDRESS_LINE_2,
        cast(null as varchar) as LOSS_LOCATION_ADDRESS__CITY,
        cast(null as varchar) as LOSS_LOCATION_ADDRESS__LANDMARK,
        cast(null as varchar) as LOSS_LOCATION_ADDRESS__POSTAL_CODE,
        cast(null as varchar) as LOSS_LOCATION_ADDRESS__STATE_CODE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 1: BJAZ_CLM_BASE_MOT_EXT | child-key literal(s): AUG_CLAIM_DOC_CHECKLIST.Document Type=ADDRESS_PROOF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ADDRESS_PROOF' as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
        null,
        t0.address_proof as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_SUBMITTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 2: BJAZ_CLM_BASE_MOT_EXT | child-key literal(s): AUG_CLAIM_DOC_CHECKLIST.Document Type=INCOME_PROOF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INCOME_PROOF' as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
        null,
        t0.income_proff as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_SUBMITTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 3: BJAZ_CLM_BASE_MOT_EXT
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null,
        nullif(nullif(trim(t0.cert_policy_ref), ''), '') as POLICY_BK,
        null, null, null,
        1 as __LNK_CLAIM_POLICY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.alter_conact_no as AUG_CLAIM_FNOL__ALTERNATE_REPORTED_BY_CONTACT,
        t0.reason_no_contact as AUG_CLAIM_FNOL__REASON_FOR_NO_CONTACT,
        t0.cust_email_id as AUG_CLAIM_FNOL__REPORTED_BY_EMAIL_ADDRESS,
        null, null,
        t0.contact_person as AUG_CLAIM_HEADER__CONTACT_PERSON_NAME,
        null,
        t0.doc_check_by as AUG_CLAIM_HEADER__DOCUMENT_CHECK_BY_REFERENCE,
        t0.doc_check_date as AUG_CLAIM_HEADER__DOCUMENT_CHECK_DATE,
        t0.doc_rec_date as AUG_CLAIM_HEADER__DOCUMENT_RECEIVED_DATE,
        null, null, null, null, null, null, null,
        t0.hhid as AUG_CLAIM_HEADER__HOUSEHOLD_IDENTIFIER,
        null,
        t0.event_code as AUG_CLAIM_HEADER__LOSS_EVENT_CODE,
        null,
        t0.others_mode_intimation as AUG_CLAIM_HEADER__OTHER_INTIMATION_CHANNEL_DESCRIPTION,
        null, null, null, null, null, null, null, null, null,
        t0.no_of_tyers as AUG_CLAIM_MOTOR_DETAIL__DAMAGED_TYRE_COUNT,
        null, null,
        t0.device_make_model as AUG_CLAIM_MOTOR_DETAIL__DEVICE_MAKE_AND_MODEL,
        t0.device_serial_no as AUG_CLAIM_MOTOR_DETAIL__DEVICE_SERIAL_NUMBER,
        null, null, null, null, null,
        t0.fault_by as AUG_CLAIM_MOTOR_DETAIL__FAULT_ATTRIBUTED_TO_PARTY,
        null, null, null, null, null, null, null, null, null, null,
        t0.km_limit as AUG_CLAIM_MOTOR_DETAIL__KILOMETRE_LIMIT,
        null, null, null, null, null, null, null, null, null, null,
        t0.invoice_no as AUG_CLAIM_MOTOR_DETAIL__REPAIR_INVOICE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.reason_delay_processing as AUG_CLAIM_SLA_TRACKING__PROCESSING_DELAY_REASON,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.place_of_loss as CLAIM_FNOL__LOCATION_OF_LOSS,
        t0.loss_desc as CLAIM_FNOL__PRELIMINARY_LOSS_DESCRIPTION,
        null, null,
        t0.mobile_no as CLAIM_FNOL__REPORTED_BY_CONTACT,
        t0.notified_by as CLAIM_FNOL__REPORTED_BY_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_base_mot_ext') }} t0
    where (coalesce(nullif(nullif(trim(t0.cert_policy_ref), ''), ''), nullif(nullif(trim(to_char(t0.claim_id)), ''), ''))) is not null

    union all

    -- branch 4: BJAZ_CLM_MOTOR_INTIM_DETAILS
    select
        null,
        nullif(nullif('INTIMATION:' || nullif(trim(t0.intimation_id), ''), 'INTIMATION:'), '') as CLAIM_BK,
        nullif(md5(normalise(upper(nullif('LOSSEVENT:' || coalesce(t0.intimation_id, ''), 'LOSSEVENT:')))), '') as LOSS_EVENT_BK,
        null, null, null,
        1 as __LNK_CLAIM_LOSS_EVENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.drv_lic_exp as AUG_CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_EXPIRY_DATE,
        null, null, null,
        t0.driver_relation as AUG_CLAIM_MOTOR_DETAIL__DRIVER_RELATIONSHIP_TO_INSURED,
        null, null, null, null, null, null,
        t0.where_inspect as AUG_CLAIM_MOTOR_DETAIL__INSPECTION_LOCATION_TEXT,
        null, null, null, null, null, null, null, null, null,
        t0.odo_reading as AUG_CLAIM_MOTOR_DETAIL__ODOMETER_READING_AT_LOSS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.where_lying as AUG_CLAIM_MOTOR_DETAIL__VEHICLE_LYING_LOCATION_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.claim_location as CLAIM_FNOL__LOCATION_OF_LOSS,
        null,
        t0.est_loss_amount as CLAIM_FNOL__PRELIMINARY_LOSS_ESTIMATE,
        null,
        t0.caller_telephone as CLAIM_FNOL__REPORTED_BY_CONTACT,
        t0.caller_name as CLAIM_FNOL__REPORTED_BY_NAME,
        null, null,
        t0.cause_of_loss as LOSS_EVENT_DETAIL__CAUSE_OF_LOSS,
        null, null, null,
        t0.loss_desc as LOSS_EVENT_DETAIL__LOSS_DESCRIPTION,
        t0.loss_type as LOSS_EVENT_DETAIL__LOSS_EVENT_TYPE,
        t0.time_of_loss as LOSS_EVENT_DETAIL__LOSS_TIME,
        null, null, null, null,
        t0.clm_street as LOSS_LOCATION_ADDRESS__ADDRESS_LINE_1,
        t0.clm_area as LOSS_LOCATION_ADDRESS__ADDRESS_LINE_2,
        t0.clm_city as LOSS_LOCATION_ADDRESS__CITY,
        t0.clm_landmark as LOSS_LOCATION_ADDRESS__LANDMARK,
        t0.clm_pincode as LOSS_LOCATION_ADDRESS__POSTAL_CODE,
        t0.clm_state as LOSS_LOCATION_ADDRESS__STATE_CODE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_motor_intim_details') }} t0
    where (coalesce(nullif(md5(normalise(upper(nullif('LOSSEVENT:' || coalesce(t0.intimation_id, ''), 'LOSSEVENT:')))), ''), nullif(nullif('INTIMATION:' || nullif(trim(t0.intimation_id), ''), 'INTIMATION:'), ''))) is not null

    union all

    -- branch 5: BJAZ_CLM_MOT_TAX_DTLS
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.email_id as AUG_CLAIM_FNOL__REPORTED_BY_EMAIL_ADDRESS,
        t0.flag_web as AUG_CLAIM_FNOL__WEB_SUBMISSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.driver_lic_issue_date as AUG_CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_ISSUE_DATE,
        t0.driving_license_type as AUG_CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_TYPE,
        null, null, null, null, null, null, null,
        t0.goods_type as AUG_CLAIM_MOTOR_DETAIL__GOODS_TYPE_CARRIED,
        null, null, null,
        t0.destination as AUG_CLAIM_MOTOR_DETAIL__JOURNEY_DESTINATION_CITY,
        t0.origin_place as AUG_CLAIM_MOTOR_DETAIL__JOURNEY_ORIGIN_CITY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.spot_sur_update as AUG_CLAIM_MOTOR_DETAIL__SPOT_SURVEY_UPDATE_TEXT,
        t0.surveyor_update as AUG_CLAIM_MOTOR_DETAIL__SURVEYOR_UPDATE_TEXT,
        t0.challan_date as AUG_CLAIM_MOTOR_DETAIL__TRAFFIC_CHALLAN_DATE,
        t0.challan_dtls as AUG_CLAIM_MOTOR_DETAIL__TRAFFIC_CHALLAN_DETAILS,
        null, null, null, null, null, null,
        t0.weight_carried as AUG_CLAIM_MOTOR_DETAIL__WEIGHT_CARRIED_AT_LOSS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.telephone_no as CLAIM_FNOL__REPORTED_BY_CONTACT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_mot_tax_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 6: BJAZ_MOT_CLM_CDC_DTLS
    select
        null,
        nullif(nullif(trim(t0.claim_ref), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.chassis as AUG_CLAIM_MOTOR_DETAIL__CHASSIS_DAMAGE_INDICATOR,
        null,
        t0.device_source as AUG_CLAIM_MOTOR_DETAIL__DAMAGE_CAPTURE_DEVICE_SOURCE,
        null, null, null, null, null, null, null, null, null, null,
        t0.fire as AUG_CLAIM_MOTOR_DETAIL__FIRE_DAMAGE_INDICATOR,
        t0.front_code as AUG_CLAIM_MOTOR_DETAIL__FRONT_DAMAGE_CODE,
        t0.fuel_tank as AUG_CLAIM_MOTOR_DETAIL__FUEL_TANK_DAMAGE_INDICATOR,
        null, null, null, null, null, null, null,
        t0.left_code as AUG_CLAIM_MOTOR_DETAIL__LEFT_SIDE_DAMAGE_CODE,
        null, null, null, null, null,
        t0.partial_theft as AUG_CLAIM_MOTOR_DETAIL__PARTIAL_THEFT_INDICATOR,
        null,
        t0.back_code as AUG_CLAIM_MOTOR_DETAIL__REAR_DAMAGE_CODE,
        t0.rearglass_code as AUG_CLAIM_MOTOR_DETAIL__REAR_GLASS_DAMAGE_CODE,
        null,
        t0.right_code as AUG_CLAIM_MOTOR_DETAIL__RIGHT_SIDE_DAMAGE_CODE,
        t0.rim_with_tyre as AUG_CLAIM_MOTOR_DETAIL__RIM_WITH_TYRE_DAMAGE_INDICATOR,
        t0.roll_over_code as AUG_CLAIM_MOTOR_DETAIL__ROLL_OVER_DAMAGE_CODE,
        t0.top_code as AUG_CLAIM_MOTOR_DETAIL__ROOF_DAMAGE_CODE,
        t0.silencer as AUG_CLAIM_MOTOR_DETAIL__SILENCER_DAMAGE_INDICATOR,
        null, null, null, null,
        t0.tire_code as AUG_CLAIM_MOTOR_DETAIL__TYRE_DAMAGE_CODE,
        t0.unclassifyable_code as AUG_CLAIM_MOTOR_DETAIL__UNCLASSIFIED_DAMAGE_CODE,
        t0.under_code as AUG_CLAIM_MOTOR_DETAIL__UNDERSIDE_DAMAGE_CODE,
        null, null,
        t0.w_flood as AUG_CLAIM_MOTOR_DETAIL__WATER_FLOOD_DAMAGE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_clm_cdc_dtls') }} t0
    where (nullif(nullif(trim(t0.claim_ref), ''), '')) is not null

    union all

    -- branch 7: BJAZ_MOT_CLM_COMPARABLE_DTLS
    select
        null,
        nullif(nullif(trim(t0.claim_ref), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.comparable_claim_ref as AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE_CK,
        t0.comparable_claim_ref as AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE,
        t0.source as AUG_CLAIM_COMPARABLE_CLAIM__COMPARISON_SOURCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_clm_comparable_dtls') }} t0
    where (nullif(nullif(trim(t0.claim_ref), ''), '')) is not null

    union all

    -- branch 8: BJAZ_MOT_CLM_IP_DMG_EXTN
    select
        nullif(nullif(trim(to_char(t0.sf_no)), ''), '') as ASSESSMENT_BK,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null,
        1 as __LNK_CLAIM_ASSESSMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_id as AUG_CLAIM_MOTOR_DETAIL__INSURED_VEHICLE_INTERNAL_REFERENCE,
        t0.vehicle_version as AUG_CLAIM_MOTOR_DETAIL__INSURED_VEHICLE_INTERNAL_VERSION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.ip_no as AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK,
        t0.damaged_object as AUG_CLAIM_THIRD_PARTY_LINE__DAMAGED_OBJECT,
        t0.object_desc as AUG_CLAIM_THIRD_PARTY_LINE__DAMAGED_OBJECT_DESCRIPTION,
        t0.damage_desc as AUG_CLAIM_THIRD_PARTY_LINE__DAMAGE_DESCRIPTION,
        t0.kind_of_damage as AUG_CLAIM_THIRD_PARTY_LINE__DAMAGE_KIND,
        t0.physical_infirmity as AUG_CLAIM_THIRD_PARTY_LINE__DISABILITY_TYPE,
        t0.ip_no as AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE,
        t0.injury_details as AUG_CLAIM_THIRD_PARTY_LINE__INJURY_DETAILS,
        t0.type_of_injury as AUG_CLAIM_THIRD_PARTY_LINE__INJURY_TYPE,
        t0.period_of_disablement as AUG_CLAIM_THIRD_PARTY_LINE__PERIOD_OF_DISABLEMENT,
        null, null, null, null, null, null,
        t0.address as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_ADDRESS_TEXT,
        t0.age as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_AGE,
        t0.income as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_DECLARED_INCOME,
        t0.sex as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_GENDER_CODE,
        t0.injured_name as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_NAME,
        t0.occupation as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_OCCUPATION,
        t0.ceased_date as AUG_CLAIM_THIRD_PARTY_LINE__WORK_CEASED_DATE,
        t0.resumed_date as AUG_CLAIM_THIRD_PARTY_LINE__WORK_RESUMED_DATE,
        t0.negligence_details as AUG_CLAIM_THIRD_PARTY_MACT__NEGLIGENCE_DETAILS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_clm_ip_dmg_extn') }} t0
    where (coalesce(nullif(nullif(trim(to_char(t0.claim_id)), ''), ''), nullif(nullif(trim(to_char(t0.sf_no)), ''), ''))) is not null

    union all

    -- branch 9: BJAZ_WB_CLM_BASE_MOT_EXT | child-key literal(s): AUG_CLAIM_DOC_CHECKLIST.Document Type=IDENTY_PROFF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IDENTY_PROFF' as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
        null,
        t0.identy_proff as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_SUBMITTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 10: BJAZ_WB_CLM_BASE_MOT_EXT | child-key literal(s): AUG_CLAIM_DOC_CHECKLIST.Document Type=DOC_IDENTY_PROOF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DOC_IDENTY_PROOF' as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
        null, null,
        t0.doc_identy_proof as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 11: BJAZ_WB_CLM_BASE_MOT_EXT | child-key literal(s): AUG_CLAIM_DOC_CHECKLIST.Document Type=DOC_NO_IDENTY_PROOF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DOC_NO_IDENTY_PROOF' as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.doc_no_identy_proof as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 12: BJAZ_WB_CLM_BASE_MOT_EXT | child-key literal(s): AUG_CLAIM_DOC_CHECKLIST.Document Type=ADDRESS_PROOF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ADDRESS_PROOF' as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
        null,
        t0.address_proof as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_SUBMITTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 13: BJAZ_WB_CLM_BASE_MOT_EXT | child-key literal(s): AUG_CLAIM_DOC_CHECKLIST.Document Type=DOC_ADDRESS_PROOF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DOC_ADDRESS_PROOF' as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
        null, null,
        t0.doc_address_proof as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 14: BJAZ_WB_CLM_BASE_MOT_EXT | child-key literal(s): AUG_CLAIM_DOC_CHECKLIST.Document Type=DOC_NO_ADDRESS_PROOF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DOC_NO_ADDRESS_PROOF' as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.doc_no_address_proof as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 15: BJAZ_WB_CLM_BASE_MOT_EXT | child-key literal(s): AUG_CLAIM_DOC_CHECKLIST.Document Type=INCOME_PROFF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INCOME_PROFF' as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
        null,
        t0.income_proff as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_SUBMITTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 16: BJAZ_WB_CLM_BASE_MOT_EXT | child-key literal(s): AUG_CLAIM_DOC_CHECKLIST.Document Type=DOC_INCOME_PROOF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DOC_INCOME_PROOF' as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
        null, null,
        t0.doc_income_proof as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 17: BJAZ_WB_CLM_BASE_MOT_EXT | child-key literal(s): AUG_CLAIM_DOC_CHECKLIST.Document Type=DOC_NO_INCOME_PROOF
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DOC_NO_INCOME_PROOF' as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
        t0.doc_no_income_proof as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 18: BJAZ_WB_CLM_BASE_MOT_EXT
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        nullif(nullif('LOSS:' || nullif(trim(to_char(t0.claim_id)), ''), 'LOSS:'), '') as LOSS_EVENT_BK,
        null, null, null,
        1 as __LNK_CLAIM_LOSS_EVENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.clm_observation as AUG_CLAIM_HEADER__CLAIM_OBSERVATION_TEXT,
        null,
        t0.clm_frm_digital as AUG_CLAIM_HEADER__DIGITAL_REGISTRATION_INDICATOR,
        null, null, null,
        t0.doc_check_by as AUG_CLAIM_HEADER__DOCUMENT_VERIFIED_BY_REFERENCE,
        t0.doc_check_date as AUG_CLAIM_HEADER__DOCUMENT_VERIFIED_DATE,
        t0.fasttrack_flag_chnage_by as AUG_CLAIM_HEADER__FAST_TRACK_FLAG_CHANGED_BY_REFERENCE,
        t0.fast_track_flag_updated_on as AUG_CLAIM_HEADER__FAST_TRACK_FLAG_CHANGED_DATE,
        t0.date_of_flag as AUG_CLAIM_HEADER__FLAG_SET_DATE,
        t0.fplm_flag as AUG_CLAIM_HEADER__FPLM_INDICATOR,
        t0.fplm_reason as AUG_CLAIM_HEADER__FPLM_REASON,
        null,
        t0.liability_sms as AUG_CLAIM_HEADER__LIABILITY_SMS_SENT_INDICATOR,
        null,
        t0.ncb_endorse_no as AUG_CLAIM_HEADER__NCB_ENDORSEMENT_NUMBER,
        null,
        t0.other_reason as AUG_CLAIM_HEADER__OTHER_REASON_TEXT,
        t0.clm_nth_year as AUG_CLAIM_HEADER__POLICY_YEAR_OF_CLAIM,
        t0.processor_remarks as AUG_CLAIM_HEADER__PROCESSOR_REMARKS,
        t0.user_type as AUG_CLAIM_HEADER__REGISTERING_USER_TYPE,
        t0.endt_approved_flag as AUG_CLAIM_HEADER__RELATED_ENDORSEMENT_APPROVED_INDICATOR,
        t0.endt_version_approved as AUG_CLAIM_HEADER__RELATED_ENDORSEMENT_VERSION,
        t0.supp_id as AUG_CLAIM_HEADER__SUPPLEMENTARY_CLAIM_REFERENCE,
        t0.reason as AUG_CLAIM_HEADER__UNQUALIFIED_REASON_TEXT,
        null, null, null, null, null, null, null, null, null,
        t0.driver_name_verified_y_n as AUG_CLAIM_MOTOR_DETAIL__DRIVER_NAME_VERIFIED_INDICATOR,
        null, null,
        t0.fault_by as AUG_CLAIM_MOTOR_DETAIL__FAULT_ATTRIBUTED_TO_ROLE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.odo_reason as AUG_CLAIM_MOTOR_DETAIL__ODOMETER_DISCREPANCY_REASON,
        t0.odo_reading as AUG_CLAIM_MOTOR_DETAIL__ODOMETER_READING_AT_LOSS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vech_insp_flag as AUG_CLAIM_MOTOR_DETAIL__VEHICLE_INSPECTION_CARRIED_OUT_INDICATOR,
        null, null, null,
        t0.follow_up_required as AUG_CLAIM_SLA_TRACKING__FOLLOW_UP_REQUIRED_INDICATOR,
        null,
        t0.req_fulfilled_date as AUG_CLAIM_SLA_TRACKING__REQUIREMENT_FULFILLED_DATE,
        t0.req_fulfilled_cust as AUG_CLAIM_SLA_TRACKING__REQUIREMENT_FULFILLED_INDICATOR,
        t0.action as AUG_CLAIM_SLA_TRACKING__WORKFLOW_ACTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.relation as CLAIM_FNOL__RELATIONSHIP_TO_INSURED,
        t0.tel_no as CLAIM_FNOL__REPORTED_BY_CONTACT,
        t0.caller_name as CLAIM_FNOL__REPORTED_BY_NAME,
        t0.action_update_date as CLAIM_SLA_TRACKING__LAST_ACTION_DATE,
        t0.pending_with as CLAIM_SLA_TRACKING__PENDING_WITH_ROLE,
        null,
        t0.est_loss_amt as LOSS_EVENT_DETAIL__ESTIMATED_LOSS_AMOUNT,
        t0.fir_number as LOSS_EVENT_DETAIL__FIR_NUMBER,
        null,
        t0.loss_desc as LOSS_EVENT_DETAIL__LOSS_DESCRIPTION,
        t0.loss_type as LOSS_EVENT_DETAIL__LOSS_EVENT_TYPE,
        t0.time_of_loss as LOSS_EVENT_DETAIL__LOSS_TIME,
        t0.event_code as LOSS_EVENT_DETAIL__PERIL_CODE,
        t0.police_station_name as LOSS_EVENT_DETAIL__POLICE_STATION_NAME,
        null,
        t0.tp_involvment as LOSS_EVENT_DETAIL__THIRD_PARTY_INVOLVED_INDICATOR,
        t0.address_line1 as LOSS_LOCATION_ADDRESS__ADDRESS_LINE_1,
        t0.address_line2 as LOSS_LOCATION_ADDRESS__ADDRESS_LINE_2,
        t0.city as LOSS_LOCATION_ADDRESS__CITY,
        t0.landmark as LOSS_LOCATION_ADDRESS__LANDMARK,
        t0.pincode as LOSS_LOCATION_ADDRESS__POSTAL_CODE,
        t0.state as LOSS_LOCATION_ADDRESS__STATE_CODE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (coalesce(nullif(nullif('LOSS:' || nullif(trim(to_char(t0.claim_id)), ''), 'LOSS:'), ''), nullif(nullif(trim(to_char(t0.claim_id)), ''), ''))) is not null

    union all

    -- branch 19: BJAZ_WB_CLM_IP_MOT_EXT
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.own_repairer as AUG_CLAIM_MOTOR_DETAIL__OWN_REPAIRER_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.ip_no as AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK,
        null, null, null, null, null,
        t0.ip_no as AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE,
        null, null, null,
        t0.driving_licence_exp_date as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_DRIVER_LICENCE_EXPIRY_DATE,
        t0.driving_licence_no as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_DRIVER_LICENCE_NUMBER,
        t0.tp_ins_comp_branch as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_BRANCH,
        t0.tp_ins_comp_contact as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_CONTACT_NUMBER,
        t0.tp_ins_comp_name as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_NAME,
        t0.tp_policy_ref as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_POLICY_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_ip_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 20: BJAZ_WS_MOTCLM_DETAILS
    select
        nullif(nullif(trim(t0.estimation_no), ''), '') as ASSESSMENT_BK,
        nullif(nullif(trim(to_char(t0.clm_ref_id)), ''), '') as CLAIM_BK,
        nullif(md5(normalise(upper(nullif('LOSSEVENT:' || coalesce(to_char(t0.clm_ref_id), ''), 'LOSSEVENT:')))), '') as LOSS_EVENT_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(nullif(trim(t0.veh_reg_no), ''), '') as RISK_OBJECT_BK,
        1 as __LNK_CLAIM_ASSESSMENT,
        1 as __LNK_CLAIM_LOSS_EVENT,
        1 as __LNK_CLAIM_POLICY,
        1 as __LNK_CLAIM_RISK_OBJECT,
        1 as __LNK_LOSS_EVENT_RISK_OBJECT,
        1 as __LNK_POLICY_RISK_OBJECT,
        1 as __LNK_RISK_OBJECT_ASSESSMENT,
        t0.estimate_version as AUG_ASSESSMENT_HEADER__ASSESSMENT_VERSION_NUMBER,
        t0.mi_trans_id as AUG_ASSESSMENT_HEADER__INSPECTION_TRANSACTION_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.total_den_est_mat as AUG_CLAIM_MOTOR_DETAIL__DENTING_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.metal_parts_est_amt as AUG_CLAIM_MOTOR_DETAIL__METAL_PARTS_AMOUNT,
        null, null,
        t0.odo_reading as AUG_CLAIM_MOTOR_DETAIL__ODOMETER_READING_AT_LOSS,
        null, null,
        t0.plastic_parts_est_amt as AUG_CLAIM_MOTOR_DETAIL__PLASTIC_PARTS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.intimation_date as CLAIM_FNOL__FNOL_DATE,
        null, null, null, null, null, null, null, null,
        t0.acc_cause as LOSS_EVENT_DETAIL__CAUSE_OF_LOSS,
        null, null,
        t0.date_of_loss as LOSS_EVENT_DETAIL__LOSS_DATE,
        null,
        t0.loss_type as LOSS_EVENT_DETAIL__LOSS_EVENT_TYPE,
        t0.acc_time as LOSS_EVENT_DETAIL__LOSS_TIME,
        t0.peril as LOSS_EVENT_DETAIL__PERIL_CODE,
        null,
        t0.sub_peril as LOSS_EVENT_DETAIL__SUB_PERIL_CODE,
        null, null, null,
        t0.acc_city_code as LOSS_LOCATION_ADDRESS__CITY,
        null,
        t0.pin_code as LOSS_LOCATION_ADDRESS__POSTAL_CODE,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_ws_motclm_details') }} t0
    where (coalesce(nullif(md5(normalise(upper(nullif('LOSSEVENT:' || coalesce(to_char(t0.clm_ref_id), ''), 'LOSSEVENT:')))), ''), nullif(nullif(trim(t0.estimation_no), ''), ''), nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(t0.veh_reg_no), ''), ''), nullif(nullif(trim(to_char(t0.clm_ref_id)), ''), ''))) is not null

    union all

    -- branch 21: BJAZ_WS_MOTCLM_SURVEY_DTLS
    select
        null,
        nullif(nullif(trim(t0.clm_ref), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.voluntary_excess_amt as AUG_CLAIM_ASSESSMENT_SUMMARY__VOLUNTARY_EXCESS_DEDUCTED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.metal_parts_asd_amt as AUG_CLAIM_MOTOR_DETAIL__METAL_PARTS_AMOUNT,
        t0.miscellaneous_asd_amt as AUG_CLAIM_MOTOR_DETAIL__MISCELLANEOUS_ASSESSED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.total_asd_amt as CLAIM_ASSESSMENT_SUMMARY__ASSESSED_LOSS_AMOUNT,
        t0.compulsry_excess_amt as CLAIM_ASSESSMENT_SUMMARY__EXCESS_DEDUCTED,
        t0.salvage_amt as CLAIM_ASSESSMENT_SUMMARY__SALVAGE_AMOUNT,
        t0.insured_liablity_amt as CLAIM_ASSESSMENT_SUMMARY__TOTAL_DEDUCTION_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_ws_motclm_survey_dtls') }} t0
    where (nullif(nullif(trim(t0.clm_ref), ''), '')) is not null

)

select
    ASSESSMENT_BK,
    CLAIM_BK,
    LOSS_EVENT_BK,
    POLICY_BK,
    RISK_OBJECT_BK,
    __LNK_CLAIM_ASSESSMENT,
    __LNK_CLAIM_LOSS_EVENT,
    __LNK_CLAIM_POLICY,
    __LNK_CLAIM_RISK_OBJECT,
    __LNK_LOSS_EVENT_RISK_OBJECT,
    __LNK_POLICY_RISK_OBJECT,
    __LNK_RISK_OBJECT_ASSESSMENT,
    first_value(AUG_ASSESSMENT_HEADER__ASSESSMENT_VERSION_NUMBER) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__ASSESSMENT_VERSION_NUMBER,
    first_value(AUG_ASSESSMENT_HEADER__INSPECTION_TRANSACTION_REFERENCE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__INSPECTION_TRANSACTION_REFERENCE,
    first_value(AUG_CLAIM_ASSESSMENT_SUMMARY__VOLUNTARY_EXCESS_DEDUCTED) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_ASSESSMENT_SUMMARY__VOLUNTARY_EXCESS_DEDUCTED,
    AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE_CK,
    first_value(AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE,
    first_value(AUG_CLAIM_COMPARABLE_CLAIM__COMPARISON_SOURCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COMPARABLE_CLAIM__COMPARISON_SOURCE,
    AUG_CLAIM_DOC_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
    AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK,
    first_value(AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_NUMBER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_DOC_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK, AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_NUMBER,
    first_value(AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_SUBMITTED_INDICATOR) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_DOC_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK, AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_SUBMITTED_INDICATOR,
    first_value(AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_DOC_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK, AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE,
    first_value(AUG_CLAIM_FNOL__ALTERNATE_REPORTED_BY_CONTACT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FNOL__ALTERNATE_REPORTED_BY_CONTACT,
    first_value(AUG_CLAIM_FNOL__REASON_FOR_NO_CONTACT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FNOL__REASON_FOR_NO_CONTACT,
    first_value(AUG_CLAIM_FNOL__REPORTED_BY_EMAIL_ADDRESS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FNOL__REPORTED_BY_EMAIL_ADDRESS,
    first_value(AUG_CLAIM_FNOL__WEB_SUBMISSION_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FNOL__WEB_SUBMISSION_INDICATOR,
    first_value(AUG_CLAIM_HEADER__CLAIM_OBSERVATION_TEXT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__CLAIM_OBSERVATION_TEXT,
    first_value(AUG_CLAIM_HEADER__CONTACT_PERSON_NAME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__CONTACT_PERSON_NAME,
    first_value(AUG_CLAIM_HEADER__DIGITAL_REGISTRATION_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__DIGITAL_REGISTRATION_INDICATOR,
    first_value(AUG_CLAIM_HEADER__DOCUMENT_CHECK_BY_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__DOCUMENT_CHECK_BY_REFERENCE,
    first_value(AUG_CLAIM_HEADER__DOCUMENT_CHECK_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__DOCUMENT_CHECK_DATE,
    first_value(AUG_CLAIM_HEADER__DOCUMENT_RECEIVED_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__DOCUMENT_RECEIVED_DATE,
    first_value(AUG_CLAIM_HEADER__DOCUMENT_VERIFIED_BY_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__DOCUMENT_VERIFIED_BY_REFERENCE,
    first_value(AUG_CLAIM_HEADER__DOCUMENT_VERIFIED_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__DOCUMENT_VERIFIED_DATE,
    first_value(AUG_CLAIM_HEADER__FAST_TRACK_FLAG_CHANGED_BY_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__FAST_TRACK_FLAG_CHANGED_BY_REFERENCE,
    first_value(AUG_CLAIM_HEADER__FAST_TRACK_FLAG_CHANGED_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__FAST_TRACK_FLAG_CHANGED_DATE,
    first_value(AUG_CLAIM_HEADER__FLAG_SET_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__FLAG_SET_DATE,
    first_value(AUG_CLAIM_HEADER__FPLM_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__FPLM_INDICATOR,
    first_value(AUG_CLAIM_HEADER__FPLM_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__FPLM_REASON,
    first_value(AUG_CLAIM_HEADER__HOUSEHOLD_IDENTIFIER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__HOUSEHOLD_IDENTIFIER,
    first_value(AUG_CLAIM_HEADER__LIABILITY_SMS_SENT_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__LIABILITY_SMS_SENT_INDICATOR,
    first_value(AUG_CLAIM_HEADER__LOSS_EVENT_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__LOSS_EVENT_CODE,
    first_value(AUG_CLAIM_HEADER__NCB_ENDORSEMENT_NUMBER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__NCB_ENDORSEMENT_NUMBER,
    first_value(AUG_CLAIM_HEADER__OTHER_INTIMATION_CHANNEL_DESCRIPTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__OTHER_INTIMATION_CHANNEL_DESCRIPTION,
    first_value(AUG_CLAIM_HEADER__OTHER_REASON_TEXT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__OTHER_REASON_TEXT,
    first_value(AUG_CLAIM_HEADER__POLICY_YEAR_OF_CLAIM) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__POLICY_YEAR_OF_CLAIM,
    first_value(AUG_CLAIM_HEADER__PROCESSOR_REMARKS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__PROCESSOR_REMARKS,
    first_value(AUG_CLAIM_HEADER__REGISTERING_USER_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__REGISTERING_USER_TYPE,
    first_value(AUG_CLAIM_HEADER__RELATED_ENDORSEMENT_APPROVED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__RELATED_ENDORSEMENT_APPROVED_INDICATOR,
    first_value(AUG_CLAIM_HEADER__RELATED_ENDORSEMENT_VERSION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__RELATED_ENDORSEMENT_VERSION,
    first_value(AUG_CLAIM_HEADER__SUPPLEMENTARY_CLAIM_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__SUPPLEMENTARY_CLAIM_REFERENCE,
    first_value(AUG_CLAIM_HEADER__UNQUALIFIED_REASON_TEXT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__UNQUALIFIED_REASON_TEXT,
    first_value(AUG_CLAIM_MOTOR_DETAIL__CHASSIS_DAMAGE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__CHASSIS_DAMAGE_INDICATOR,
    first_value(AUG_CLAIM_MOTOR_DETAIL__DAMAGED_TYRE_COUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__DAMAGED_TYRE_COUNT,
    first_value(AUG_CLAIM_MOTOR_DETAIL__DAMAGE_CAPTURE_DEVICE_SOURCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__DAMAGE_CAPTURE_DEVICE_SOURCE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__DENTING_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__DENTING_AMOUNT,
    first_value(AUG_CLAIM_MOTOR_DETAIL__DEVICE_MAKE_AND_MODEL) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__DEVICE_MAKE_AND_MODEL,
    first_value(AUG_CLAIM_MOTOR_DETAIL__DEVICE_SERIAL_NUMBER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__DEVICE_SERIAL_NUMBER,
    first_value(AUG_CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_EXPIRY_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_EXPIRY_DATE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_ISSUE_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_ISSUE_DATE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_TYPE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__DRIVER_NAME_VERIFIED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__DRIVER_NAME_VERIFIED_INDICATOR,
    first_value(AUG_CLAIM_MOTOR_DETAIL__DRIVER_RELATIONSHIP_TO_INSURED) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__DRIVER_RELATIONSHIP_TO_INSURED,
    first_value(AUG_CLAIM_MOTOR_DETAIL__FAULT_ATTRIBUTED_TO_PARTY) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__FAULT_ATTRIBUTED_TO_PARTY,
    first_value(AUG_CLAIM_MOTOR_DETAIL__FAULT_ATTRIBUTED_TO_ROLE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__FAULT_ATTRIBUTED_TO_ROLE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__FIRE_DAMAGE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__FIRE_DAMAGE_INDICATOR,
    first_value(AUG_CLAIM_MOTOR_DETAIL__FRONT_DAMAGE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__FRONT_DAMAGE_CODE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__FUEL_TANK_DAMAGE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__FUEL_TANK_DAMAGE_INDICATOR,
    first_value(AUG_CLAIM_MOTOR_DETAIL__GOODS_TYPE_CARRIED) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__GOODS_TYPE_CARRIED,
    first_value(AUG_CLAIM_MOTOR_DETAIL__INSPECTION_LOCATION_TEXT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__INSPECTION_LOCATION_TEXT,
    first_value(AUG_CLAIM_MOTOR_DETAIL__INSURED_VEHICLE_INTERNAL_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__INSURED_VEHICLE_INTERNAL_REFERENCE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__INSURED_VEHICLE_INTERNAL_VERSION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__INSURED_VEHICLE_INTERNAL_VERSION,
    first_value(AUG_CLAIM_MOTOR_DETAIL__JOURNEY_DESTINATION_CITY) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__JOURNEY_DESTINATION_CITY,
    first_value(AUG_CLAIM_MOTOR_DETAIL__JOURNEY_ORIGIN_CITY) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__JOURNEY_ORIGIN_CITY,
    first_value(AUG_CLAIM_MOTOR_DETAIL__KILOMETRE_LIMIT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__KILOMETRE_LIMIT,
    first_value(AUG_CLAIM_MOTOR_DETAIL__LEFT_SIDE_DAMAGE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__LEFT_SIDE_DAMAGE_CODE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__METAL_PARTS_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__METAL_PARTS_AMOUNT,
    first_value(AUG_CLAIM_MOTOR_DETAIL__MISCELLANEOUS_ASSESSED_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__MISCELLANEOUS_ASSESSED_AMOUNT,
    first_value(AUG_CLAIM_MOTOR_DETAIL__ODOMETER_DISCREPANCY_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__ODOMETER_DISCREPANCY_REASON,
    first_value(AUG_CLAIM_MOTOR_DETAIL__ODOMETER_READING_AT_LOSS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__ODOMETER_READING_AT_LOSS,
    first_value(AUG_CLAIM_MOTOR_DETAIL__OWN_REPAIRER_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__OWN_REPAIRER_INDICATOR,
    first_value(AUG_CLAIM_MOTOR_DETAIL__PARTIAL_THEFT_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__PARTIAL_THEFT_INDICATOR,
    first_value(AUG_CLAIM_MOTOR_DETAIL__PLASTIC_PARTS_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__PLASTIC_PARTS_AMOUNT,
    first_value(AUG_CLAIM_MOTOR_DETAIL__REAR_DAMAGE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__REAR_DAMAGE_CODE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__REAR_GLASS_DAMAGE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__REAR_GLASS_DAMAGE_CODE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__REPAIR_INVOICE_NUMBER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__REPAIR_INVOICE_NUMBER,
    first_value(AUG_CLAIM_MOTOR_DETAIL__RIGHT_SIDE_DAMAGE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__RIGHT_SIDE_DAMAGE_CODE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__RIM_WITH_TYRE_DAMAGE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__RIM_WITH_TYRE_DAMAGE_INDICATOR,
    first_value(AUG_CLAIM_MOTOR_DETAIL__ROLL_OVER_DAMAGE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__ROLL_OVER_DAMAGE_CODE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__ROOF_DAMAGE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__ROOF_DAMAGE_CODE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__SILENCER_DAMAGE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__SILENCER_DAMAGE_INDICATOR,
    first_value(AUG_CLAIM_MOTOR_DETAIL__SPOT_SURVEY_UPDATE_TEXT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__SPOT_SURVEY_UPDATE_TEXT,
    first_value(AUG_CLAIM_MOTOR_DETAIL__SURVEYOR_UPDATE_TEXT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__SURVEYOR_UPDATE_TEXT,
    first_value(AUG_CLAIM_MOTOR_DETAIL__TRAFFIC_CHALLAN_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__TRAFFIC_CHALLAN_DATE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__TRAFFIC_CHALLAN_DETAILS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__TRAFFIC_CHALLAN_DETAILS,
    first_value(AUG_CLAIM_MOTOR_DETAIL__TYRE_DAMAGE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__TYRE_DAMAGE_CODE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__UNCLASSIFIED_DAMAGE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__UNCLASSIFIED_DAMAGE_CODE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__UNDERSIDE_DAMAGE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__UNDERSIDE_DAMAGE_CODE,
    first_value(AUG_CLAIM_MOTOR_DETAIL__VEHICLE_INSPECTION_CARRIED_OUT_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__VEHICLE_INSPECTION_CARRIED_OUT_INDICATOR,
    first_value(AUG_CLAIM_MOTOR_DETAIL__VEHICLE_LYING_LOCATION_TEXT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__VEHICLE_LYING_LOCATION_TEXT,
    first_value(AUG_CLAIM_MOTOR_DETAIL__WATER_FLOOD_DAMAGE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__WATER_FLOOD_DAMAGE_INDICATOR,
    first_value(AUG_CLAIM_MOTOR_DETAIL__WEIGHT_CARRIED_AT_LOSS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_MOTOR_DETAIL__WEIGHT_CARRIED_AT_LOSS,
    first_value(AUG_CLAIM_SLA_TRACKING__FOLLOW_UP_REQUIRED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SLA_TRACKING__FOLLOW_UP_REQUIRED_INDICATOR,
    first_value(AUG_CLAIM_SLA_TRACKING__PROCESSING_DELAY_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SLA_TRACKING__PROCESSING_DELAY_REASON,
    first_value(AUG_CLAIM_SLA_TRACKING__REQUIREMENT_FULFILLED_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SLA_TRACKING__REQUIREMENT_FULFILLED_DATE,
    first_value(AUG_CLAIM_SLA_TRACKING__REQUIREMENT_FULFILLED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SLA_TRACKING__REQUIREMENT_FULFILLED_INDICATOR,
    first_value(AUG_CLAIM_SLA_TRACKING__WORKFLOW_ACTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SLA_TRACKING__WORKFLOW_ACTION,
    AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__DAMAGED_OBJECT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__DAMAGED_OBJECT,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__DAMAGED_OBJECT_DESCRIPTION) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__DAMAGED_OBJECT_DESCRIPTION,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__DAMAGE_DESCRIPTION) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__DAMAGE_DESCRIPTION,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__DAMAGE_KIND) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__DAMAGE_KIND,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__DISABILITY_TYPE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__DISABILITY_TYPE,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__INJURY_DETAILS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__INJURY_DETAILS,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__INJURY_TYPE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__INJURY_TYPE,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__PERIOD_OF_DISABLEMENT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__PERIOD_OF_DISABLEMENT,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_DRIVER_LICENCE_EXPIRY_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_DRIVER_LICENCE_EXPIRY_DATE,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_DRIVER_LICENCE_NUMBER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_DRIVER_LICENCE_NUMBER,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_BRANCH) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_BRANCH,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_CONTACT_NUMBER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_CONTACT_NUMBER,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_NAME) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_NAME,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_POLICY_NUMBER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_POLICY_NUMBER,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_ADDRESS_TEXT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_ADDRESS_TEXT,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_AGE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_AGE,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_DECLARED_INCOME) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_DECLARED_INCOME,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_GENDER_CODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_GENDER_CODE,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_NAME) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_NAME,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_OCCUPATION) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_OCCUPATION,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__WORK_CEASED_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__WORK_CEASED_DATE,
    first_value(AUG_CLAIM_THIRD_PARTY_LINE__WORK_RESUMED_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_LINE__WORK_RESUMED_DATE,
    first_value(AUG_CLAIM_THIRD_PARTY_MACT__NEGLIGENCE_DETAILS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_MACT__NEGLIGENCE_DETAILS,
    first_value(CLAIM_ASSESSMENT_SUMMARY__ASSESSED_LOSS_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_ASSESSMENT_SUMMARY__ASSESSED_LOSS_AMOUNT,
    first_value(CLAIM_ASSESSMENT_SUMMARY__EXCESS_DEDUCTED) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_ASSESSMENT_SUMMARY__EXCESS_DEDUCTED,
    first_value(CLAIM_ASSESSMENT_SUMMARY__SALVAGE_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_ASSESSMENT_SUMMARY__SALVAGE_AMOUNT,
    first_value(CLAIM_ASSESSMENT_SUMMARY__TOTAL_DEDUCTION_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_ASSESSMENT_SUMMARY__TOTAL_DEDUCTION_AMOUNT,
    first_value(CLAIM_FNOL__FNOL_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FNOL__FNOL_DATE,
    first_value(CLAIM_FNOL__LOCATION_OF_LOSS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FNOL__LOCATION_OF_LOSS,
    first_value(CLAIM_FNOL__PRELIMINARY_LOSS_DESCRIPTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FNOL__PRELIMINARY_LOSS_DESCRIPTION,
    first_value(CLAIM_FNOL__PRELIMINARY_LOSS_ESTIMATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FNOL__PRELIMINARY_LOSS_ESTIMATE,
    first_value(CLAIM_FNOL__RELATIONSHIP_TO_INSURED) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FNOL__RELATIONSHIP_TO_INSURED,
    first_value(CLAIM_FNOL__REPORTED_BY_CONTACT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FNOL__REPORTED_BY_CONTACT,
    first_value(CLAIM_FNOL__REPORTED_BY_NAME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FNOL__REPORTED_BY_NAME,
    first_value(CLAIM_SLA_TRACKING__LAST_ACTION_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SLA_TRACKING__LAST_ACTION_DATE,
    first_value(CLAIM_SLA_TRACKING__PENDING_WITH_ROLE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SLA_TRACKING__PENDING_WITH_ROLE,
    first_value(LOSS_EVENT_DETAIL__CAUSE_OF_LOSS) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__CAUSE_OF_LOSS,
    first_value(LOSS_EVENT_DETAIL__ESTIMATED_LOSS_AMOUNT) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__ESTIMATED_LOSS_AMOUNT,
    first_value(LOSS_EVENT_DETAIL__FIR_NUMBER) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__FIR_NUMBER,
    first_value(LOSS_EVENT_DETAIL__LOSS_DATE) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__LOSS_DATE,
    first_value(LOSS_EVENT_DETAIL__LOSS_DESCRIPTION) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__LOSS_DESCRIPTION,
    first_value(LOSS_EVENT_DETAIL__LOSS_EVENT_TYPE) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__LOSS_EVENT_TYPE,
    first_value(LOSS_EVENT_DETAIL__LOSS_TIME) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__LOSS_TIME,
    first_value(LOSS_EVENT_DETAIL__PERIL_CODE) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__PERIL_CODE,
    first_value(LOSS_EVENT_DETAIL__POLICE_STATION_NAME) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__POLICE_STATION_NAME,
    first_value(LOSS_EVENT_DETAIL__SUB_PERIL_CODE) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__SUB_PERIL_CODE,
    first_value(LOSS_EVENT_DETAIL__THIRD_PARTY_INVOLVED_INDICATOR) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__THIRD_PARTY_INVOLVED_INDICATOR,
    first_value(LOSS_LOCATION_ADDRESS__ADDRESS_LINE_1) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_LOCATION_ADDRESS__ADDRESS_LINE_1,
    first_value(LOSS_LOCATION_ADDRESS__ADDRESS_LINE_2) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_LOCATION_ADDRESS__ADDRESS_LINE_2,
    first_value(LOSS_LOCATION_ADDRESS__CITY) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_LOCATION_ADDRESS__CITY,
    first_value(LOSS_LOCATION_ADDRESS__LANDMARK) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_LOCATION_ADDRESS__LANDMARK,
    first_value(LOSS_LOCATION_ADDRESS__POSTAL_CODE) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_LOCATION_ADDRESS__POSTAL_CODE,
    first_value(LOSS_LOCATION_ADDRESS__STATE_CODE) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_LOCATION_ADDRESS__STATE_CODE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- SAT_AUG_CLAIM_COMPARABLE_CLAIM (ma_sat): one load time per CLAIM_BK, so all its child rows share it
    max(case when coalesce(m.AUG_CLAIM_COMPARABLE_CLAIM__COMPARABLE_CLAIM_REFERENCE, m.AUG_CLAIM_COMPARABLE_CLAIM__COMPARISON_SOURCE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.CLAIM_BK) as AUG_CLAIM_COMPARABLE_CLAIM__LOAD_DATETIME,
    -- SAT_AUG_CLAIM_DOC_CHECKLIST (ma_sat): one load time per CLAIM_BK, so all its child rows share it
    max(case when coalesce(m.AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_NUMBER, m.AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_SUBMITTED_INDICATOR, m.AUG_CLAIM_DOC_CHECKLIST__DOCUMENT_TYPE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.CLAIM_BK) as AUG_CLAIM_DOC_CHECKLIST__LOAD_DATETIME,
    -- SAT_AUG_CLAIM_THIRD_PARTY_LINE (ma_sat): one load time per CLAIM_BK, so all its child rows share it
    max(case when coalesce(m.AUG_CLAIM_THIRD_PARTY_LINE__DAMAGED_OBJECT, m.AUG_CLAIM_THIRD_PARTY_LINE__DAMAGED_OBJECT_DESCRIPTION, m.AUG_CLAIM_THIRD_PARTY_LINE__DAMAGE_DESCRIPTION, m.AUG_CLAIM_THIRD_PARTY_LINE__DAMAGE_KIND, m.AUG_CLAIM_THIRD_PARTY_LINE__DISABILITY_TYPE, m.AUG_CLAIM_THIRD_PARTY_LINE__INJURED_PARTY_SEQUENCE, m.AUG_CLAIM_THIRD_PARTY_LINE__INJURY_DETAILS, m.AUG_CLAIM_THIRD_PARTY_LINE__INJURY_TYPE, m.AUG_CLAIM_THIRD_PARTY_LINE__PERIOD_OF_DISABLEMENT, m.AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_DRIVER_LICENCE_EXPIRY_DATE, m.AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_DRIVER_LICENCE_NUMBER, m.AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_BRANCH, m.AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_CONTACT_NUMBER, m.AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_NAME, m.AUG_CLAIM_THIRD_PARTY_LINE__THIRD_PARTY_INSURER_POLICY_NUMBER, m.AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_ADDRESS_TEXT, m.AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_AGE, m.AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_DECLARED_INCOME, m.AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_GENDER_CODE, m.AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_NAME, m.AUG_CLAIM_THIRD_PARTY_LINE__VICTIM_OCCUPATION, m.AUG_CLAIM_THIRD_PARTY_LINE__WORK_CEASED_DATE, m.AUG_CLAIM_THIRD_PARTY_LINE__WORK_RESUMED_DATE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.CLAIM_BK) as AUG_CLAIM_THIRD_PARTY_LINE__LOAD_DATETIME
from merged m
