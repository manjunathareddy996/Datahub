-- CENTRAL VIEW v04_claim -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_EVENT_FOLLOWUP
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_HISTORY
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_NOTES
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_CLAIM_COMMUNICATION
--   SAT_MOTOR_AUG_CLAIM_EVIDENCE
--   SAT_MOTOR_AUG_CLAIM_FOLLOW_UP_CHASE
--   SAT_MOTOR_AUG_CLAIM_NOTE
--   SAT_MOTOR_AUG_CLAIM_STATUS_TRANSITION
--   SAT_MOTOR_AUG_CLAIM_SURVEY_APPOINTMENT
--   SAT_MOTOR_AUG_LNK_CLAIM_PARTY_ROLE
--   SAT_MOTOR_AUG_PARTY_POLICY_HISTORY
--   SAT_MOTOR_AUG_PARTY_PORTFOLIO_SUMMARY
--   SAT_MOTOR_AUG_POLICY_BONUS_TRACKING
--   SAT_MOTOR_AUG_POLICY_UNDERWRITING_QUERY
--   SAT_MOTOR_AUG_QUOTE_PA_NAMED_PERSON
--   SAT_MOTOR_AUG_QUOTE_UNDERWRITING_QUERY
--   SAT_CLAIM_BENEFIT_HEAD
--   SAT_CLAIM_LITIGATION
--   SAT_CLAIM_NOTE
--   SAT_CLAIM_RECOVERY_SALVAGE
--   SAT_CLAIM_SURVEY_APPOINTMENT
--   SAT_PARTY_CLAIM_HISTORY
--   SAT_PARTY_POLICY_HISTORY
--   SAT_PARTY_PORTFOLIO_SUMMARY
--   SAT_PARTY_RELATIONSHIP_PROFILE
--   SAT_POLICY_BONUS_TRACKING
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_POLICY
--   LNK_CLAIM_RISK_OBJECT
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.claimno), ''), '') as CLAIM_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as QUOTE_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_CLAIM_PARTY,
        cast(null as number) as __LNK_CLAIM_POLICY,
        cast(null as number) as __LNK_CLAIM_RISK_OBJECT,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        nullif(trim(t0.inward_date),'') as AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK,
        nullif(trim(t0.inward_number),'') as AUG_CLAIM_COMMUNICATION__SEQUENCE_CK,
        t0.acknowledgment_received as AUG_CLAIM_COMMUNICATION__ACKNOWLEDGEMENT_RECEIVED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_COMMUNICATION__COURIER_VENDOR_NAME,
        cast(null as varchar) as AUG_CLAIM_COMMUNICATION__DISPATCH_MODE,
        t0.mode_of_inward as AUG_CLAIM_COMMUNICATION__INWARD_MODE,
        t0.inward_date as AUG_CLAIM_COMMUNICATION__INWARD_REGISTRATION_DATE,
        cast(null as varchar) as AUG_CLAIM_COMMUNICATION__OUTWARD_REGISTRATION_DATE,
        cast(null as varchar) as AUG_CLAIM_COMMUNICATION__OUTWARD_REGISTRATION_NUMBER,
        cast(null as varchar) as AUG_CLAIM_COMMUNICATION__PROOF_OF_DELIVERY_NUMBER,
        cast(null as varchar) as AUG_CLAIM_COMMUNICATION__SENDER_NAME,
        cast(null as varchar) as AUG_CLAIM_COMMUNICATION__SENT_TO_NAME,
        cast(null as varchar) as AUG_CLAIM_EVIDENCE__IMAGE_UPLOAD_STATUS,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__ASSIGNED_TO_USER_REFERENCE,
        t0.c_1st_reminder_date as AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_CREATED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_CREATED_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_DESCRIPTION_REMARKS,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_EFFECTIVE_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_EVENT_CODE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_KEYWORD,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_PRIORITY,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_STATUS,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_DATE,
        t0.c_2nd_reminder_date as AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE,
        t0.c_3rd_reminder_date as AUG_CLAIM_FOLLOW_UP_CHASE__THIRD_REMINDER_DATE,
        cast(null as varchar) as AUG_CLAIM_FOLLOW_UP_CHASE__WORKFLOW_JOB_STATUS,
        cast(null as varchar) as AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK,
        cast(null as varchar) as AUG_CLAIM_NOTE__NOTE_AUTHOR_ROLE_CK,
        cast(null as varchar) as AUG_CLAIM_NOTE__ASSIGNED_TO_USER_NAME,
        cast(null as varchar) as AUG_CLAIM_NOTE__ASSIGNED_TO_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_NOTE__NOTE_SUMMARY_TEXT,
        cast(null as varchar) as AUG_CLAIM_NOTE__NOTE_UPDATED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_NOTE__NOTE_UPDATED_DATE,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__CLAIM_STATUS_CODE,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__CLAIM_SUB_STATUS_CODE,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__DELAY_REASON,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__EVENT_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__EVENT_DETAIL_TEXT,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__EVENT_RECORD_CREATED_DATE,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__EVENT_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__EVENT_REMARKS,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__HISTORY_ENTRY_TYPE,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__PPI_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__REQUIREMENT_STATUS_AT_EVENT,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__SCRUTINY_STATUS,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__SURVEY_REPORT_STATUS,
        cast(null as varchar) as AUG_CLAIM_STATUS_TRANSITION__TRANSITION_ACTOR_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_SURVEY_APPOINTMENT__INSPECTION_ADDRESS_TEXT,
        cast(null as varchar) as AUG_CLAIM_SURVEY_APPOINTMENT__LIVE_VIDEO_SURVEY_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_SURVEY_APPOINTMENT__SURVEY_CARRIED_OUT_INDICATOR,
        cast(null as varchar) as AUG_LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        cast(null as varchar) as AUG_LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK,
        cast(null as varchar) as AUG_LNK_CLAIM_PARTY_ROLE__RELATIONSHIP_TO_INSURED,
        cast(null as varchar) as AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_ISSUING_OFFICE,
        cast(null as varchar) as AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_LINE_OF_BUSINESS,
        cast(null as varchar) as AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_PRODUCT_NAME,
        cast(null as varchar) as AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_SUB_CHANNEL,
        cast(null as varchar) as AUG_PARTY_PORTFOLIO_SUMMARY__MULTI_CHANNEL_PURCHASE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_BONUS_TRACKING__NCB_STATUS,
        cast(null as varchar) as AUG_POLICY_BONUS_TRACKING__PREVIOUS_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_BONUS_TRACKING__PREVIOUS_NCB_PERCENTAGE,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__DEFICIENCY_MAIN_REMARKS,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__DEFICIENCY_SUB_REMARKS,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__OPERATIONS_QUERY_TEXT,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_DETAIL,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_RAISED_TIMESTAMP,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_REPLY_TEXT,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_REPLY_TIMESTAMP,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_RESPONSE_TEXT,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_STATUS,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_TYPE,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__RAISED_BY_ROLE,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__RAISED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__REPLIED_BY_ROLE,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_QUERY__REPLIED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK,
        cast(null as varchar) as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_AGE,
        cast(null as varchar) as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_GENDER,
        cast(null as varchar) as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME,
        cast(null as varchar) as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_RELATIONSHIP,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__DEFICIENCY_MAIN_REMARKS,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__DEFICIENCY_SUB_REMARKS,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__OPERATIONS_QUERY_TEXT,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_DETAIL,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_RAISED_TIMESTAMP,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_REPLY_TEXT,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_REPLY_TIMESTAMP,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_RESPONSE_TEXT,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_STATUS,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_TYPE,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__RAISED_BY_ROLE,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__RAISED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__REPLIED_BY_ROLE,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_QUERY__REPLIED_BY_USER_REFERENCE,
        nullif(trim(t0.cover_name),'') as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        t0.cover_taken as CLAIM_BENEFIT_HEAD__COVERAGE_REFERENCE,
        t0.cover_name as CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION,
        cast(null as varchar) as CLAIM_LITIGATION__ADVISORY_COMMITTEE_REFERRAL_INDICATOR,
        cast(null as varchar) as CLAIM_LITIGATION__COURT_NAME,
        cast(null as varchar) as CLAIM_LITIGATION__COURT_TYPE,
        cast(null as varchar) as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        cast(null as varchar) as CLAIM_NOTE__NOTE_AUTHOR_REFERENCE,
        cast(null as varchar) as CLAIM_NOTE__NOTE_CATEGORY,
        cast(null as varchar) as CLAIM_NOTE__NOTE_DATE,
        cast(null as varchar) as CLAIM_NOTE__NOTE_TEXT,
        cast(null as varchar) as CLAIM_NOTE__NOTE_TYPE,
        cast(null as varchar) as CLAIM_RECOVERY_SALVAGE__SALVAGE_INDICATOR,
        cast(null as varchar) as CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_TYPE_CK,
        cast(null as varchar) as CLAIM_SURVEY_APPOINTMENT__SURVEYOR_REFERENCE_CK,
        cast(null as varchar) as CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_STATUS,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__MOTOR_CLAIM_COUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_POLICY_HISTORY__TOTAL_POLICY_COUNT,
        cast(null as varchar) as PARTY_PORTFOLIO_SUMMARY__ACTIVE_POLICY_COUNT,
        cast(null as varchar) as PARTY_PORTFOLIO_SUMMARY__CROSS_HOLD_COUNT,
        cast(null as varchar) as PARTY_PORTFOLIO_SUMMARY__MOTOR_HOLDING_INDICATOR,
        cast(null as varchar) as PARTY_RELATIONSHIP_PROFILE__LOYALTY_TIER,
        cast(null as varchar) as PARTY_RELATIONSHIP_PROFILE__PROFITABILITY_INDEX,
        cast(null as varchar) as PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_TENURE,
        cast(null as varchar) as PARTY_RELATIONSHIP_PROFILE__TOTAL_PREMIUM_PAID_LIFETIME,
        cast(null as varchar) as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.claimno), ''), '')) is not null

    union all

    -- branch 1: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.outward_date),'') as AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK,
        nullif(trim(t0.outward_number),'') as AUG_CLAIM_COMMUNICATION__SEQUENCE_CK,
        null,
        t0.courier_name as AUG_CLAIM_COMMUNICATION__COURIER_VENDOR_NAME,
        t0.mode_of_dispatch as AUG_CLAIM_COMMUNICATION__DISPATCH_MODE,
        null, null,
        t0.outward_date as AUG_CLAIM_COMMUNICATION__OUTWARD_REGISTRATION_DATE,
        t0.outward_number as AUG_CLAIM_COMMUNICATION__OUTWARD_REGISTRATION_NUMBER,
        t0.pod_number as AUG_CLAIM_COMMUNICATION__PROOF_OF_DELIVERY_NUMBER,
        t0.sender_name as AUG_CLAIM_COMMUNICATION__SENDER_NAME,
        t0.sent_to as AUG_CLAIM_COMMUNICATION__SENT_TO_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.claimno), ''), '')) is not null

    union all

    -- branch 2: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(nullif(trim(t0.claimno),''), '') as CLAIM_BK,
        nullif(nullif(trim(t0.stored_company_code),''), '') as ORG_UNIT_BK,
        nullif('DL:' || nullif(trim(t0.driver_license_number),''), '') as PARTY_BK,
        nullif(nullif(trim(j3.policyno),''), '') as POLICY_BK,
        nullif(nullif(trim(t0.stored_product_code),''), '') as PRODUCT_BK,
        null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        1 as __LNK_CLAIM_PARTY,
        1 as __LNK_CLAIM_POLICY,
        1 as __LNK_CLAIM_RISK_OBJECT,
        1 as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_POLICY_RISK_OBJECT,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.camcom_image_upload_status as AUG_CLAIM_EVIDENCE__IMAGE_UPLOAD_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.select_inspection_address as AUG_CLAIM_SURVEY_APPOINTMENT__INSPECTION_ADDRESS_TEXT,
        t0.live_video_survey_flag as AUG_CLAIM_SURVEY_APPOINTMENT__LIVE_VIDEO_SURVEY_INDICATOR,
        t0.survey_flag as AUG_CLAIM_SURVEY_APPOINTMENT__SURVEY_CARRIED_OUT_INDICATOR,
        null, null,
        t0.driver_relation_with_insured as AUG_LNK_CLAIM_PARTY_ROLE__RELATIONSHIP_TO_INSURED,
        null, null, null, null, null,
        t0.ncb_status as AUG_POLICY_BONUS_TRACKING__NCB_STATUS,
        t0.previous_ncb as AUG_POLICY_BONUS_TRACKING__PREVIOUS_BONUS_AMOUNT,
        t0.previous_ncb_rate as AUG_POLICY_BONUS_TRACKING__PREVIOUS_NCB_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.route_claim_through_advisory_committee as CLAIM_LITIGATION__ADVISORY_COMMITTEE_REFERRAL_INDICATOR,
        t0.court_name_as_per_intimation_details as CLAIM_LITIGATION__COURT_NAME,
        t0.case_filed_before as CLAIM_LITIGATION__COURT_TYPE,
        null, null, null, null, null, null,
        t0.do_you_want_to_retain_salvage as CLAIM_RECOVERY_SALVAGE__SALVAGE_INDICATOR,
        'SURVEY' as CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_TYPE_CK,
        null,
        t0.survey_report_status as CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_STATUS,
        null, null, null, null, null, null, null, null, null, null,
        t0.current_ncb as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        t0.current_ncb_rate as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_attr_properties') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif('DL:' || nullif(trim(t0.driver_license_number),''), ''), nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j3.policyno),''), ''), nullif(nullif(trim(t0.claimno),''), ''), nullif(nullif(trim(t0.stored_company_code),''), ''), nullif(nullif(trim(t0.stored_product_code),''), ''))) is not null

    union all

    -- branch 3: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null, null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.latest_policy_location_name_of_policy_issuance as AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_ISSUING_OFFICE,
        t0.latest_policy_line_of_business as AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_LINE_OF_BUSINESS,
        t0.latest_policy_product_name as AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_PRODUCT_NAME,
        t0.latest_policy_sub_channnel as AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_SUB_CHANNEL,
        t0.customer_taking_policies_from_multiple_channels as AUG_PARTY_PORTFOLIO_SUMMARY__MULTI_CHANNEL_PURCHASE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.total_incurred_amount_for_claims_raised_by_customers as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        t0.total_policies_purchased as PARTY_POLICY_HISTORY__TOTAL_POLICY_COUNT,
        t0.no_of_active_policies as PARTY_PORTFOLIO_SUMMARY__ACTIVE_POLICY_COUNT,
        t0.cross_sell_policies_purchased as PARTY_PORTFOLIO_SUMMARY__CROSS_HOLD_COUNT,
        null,
        t0.loyality_bucket_by_nomenclature as PARTY_RELATIONSHIP_PROFILE__LOYALTY_TIER,
        t0.retail_customer_profitability_flag_as_per_logic_by_actuary_team as PARTY_RELATIONSHIP_PROFILE__PROFITABILITY_INDEX,
        t0.customer_active_period_with_bagic_in_year as PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_TENURE,
        t0.total_premium_paid as PARTY_RELATIONSHIP_PROFILE__TOTAL_PREMIUM_PAID_LIFETIME,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '')) is not null

    union all

    -- branch 4: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_EVENT_FOLLOWUP
    select
        nullif(nullif(trim(j1.claimno),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.assigned_personal as AUG_CLAIM_FOLLOW_UP_CHASE__ASSIGNED_TO_USER_REFERENCE,
        null,
        t0.created_by as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_CREATED_BY_USER_REFERENCE,
        t0.created_date as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_CREATED_DATE,
        t0.description_remarks as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_DESCRIPTION_REMARKS,
        t0.event_effective_date as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_EFFECTIVE_DATE,
        t0.event_code as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_EVENT_CODE,
        t0.keyword as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_KEYWORD,
        t0.priority_indicator as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_PRIORITY,
        t0.claim_followup_status as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_STATUS,
        t0.followup_timestamp as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_TIMESTAMP,
        t0.last_updated_by as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE,
        t0.last_updated_date as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_DATE,
        null, null,
        t0.job_status as AUG_CLAIM_FOLLOW_UP_CHASE__WORKFLOW_JOB_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_event_followup') }} t0
    left join {{ ref('stg_mxm__clm_cd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.claimno),''), '')) is not null

    union all

    -- branch 5: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_HISTORY
    select
        nullif(nullif(trim(j1.claimno),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.event as AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE,
        t0.claim_status as AUG_CLAIM_STATUS_TRANSITION__CLAIM_STATUS_CODE,
        t0.claim_sub_status as AUG_CLAIM_STATUS_TRANSITION__CLAIM_SUB_STATUS_CODE,
        t0.delay_reason as AUG_CLAIM_STATUS_TRANSITION__DELAY_REASON,
        t0.event_date as AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE,
        t0.event_description as AUG_CLAIM_STATUS_TRANSITION__EVENT_DESCRIPTION,
        t0.details as AUG_CLAIM_STATUS_TRANSITION__EVENT_DETAIL_TEXT,
        t0.created_date as AUG_CLAIM_STATUS_TRANSITION__EVENT_RECORD_CREATED_DATE,
        t0.reference_number as AUG_CLAIM_STATUS_TRANSITION__EVENT_REFERENCE_NUMBER,
        t0.remarks as AUG_CLAIM_STATUS_TRANSITION__EVENT_REMARKS,
        t0.type as AUG_CLAIM_STATUS_TRANSITION__HISTORY_ENTRY_TYPE,
        t0.ppi_indicator as AUG_CLAIM_STATUS_TRANSITION__PPI_INDICATOR,
        t0.claim_requirement_status as AUG_CLAIM_STATUS_TRANSITION__REQUIREMENT_STATUS_AT_EVENT,
        t0.scrutiny_status as AUG_CLAIM_STATUS_TRANSITION__SCRUTINY_STATUS,
        t0.survey_report_status as AUG_CLAIM_STATUS_TRANSITION__SURVEY_REPORT_STATUS,
        t0.user_code as AUG_CLAIM_STATUS_TRANSITION__TRANSITION_ACTOR_USER_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_history') }} t0
    left join {{ ref('stg_mxm__clm_cd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.claimno),''), '')) is not null

    union all

    -- branch 6: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_NOTES
    select
        nullif(nullif(trim(j1.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.note_type_cd),'') as AUG_CLAIM_NOTE__NOTE_AUTHOR_ROLE_CK,
        t0.assigned_user_name as AUG_CLAIM_NOTE__ASSIGNED_TO_USER_NAME,
        t0.assigned_user_cd as AUG_CLAIM_NOTE__ASSIGNED_TO_USER_REFERENCE,
        t0.description as AUG_CLAIM_NOTE__NOTE_SUMMARY_TEXT,
        t0.updated_by as AUG_CLAIM_NOTE__NOTE_UPDATED_BY_USER_REFERENCE,
        t0.updated_on as AUG_CLAIM_NOTE__NOTE_UPDATED_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.created_by as CLAIM_NOTE__NOTE_AUTHOR_REFERENCE,
        t0.type as CLAIM_NOTE__NOTE_CATEGORY,
        t0.created_on as CLAIM_NOTE__NOTE_DATE,
        t0.long_description as CLAIM_NOTE__NOTE_TEXT,
        t0.note_type_cd as CLAIM_NOTE__NOTE_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_notes') }} t0
    left join {{ ref('stg_mxm__clm_cd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.claimno), ''), '')) is not null

    union all

    -- branch 7: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_holder_code),''), '') as PARTY_BK,
        nullif(nullif(trim(j5.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.deficient_main_remarks as AUG_POLICY_UNDERWRITING_QUERY__DEFICIENCY_MAIN_REMARKS,
        t0.deficient_sub_remarks as AUG_POLICY_UNDERWRITING_QUERY__DEFICIENCY_SUB_REMARKS,
        t0.ops_query as AUG_POLICY_UNDERWRITING_QUERY__OPERATIONS_QUERY_TEXT,
        t0.query_code as AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE,
        t0.query_details as AUG_POLICY_UNDERWRITING_QUERY__QUERY_DETAIL,
        t0.date_and_time as AUG_POLICY_UNDERWRITING_QUERY__QUERY_RAISED_TIMESTAMP,
        t0.query_reply as AUG_POLICY_UNDERWRITING_QUERY__QUERY_REPLY_TEXT,
        t0.reply_date_and_time as AUG_POLICY_UNDERWRITING_QUERY__QUERY_REPLY_TIMESTAMP,
        t0.response as AUG_POLICY_UNDERWRITING_QUERY__QUERY_RESPONSE_TEXT,
        t0.query_status as AUG_POLICY_UNDERWRITING_QUERY__QUERY_STATUS,
        t0.query_type as AUG_POLICY_UNDERWRITING_QUERY__QUERY_TYPE,
        t0.raised_by_role as AUG_POLICY_UNDERWRITING_QUERY__RAISED_BY_ROLE,
        t0.raised_byuser as AUG_POLICY_UNDERWRITING_QUERY__RAISED_BY_USER_REFERENCE,
        t0.replied_by_role as AUG_POLICY_UNDERWRITING_QUERY__REPLIED_BY_ROLE,
        t0.replied_by_user as AUG_POLICY_UNDERWRITING_QUERY__REPLIED_BY_USER_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.no_of_claims as PARTY_CLAIM_HISTORY__MOTOR_CLAIM_COUNT,
        t0.claim_amount as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        null, null, null,
        t0.do_you_have_motor_policy_with_bagic as PARTY_PORTFOLIO_SUMMARY__MOTOR_HOLDING_INDICATOR,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j5.policy_holder_code),''), ''), nullif(nullif(trim(j5.policy_number),''), ''))) is not null

    union all

    -- branch 8: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_holder_code),''), '') as PARTY_BK,
        null, null,
        nullif(nullif(trim(j5.policy_quote_number),''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.age as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_AGE,
        t0.gender as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_GENDER,
        t0.name_of_person as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME,
        t0.relationship as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_RELATIONSHIP,
        null,
        t0.deficient_main_remarks as AUG_QUOTE_UNDERWRITING_QUERY__DEFICIENCY_MAIN_REMARKS,
        t0.deficient_sub_remarks as AUG_QUOTE_UNDERWRITING_QUERY__DEFICIENCY_SUB_REMARKS,
        t0.ops_query as AUG_QUOTE_UNDERWRITING_QUERY__OPERATIONS_QUERY_TEXT,
        t0.query_code as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE,
        t0.query_details as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_DETAIL,
        t0.date_and_time as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_RAISED_TIMESTAMP,
        t0.query_reply as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_REPLY_TEXT,
        t0.reply_date_and_time as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_REPLY_TIMESTAMP,
        t0.response as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_RESPONSE_TEXT,
        t0.query_status as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_STATUS,
        t0.query_type as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_TYPE,
        t0.raised_by_role as AUG_QUOTE_UNDERWRITING_QUERY__RAISED_BY_ROLE,
        t0.raised_byuser as AUG_QUOTE_UNDERWRITING_QUERY__RAISED_BY_USER_REFERENCE,
        t0.replied_by_role as AUG_QUOTE_UNDERWRITING_QUERY__REPLIED_BY_ROLE,
        t0.replied_by_user as AUG_QUOTE_UNDERWRITING_QUERY__REPLIED_BY_USER_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.no_of_claims as PARTY_CLAIM_HISTORY__MOTOR_CLAIM_COUNT,
        t0.claim_amount as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        null, null, null,
        t0.do_you_have_motor_policy_with_bagic as PARTY_PORTFOLIO_SUMMARY__MOTOR_HOLDING_INDICATOR,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_msp_input_msd_input_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_msp_input_msd_input_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_msp_input_msd_input') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_msp_input') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j5.policy_holder_code),''), ''), nullif(nullif(trim(j5.policy_quote_number),''), ''))) is not null

)

select
    CLAIM_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    QUOTE_BK,
    RISK_OBJECT_BK,
    __LNK_CLAIM_PARTY,
    __LNK_CLAIM_POLICY,
    __LNK_CLAIM_RISK_OBJECT,
    __LNK_POLICY_ORG_UNIT,
    __LNK_POLICY_PRODUCT,
    __LNK_POLICY_RISK_OBJECT,
    AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK,
    AUG_CLAIM_COMMUNICATION__SEQUENCE_CK,
    first_value(AUG_CLAIM_COMMUNICATION__ACKNOWLEDGEMENT_RECEIVED_INDICATOR) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, AUG_CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COMMUNICATION__ACKNOWLEDGEMENT_RECEIVED_INDICATOR,
    first_value(AUG_CLAIM_COMMUNICATION__COURIER_VENDOR_NAME) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, AUG_CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COMMUNICATION__COURIER_VENDOR_NAME,
    first_value(AUG_CLAIM_COMMUNICATION__DISPATCH_MODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, AUG_CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COMMUNICATION__DISPATCH_MODE,
    first_value(AUG_CLAIM_COMMUNICATION__INWARD_MODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, AUG_CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COMMUNICATION__INWARD_MODE,
    first_value(AUG_CLAIM_COMMUNICATION__INWARD_REGISTRATION_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, AUG_CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COMMUNICATION__INWARD_REGISTRATION_DATE,
    first_value(AUG_CLAIM_COMMUNICATION__OUTWARD_REGISTRATION_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, AUG_CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COMMUNICATION__OUTWARD_REGISTRATION_DATE,
    first_value(AUG_CLAIM_COMMUNICATION__OUTWARD_REGISTRATION_NUMBER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, AUG_CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COMMUNICATION__OUTWARD_REGISTRATION_NUMBER,
    first_value(AUG_CLAIM_COMMUNICATION__PROOF_OF_DELIVERY_NUMBER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, AUG_CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COMMUNICATION__PROOF_OF_DELIVERY_NUMBER,
    first_value(AUG_CLAIM_COMMUNICATION__SENDER_NAME) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, AUG_CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COMMUNICATION__SENDER_NAME,
    first_value(AUG_CLAIM_COMMUNICATION__SENT_TO_NAME) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, AUG_CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COMMUNICATION__SENT_TO_NAME,
    first_value(AUG_CLAIM_EVIDENCE__IMAGE_UPLOAD_STATUS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_EVIDENCE__IMAGE_UPLOAD_STATUS,
    AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__ASSIGNED_TO_USER_REFERENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__ASSIGNED_TO_USER_REFERENCE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_CREATED_BY_USER_REFERENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_CREATED_BY_USER_REFERENCE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_CREATED_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_CREATED_DATE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_DESCRIPTION_REMARKS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_DESCRIPTION_REMARKS,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_EFFECTIVE_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_EFFECTIVE_DATE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_EVENT_CODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_EVENT_CODE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_KEYWORD) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_KEYWORD,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_PRIORITY) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_PRIORITY,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_STATUS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_STATUS,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_TIMESTAMP) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_TIMESTAMP,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_DATE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__THIRD_REMINDER_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__THIRD_REMINDER_DATE,
    first_value(AUG_CLAIM_FOLLOW_UP_CHASE__WORKFLOW_JOB_STATUS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FOLLOW_UP_CHASE__WORKFLOW_JOB_STATUS,
    AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK,
    AUG_CLAIM_NOTE__NOTE_AUTHOR_ROLE_CK,
    first_value(AUG_CLAIM_NOTE__ASSIGNED_TO_USER_NAME) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK, AUG_CLAIM_NOTE__NOTE_AUTHOR_ROLE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_NOTE__ASSIGNED_TO_USER_NAME,
    first_value(AUG_CLAIM_NOTE__ASSIGNED_TO_USER_REFERENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK, AUG_CLAIM_NOTE__NOTE_AUTHOR_ROLE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_NOTE__ASSIGNED_TO_USER_REFERENCE,
    first_value(AUG_CLAIM_NOTE__NOTE_SUMMARY_TEXT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK, AUG_CLAIM_NOTE__NOTE_AUTHOR_ROLE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_NOTE__NOTE_SUMMARY_TEXT,
    first_value(AUG_CLAIM_NOTE__NOTE_UPDATED_BY_USER_REFERENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK, AUG_CLAIM_NOTE__NOTE_AUTHOR_ROLE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_NOTE__NOTE_UPDATED_BY_USER_REFERENCE,
    first_value(AUG_CLAIM_NOTE__NOTE_UPDATED_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK, AUG_CLAIM_NOTE__NOTE_AUTHOR_ROLE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_NOTE__NOTE_UPDATED_DATE,
    AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK,
    AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK,
    first_value(AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE,
    first_value(AUG_CLAIM_STATUS_TRANSITION__CLAIM_STATUS_CODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__CLAIM_STATUS_CODE,
    first_value(AUG_CLAIM_STATUS_TRANSITION__CLAIM_SUB_STATUS_CODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__CLAIM_SUB_STATUS_CODE,
    first_value(AUG_CLAIM_STATUS_TRANSITION__DELAY_REASON) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__DELAY_REASON,
    first_value(AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE,
    first_value(AUG_CLAIM_STATUS_TRANSITION__EVENT_DESCRIPTION) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__EVENT_DESCRIPTION,
    first_value(AUG_CLAIM_STATUS_TRANSITION__EVENT_DETAIL_TEXT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__EVENT_DETAIL_TEXT,
    first_value(AUG_CLAIM_STATUS_TRANSITION__EVENT_RECORD_CREATED_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__EVENT_RECORD_CREATED_DATE,
    first_value(AUG_CLAIM_STATUS_TRANSITION__EVENT_REFERENCE_NUMBER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__EVENT_REFERENCE_NUMBER,
    first_value(AUG_CLAIM_STATUS_TRANSITION__EVENT_REMARKS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__EVENT_REMARKS,
    first_value(AUG_CLAIM_STATUS_TRANSITION__HISTORY_ENTRY_TYPE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__HISTORY_ENTRY_TYPE,
    first_value(AUG_CLAIM_STATUS_TRANSITION__PPI_INDICATOR) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__PPI_INDICATOR,
    first_value(AUG_CLAIM_STATUS_TRANSITION__REQUIREMENT_STATUS_AT_EVENT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__REQUIREMENT_STATUS_AT_EVENT,
    first_value(AUG_CLAIM_STATUS_TRANSITION__SCRUTINY_STATUS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__SCRUTINY_STATUS,
    first_value(AUG_CLAIM_STATUS_TRANSITION__SURVEY_REPORT_STATUS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__SURVEY_REPORT_STATUS,
    first_value(AUG_CLAIM_STATUS_TRANSITION__TRANSITION_ACTOR_USER_REFERENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__TRANSITION_ACTOR_USER_REFERENCE,
    first_value(AUG_CLAIM_SURVEY_APPOINTMENT__INSPECTION_ADDRESS_TEXT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SURVEY_APPOINTMENT__INSPECTION_ADDRESS_TEXT,
    first_value(AUG_CLAIM_SURVEY_APPOINTMENT__LIVE_VIDEO_SURVEY_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SURVEY_APPOINTMENT__LIVE_VIDEO_SURVEY_INDICATOR,
    first_value(AUG_CLAIM_SURVEY_APPOINTMENT__SURVEY_CARRIED_OUT_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SURVEY_APPOINTMENT__SURVEY_CARRIED_OUT_INDICATOR,
    AUG_LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
    AUG_LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK,
    first_value(AUG_LNK_CLAIM_PARTY_ROLE__RELATIONSHIP_TO_INSURED) ignore nulls over (partition by CLAIM_BK, PARTY_BK, AUG_LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK, AUG_LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_LNK_CLAIM_PARTY_ROLE__RELATIONSHIP_TO_INSURED,
    first_value(AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_ISSUING_OFFICE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_ISSUING_OFFICE,
    first_value(AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_LINE_OF_BUSINESS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_LINE_OF_BUSINESS,
    first_value(AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_PRODUCT_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_PRODUCT_NAME,
    first_value(AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_SUB_CHANNEL) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_SUB_CHANNEL,
    first_value(AUG_PARTY_PORTFOLIO_SUMMARY__MULTI_CHANNEL_PURCHASE_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PORTFOLIO_SUMMARY__MULTI_CHANNEL_PURCHASE_INDICATOR,
    first_value(AUG_POLICY_BONUS_TRACKING__NCB_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_BONUS_TRACKING__NCB_STATUS,
    first_value(AUG_POLICY_BONUS_TRACKING__PREVIOUS_BONUS_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_BONUS_TRACKING__PREVIOUS_BONUS_AMOUNT,
    first_value(AUG_POLICY_BONUS_TRACKING__PREVIOUS_NCB_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_BONUS_TRACKING__PREVIOUS_NCB_PERCENTAGE,
    AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__DEFICIENCY_MAIN_REMARKS) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__DEFICIENCY_MAIN_REMARKS,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__DEFICIENCY_SUB_REMARKS) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__DEFICIENCY_SUB_REMARKS,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__OPERATIONS_QUERY_TEXT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__OPERATIONS_QUERY_TEXT,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__QUERY_DETAIL) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_DETAIL,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__QUERY_RAISED_TIMESTAMP) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_RAISED_TIMESTAMP,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__QUERY_REPLY_TEXT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_REPLY_TEXT,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__QUERY_REPLY_TIMESTAMP) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_REPLY_TIMESTAMP,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__QUERY_RESPONSE_TEXT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_RESPONSE_TEXT,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__QUERY_STATUS) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_STATUS,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__QUERY_TYPE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__QUERY_TYPE,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__RAISED_BY_ROLE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__RAISED_BY_ROLE,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__RAISED_BY_USER_REFERENCE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__RAISED_BY_USER_REFERENCE,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__REPLIED_BY_ROLE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__REPLIED_BY_ROLE,
    first_value(AUG_POLICY_UNDERWRITING_QUERY__REPLIED_BY_USER_REFERENCE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_QUERY__REPLIED_BY_USER_REFERENCE,
    AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK,
    first_value(AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_AGE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_AGE,
    first_value(AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_GENDER) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_GENDER,
    first_value(AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME,
    first_value(AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_RELATIONSHIP) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_RELATIONSHIP,
    AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__DEFICIENCY_MAIN_REMARKS) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__DEFICIENCY_MAIN_REMARKS,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__DEFICIENCY_SUB_REMARKS) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__DEFICIENCY_SUB_REMARKS,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__OPERATIONS_QUERY_TEXT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__OPERATIONS_QUERY_TEXT,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__QUERY_DETAIL) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_DETAIL,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__QUERY_RAISED_TIMESTAMP) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_RAISED_TIMESTAMP,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__QUERY_REPLY_TEXT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_REPLY_TEXT,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__QUERY_REPLY_TIMESTAMP) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_REPLY_TIMESTAMP,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__QUERY_RESPONSE_TEXT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_RESPONSE_TEXT,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__QUERY_STATUS) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_STATUS,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__QUERY_TYPE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__QUERY_TYPE,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__RAISED_BY_ROLE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__RAISED_BY_ROLE,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__RAISED_BY_USER_REFERENCE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__RAISED_BY_USER_REFERENCE,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__REPLIED_BY_ROLE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__REPLIED_BY_ROLE,
    first_value(AUG_QUOTE_UNDERWRITING_QUERY__REPLIED_BY_USER_REFERENCE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_QUERY__REPLIED_BY_USER_REFERENCE,
    CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
    first_value(CLAIM_BENEFIT_HEAD__COVERAGE_REFERENCE) ignore nulls over (partition by CLAIM_BK, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BENEFIT_HEAD__COVERAGE_REFERENCE,
    first_value(CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION) ignore nulls over (partition by CLAIM_BK, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION,
    first_value(CLAIM_LITIGATION__ADVISORY_COMMITTEE_REFERRAL_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_LITIGATION__ADVISORY_COMMITTEE_REFERRAL_INDICATOR,
    first_value(CLAIM_LITIGATION__COURT_NAME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_LITIGATION__COURT_NAME,
    first_value(CLAIM_LITIGATION__COURT_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_LITIGATION__COURT_TYPE,
    CLAIM_NOTE__NOTE_SEQUENCE_CK,
    first_value(CLAIM_NOTE__NOTE_AUTHOR_REFERENCE) ignore nulls over (partition by CLAIM_BK, CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_NOTE__NOTE_AUTHOR_REFERENCE,
    first_value(CLAIM_NOTE__NOTE_CATEGORY) ignore nulls over (partition by CLAIM_BK, CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_NOTE__NOTE_CATEGORY,
    first_value(CLAIM_NOTE__NOTE_DATE) ignore nulls over (partition by CLAIM_BK, CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_NOTE__NOTE_DATE,
    first_value(CLAIM_NOTE__NOTE_TEXT) ignore nulls over (partition by CLAIM_BK, CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_NOTE__NOTE_TEXT,
    first_value(CLAIM_NOTE__NOTE_TYPE) ignore nulls over (partition by CLAIM_BK, CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_NOTE__NOTE_TYPE,
    first_value(CLAIM_RECOVERY_SALVAGE__SALVAGE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RECOVERY_SALVAGE__SALVAGE_INDICATOR,
    CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_TYPE_CK,
    CLAIM_SURVEY_APPOINTMENT__SURVEYOR_REFERENCE_CK,
    first_value(CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_STATUS) ignore nulls over (partition by CLAIM_BK, CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_TYPE_CK, CLAIM_SURVEY_APPOINTMENT__SURVEYOR_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_STATUS,
    first_value(PARTY_CLAIM_HISTORY__MOTOR_CLAIM_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_CLAIM_HISTORY__MOTOR_CLAIM_COUNT,
    first_value(PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
    first_value(PARTY_POLICY_HISTORY__TOTAL_POLICY_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_POLICY_HISTORY__TOTAL_POLICY_COUNT,
    first_value(PARTY_PORTFOLIO_SUMMARY__ACTIVE_POLICY_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PORTFOLIO_SUMMARY__ACTIVE_POLICY_COUNT,
    first_value(PARTY_PORTFOLIO_SUMMARY__CROSS_HOLD_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PORTFOLIO_SUMMARY__CROSS_HOLD_COUNT,
    first_value(PARTY_PORTFOLIO_SUMMARY__MOTOR_HOLDING_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PORTFOLIO_SUMMARY__MOTOR_HOLDING_INDICATOR,
    first_value(PARTY_RELATIONSHIP_PROFILE__LOYALTY_TIER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_RELATIONSHIP_PROFILE__LOYALTY_TIER,
    first_value(PARTY_RELATIONSHIP_PROFILE__PROFITABILITY_INDEX) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_RELATIONSHIP_PROFILE__PROFITABILITY_INDEX,
    first_value(PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_TENURE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_TENURE,
    first_value(PARTY_RELATIONSHIP_PROFILE__TOTAL_PREMIUM_PAID_LIFETIME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_RELATIONSHIP_PROFILE__TOTAL_PREMIUM_PAID_LIFETIME,
    first_value(POLICY_BONUS_TRACKING__BONUS_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
    first_value(POLICY_BONUS_TRACKING__NCB_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.REC_REFRESH_AT,
    -- multi-active satellites on CLAIM_BK (SAT_MOTOR_AUG_CLAIM_COMMUNICATION, SAT_MOTOR_AUG_CLAIM_FOLLOW_UP_CHASE, SAT_MOTOR_AUG_CLAIM_NOTE, SAT_MOTOR_AUG_CLAIM_STATUS_TRANSITION, SAT_MOTOR_AUG_LNK_CLAIM_PARTY_ROLE, SAT_CLAIM_BENEFIT_HEAD, SAT_CLAIM_NOTE, SAT_CLAIM_SURVEY_APPOINTMENT):
    -- one load time per CLAIM_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_CLAIM_COMMUNICATION__ACKNOWLEDGEMENT_RECEIVED_INDICATOR, m.AUG_CLAIM_COMMUNICATION__COURIER_VENDOR_NAME, m.AUG_CLAIM_COMMUNICATION__DISPATCH_MODE, m.AUG_CLAIM_COMMUNICATION__INWARD_MODE, m.AUG_CLAIM_COMMUNICATION__INWARD_REGISTRATION_DATE, m.AUG_CLAIM_COMMUNICATION__OUTWARD_REGISTRATION_DATE, m.AUG_CLAIM_COMMUNICATION__OUTWARD_REGISTRATION_NUMBER, m.AUG_CLAIM_COMMUNICATION__PROOF_OF_DELIVERY_NUMBER, m.AUG_CLAIM_COMMUNICATION__SENDER_NAME, m.AUG_CLAIM_COMMUNICATION__SENT_TO_NAME, m.AUG_CLAIM_FOLLOW_UP_CHASE__ASSIGNED_TO_USER_REFERENCE, m.AUG_CLAIM_FOLLOW_UP_CHASE__FIRST_REMINDER_DATE, m.AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_CREATED_BY_USER_REFERENCE, m.AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_CREATED_DATE, m.AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_DESCRIPTION_REMARKS, m.AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_EFFECTIVE_DATE, m.AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_EVENT_CODE, m.AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_KEYWORD, m.AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_PRIORITY, m.AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_STATUS, m.AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_TIMESTAMP, m.AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_BY_USER_REFERENCE, m.AUG_CLAIM_FOLLOW_UP_CHASE__FOLLOW_UP_UPDATED_DATE, m.AUG_CLAIM_FOLLOW_UP_CHASE__SECOND_REMINDER_DATE, m.AUG_CLAIM_FOLLOW_UP_CHASE__THIRD_REMINDER_DATE, m.AUG_CLAIM_FOLLOW_UP_CHASE__WORKFLOW_JOB_STATUS, m.AUG_CLAIM_NOTE__ASSIGNED_TO_USER_NAME, m.AUG_CLAIM_NOTE__ASSIGNED_TO_USER_REFERENCE, m.AUG_CLAIM_NOTE__NOTE_SUMMARY_TEXT, m.AUG_CLAIM_NOTE__NOTE_UPDATED_BY_USER_REFERENCE, m.AUG_CLAIM_NOTE__NOTE_UPDATED_DATE, m.AUG_CLAIM_STATUS_TRANSITION__CLAIM_EVENT_CODE, m.AUG_CLAIM_STATUS_TRANSITION__CLAIM_STATUS_CODE, m.AUG_CLAIM_STATUS_TRANSITION__CLAIM_SUB_STATUS_CODE, m.AUG_CLAIM_STATUS_TRANSITION__DELAY_REASON, m.AUG_CLAIM_STATUS_TRANSITION__EVENT_DATE, m.AUG_CLAIM_STATUS_TRANSITION__EVENT_DESCRIPTION, m.AUG_CLAIM_STATUS_TRANSITION__EVENT_DETAIL_TEXT, m.AUG_CLAIM_STATUS_TRANSITION__EVENT_RECORD_CREATED_DATE, m.AUG_CLAIM_STATUS_TRANSITION__EVENT_REFERENCE_NUMBER, m.AUG_CLAIM_STATUS_TRANSITION__EVENT_REMARKS, m.AUG_CLAIM_STATUS_TRANSITION__HISTORY_ENTRY_TYPE, m.AUG_CLAIM_STATUS_TRANSITION__PPI_INDICATOR, m.AUG_CLAIM_STATUS_TRANSITION__REQUIREMENT_STATUS_AT_EVENT, m.AUG_CLAIM_STATUS_TRANSITION__SCRUTINY_STATUS, m.AUG_CLAIM_STATUS_TRANSITION__SURVEY_REPORT_STATUS, m.AUG_CLAIM_STATUS_TRANSITION__TRANSITION_ACTOR_USER_REFERENCE, m.AUG_LNK_CLAIM_PARTY_ROLE__RELATIONSHIP_TO_INSURED, m.CLAIM_BENEFIT_HEAD__COVERAGE_REFERENCE, m.CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION, m.CLAIM_NOTE__NOTE_AUTHOR_REFERENCE, m.CLAIM_NOTE__NOTE_CATEGORY, m.CLAIM_NOTE__NOTE_DATE, m.CLAIM_NOTE__NOTE_TEXT, m.CLAIM_NOTE__NOTE_TYPE, m.CLAIM_SURVEY_APPOINTMENT__APPOINTMENT_STATUS) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.CLAIM_BK) as CLAIM_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on POLICY_BK (SAT_MOTOR_AUG_POLICY_UNDERWRITING_QUERY):
    -- one load time per POLICY_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_POLICY_UNDERWRITING_QUERY__DEFICIENCY_MAIN_REMARKS, m.AUG_POLICY_UNDERWRITING_QUERY__DEFICIENCY_SUB_REMARKS, m.AUG_POLICY_UNDERWRITING_QUERY__OPERATIONS_QUERY_TEXT, m.AUG_POLICY_UNDERWRITING_QUERY__QUERY_CODE, m.AUG_POLICY_UNDERWRITING_QUERY__QUERY_DETAIL, m.AUG_POLICY_UNDERWRITING_QUERY__QUERY_RAISED_TIMESTAMP, m.AUG_POLICY_UNDERWRITING_QUERY__QUERY_REPLY_TEXT, m.AUG_POLICY_UNDERWRITING_QUERY__QUERY_REPLY_TIMESTAMP, m.AUG_POLICY_UNDERWRITING_QUERY__QUERY_RESPONSE_TEXT, m.AUG_POLICY_UNDERWRITING_QUERY__QUERY_STATUS, m.AUG_POLICY_UNDERWRITING_QUERY__QUERY_TYPE, m.AUG_POLICY_UNDERWRITING_QUERY__RAISED_BY_ROLE, m.AUG_POLICY_UNDERWRITING_QUERY__RAISED_BY_USER_REFERENCE, m.AUG_POLICY_UNDERWRITING_QUERY__REPLIED_BY_ROLE, m.AUG_POLICY_UNDERWRITING_QUERY__REPLIED_BY_USER_REFERENCE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.POLICY_BK) as POLICY_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on QUOTE_BK (SAT_MOTOR_AUG_QUOTE_PA_NAMED_PERSON, SAT_MOTOR_AUG_QUOTE_UNDERWRITING_QUERY):
    -- one load time per QUOTE_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_AGE, m.AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_GENDER, m.AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME, m.AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_RELATIONSHIP, m.AUG_QUOTE_UNDERWRITING_QUERY__DEFICIENCY_MAIN_REMARKS, m.AUG_QUOTE_UNDERWRITING_QUERY__DEFICIENCY_SUB_REMARKS, m.AUG_QUOTE_UNDERWRITING_QUERY__OPERATIONS_QUERY_TEXT, m.AUG_QUOTE_UNDERWRITING_QUERY__QUERY_CODE, m.AUG_QUOTE_UNDERWRITING_QUERY__QUERY_DETAIL, m.AUG_QUOTE_UNDERWRITING_QUERY__QUERY_RAISED_TIMESTAMP, m.AUG_QUOTE_UNDERWRITING_QUERY__QUERY_REPLY_TEXT, m.AUG_QUOTE_UNDERWRITING_QUERY__QUERY_REPLY_TIMESTAMP, m.AUG_QUOTE_UNDERWRITING_QUERY__QUERY_RESPONSE_TEXT, m.AUG_QUOTE_UNDERWRITING_QUERY__QUERY_STATUS, m.AUG_QUOTE_UNDERWRITING_QUERY__QUERY_TYPE, m.AUG_QUOTE_UNDERWRITING_QUERY__RAISED_BY_ROLE, m.AUG_QUOTE_UNDERWRITING_QUERY__RAISED_BY_USER_REFERENCE, m.AUG_QUOTE_UNDERWRITING_QUERY__REPLIED_BY_ROLE, m.AUG_QUOTE_UNDERWRITING_QUERY__REPLIED_BY_USER_REFERENCE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.QUOTE_BK) as QUOTE_BK__MA_LOAD_DATETIME
from merged m
