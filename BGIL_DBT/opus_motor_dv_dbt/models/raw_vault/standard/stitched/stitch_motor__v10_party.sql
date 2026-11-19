-- CENTRAL VIEW v10_party -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BJAZ_AGENCY_MOT_WAR_DTLS
--   BJAZ_CLM_MOTOR_INTIM_DETAILS
--   BJAZ_CVTP_WS_DATA
--   BJAZ_CVTP_WS_DATA_EXTN
--   BJAZ_MOT_ADD_QSTN_DTLS
--   BJAZ_MOT_CLM_TRANS_EXTN
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_ONLINE_POL_DTLS_EXTN
--   BJAZ_MOT_WAR_CHILD_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_WB_CLM_BASE_MOT_EXT
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_PRE_INSPECTION
--   SAT_MOTOR_AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE
--   SAT_MOTOR_AUG_LOCATION_PROFILE
--   SAT_MOTOR_AUG_PARTY_CORRESPONDENCE
--   SAT_MOTOR_AUG_PARTY_EMPLOYMENT
--   SAT_MOTOR_AUG_PARTY_IDENTIFICATION
--   SAT_MOTOR_AUG_PARTY_IDENTITY
--   SAT_MOTOR_AUG_POLICY_PORTABILITY_MIGRATION
--   SAT_MOTOR_AUG_POLICY_TAX_BREAKUP
--   SAT_MOTOR_AUG_POLICY_TAX_HEAD
--   SAT_PARTY_IDENTIFICATION
--   SAT_POLICY_PORTABILITY_MIGRATION
--   SAT_POLICY_TAX_BREAKUP
--   SAT_PROPOSAL_QUESTIONNAIRE
--   SAT_RISK_EXTENDED_WARRANTY
--   SAT_RISK_TRAILER
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_LOCATION
--   LNK_POLICY_LOCATION
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_PROPOSAL_ASSESSMENT
--   LNK_PROPOSAL_PARTY
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_PRODUCT
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_AGENCY_MOT_WAR_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=GSTIN
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as LOCATION_BK,
        nullif(md5(normalise(upper(nullif(coalesce(t0.your_name, '') || '|' || coalesce(to_char(t0.mob_no), ''), '|')))), '') as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as PROPOSAL_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_PARTY_LOCATION,
        cast(null as number) as __LNK_POLICY_LOCATION,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_PROPOSAL_ASSESSMENT,
        cast(null as number) as __LNK_PROPOSAL_PARTY,
        cast(null as number) as __LNK_PROPOSAL_POLICY,
        cast(null as number) as __LNK_PROPOSAL_PRODUCT,
        cast(null as varchar) as ASSESSMENT_PRE_INSPECTION__INSPECTION_AGENCY_CODE,
        cast(null as varchar) as ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE,
        cast(null as varchar) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_CHECK_PERFORMED_INDICATOR,
        cast(null as varchar) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_DISCREPANCY_RULE_CODE,
        cast(null as varchar) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_POLICY_STATUS,
        cast(null as varchar) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_PREVIOUS_POLICY_NUMBER,
        cast(null as varchar) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_PRIOR_CLAIM_INDICATOR,
        cast(null as varchar) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__CONTINUOUS_COVER_CONFIRMED_INDICATOR,
        cast(null as varchar) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__PREVIOUS_POLICY_EXPIRED_OVER_NINETY_DAYS_INDICATOR,
        cast(null as varchar) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__PREVIOUS_POLICY_EXPIRED_WITHIN_NINETY_DAYS_INDICATOR,
        cast(null as varchar) as AUG_LOCATION_PROFILE__DWELLING_DESCRIPTION,
        cast(null as varchar) as AUG_LOCATION_PROFILE__YEARS_AT_LOCATION,
        cast(null as varchar) as AUG_PARTY_CORRESPONDENCE__DISPATCH_REFERENCE_CK,
        cast(null as varchar) as AUG_PARTY_CORRESPONDENCE__DISPATCH_CHANNEL_CK,
        cast(null as varchar) as AUG_PARTY_CORRESPONDENCE__COMMUNICATION_REQUEST_TIMESTAMP,
        cast(null as varchar) as AUG_PARTY_CORRESPONDENCE__COMMUNICATION_SCHEDULED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYER_COMPANY_CODE,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYER_RELATIONSHIP_TYPE,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        cast(null as varchar) as AUG_PARTY_IDENTITY__UNIQUE_CUSTOMER_IDENTIFICATION_CODE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_TAX_BREAKUP__TAX_TYPE_2_CODE,
        cast(null as varchar) as AUG_POLICY_TAX_BREAKUP__UTGST_AMOUNT,
        cast(null as varchar) as AUG_POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
        cast(null as varchar) as AUG_POLICY_TAX_HEAD__TAX_HEAD_IDENTIFIER,
        'GSTIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        cast(null as varchar) as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__AADHAAR_VERIFICATION_STATUS,
        t0.gstin_no as PARTY_IDENTIFICATION__GSTIN,
        cast(null as varchar) as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        cast(null as varchar) as PARTY_IDENTIFICATION__PAN_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__PAN_VERIFICATION_STATUS,
        cast(null as varchar) as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        cast(null as varchar) as POLICY_TAX_BREAKUP__CESS_AMOUNT,
        cast(null as varchar) as POLICY_TAX_BREAKUP__CGST_AMOUNT,
        cast(null as varchar) as POLICY_TAX_BREAKUP__IGST_AMOUNT,
        cast(null as varchar) as POLICY_TAX_BREAKUP__SGST_AMOUNT,
        cast(null as varchar) as POLICY_TAX_BREAKUP__STAMP_DUTY_AMOUNT,
        cast(null as varchar) as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        cast(null as varchar) as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        cast(null as varchar) as RISK_EXTENDED_WARRANTY__EXTENDED_WARRANTY_END_DATE,
        cast(null as varchar) as RISK_EXTENDED_WARRANTY__EXTENDED_WARRANTY_START_DATE,
        cast(null as varchar) as RISK_EXTENDED_WARRANTY__OEM_MAKE_REFERENCE,
        cast(null as varchar) as RISK_EXTENDED_WARRANTY__OEM_MODEL_REFERENCE,
        cast(null as varchar) as RISK_EXTENDED_WARRANTY__WARRANTY_INVOICE_NUMBER,
        cast(null as varchar) as RISK_EXTENDED_WARRANTY__WARRANTY_PLAN_CODE,
        cast(null as varchar) as RISK_EXTENDED_WARRANTY__WARRANTY_PLAN_NAME,
        cast(null as varchar) as RISK_EXTENDED_WARRANTY__WARRANTY_SUM_INSURED,
        cast(null as varchar) as RISK_EXTENDED_WARRANTY__WARRANTY_TERM_MONTHS,
        cast(null as varchar) as RISK_TRAILER__TRAILER_SEQUENCE_CK,
        cast(null as varchar) as RISK_TRAILER__ATTACHED_INDICATOR,
        cast(null as varchar) as RISK_TRAILER__TRAILER_IDV,
        cast(null as varchar) as RISK_TRAILER__TRAILER_REGISTRATION_NUMBER,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_agency_mot_war_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.your_name, '') || '|' || coalesce(to_char(t0.mob_no), ''), '|')))), '')) is not null

    union all

    -- branch 1: BJAZ_AGENCY_MOT_WAR_DTLS
    select
        null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.veh_reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.ew_plan as RISK_EXTENDED_WARRANTY__WARRANTY_PLAN_CODE,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_agency_mot_war_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.veh_reg_no), '')), '')) is not null

    union all

    -- branch 2: BJAZ_CLM_MOTOR_INTIM_DETAILS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null,
        nullif(nullif('PAN:' || nullif(trim(t0.insured_panno), ''), 'PAN:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.insured_panno as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_motor_intim_details') }} t0
    where (nullif(nullif('PAN:' || nullif(trim(t0.insured_panno), ''), 'PAN:'), '')) is not null

    union all

    -- branch 3: BJAZ_CVTP_WS_DATA | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null,
        nullif(nullif(trim(t0.proposerpan), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.proposerpan as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.proposerpan), ''), '')) is not null

    union all

    -- branch 4: BJAZ_CVTP_WS_DATA
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.trailerchassisno), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.traileridv as RISK_TRAILER__TRAILER_IDV,
        t0.trailerregistrationno as RISK_TRAILER__TRAILER_REGISTRATION_NUMBER,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.trailerchassisno), ''), '')) is not null

    union all

    -- branch 5: BJAZ_CVTP_WS_DATA_EXTN
    select
        nullif(nullif(trim(t0.breakinreferenceno), ''), '') as ASSESSMENT_BK,
        null, null, null, null,
        nullif(nullif('VISOF:' || nullif(trim(t0.visofnumber), ''), 'VISOF:'), '') as PROPOSAL_BK,
        null, null, null, null, null,
        1 as __LNK_PROPOSAL_ASSESSMENT,
        null, null, null,
        t0.breakininspectionagency as ASSESSMENT_PRE_INSPECTION__INSPECTION_AGENCY_CODE,
        t0.breakininspectiondate as ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data_extn') }} t0
    where (coalesce(nullif(nullif('VISOF:' || nullif(trim(t0.visofnumber), ''), 'VISOF:'), ''), nullif(nullif(trim(t0.breakinreferenceno), ''), ''))) is not null

    union all

    -- branch 6: BJAZ_CVTP_WS_DATA_EXTN | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AADHAAR
    select
        null, null,
        nullif(nullif('POSP:' || nullif(trim(t0.pspuniqueno), ''), 'POSP:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.pspaadhaarcardnumber as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data_extn') }} t0
    where (nullif(nullif('POSP:' || nullif(trim(t0.pspuniqueno), ''), 'POSP:'), '')) is not null

    union all

    -- branch 7: BJAZ_CVTP_WS_DATA_EXTN | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null,
        nullif(nullif('POSP:' || nullif(trim(t0.pspuniqueno), ''), 'POSP:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.psppannumber as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data_extn') }} t0
    where (nullif(nullif('POSP:' || nullif(trim(t0.pspuniqueno), ''), 'POSP:'), '')) is not null

    union all

    -- branch 8: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null,
        nullif(nullif(trim(t0.pan_no), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.pan_no as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(t0.pan_no), ''), '')) is not null

    union all

    -- branch 9: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=KM_READING
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'KM_READING' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.km_reading as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 10: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=OD_CLAIM
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'OD_CLAIM' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.od_claim as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 11: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=OD_CLAIM_AMT
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'OD_CLAIM_AMT' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.od_claim_amt as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 12: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=TP_CLAIM
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'TP_CLAIM' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.tp_claim as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 13: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=TP_CLAIM_AMT
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'TP_CLAIM_AMT' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.tp_claim_amt as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 14: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=THEFT_INDICATOR
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'THEFT_INDICATOR' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.theft_indicator as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 15: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=TOTAL_CLAIM_INDICATOR
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'TOTAL_CLAIM_INDICATOR' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.total_claim_indicator as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 16: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=BAGIC_MOT_POL
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'BAGIC_MOT_POL' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.bagic_mot_pol as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 17: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=BAGIC_NONMOT_POL_YN
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'BAGIC_NONMOT_POL_YN' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.bagic_nonmot_pol_yn as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 18: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=BAGIC_NONMOT_POL
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'BAGIC_NONMOT_POL' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.bagic_nonmot_pol as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 19: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=CHALLAN
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'CHALLAN' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.challan as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 20: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=DRV_OFFENCE_YN
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'DRV_OFFENCE_YN' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.drv_offence_yn as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 21: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=DRV_OFFENCE_CNT
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'DRV_OFFENCE_CNT' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.drv_offence_cnt as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 22: BJAZ_MOT_ADD_QSTN_DTLS | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=CLAIM_OFFENCE_CNT
    select
        null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'CLAIM_OFFENCE_CNT' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.claim_offence_cnt as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 23: BJAZ_MOT_ADD_QSTN_DTLS
    select
        null,
        nullif(nullif('PIN:' || nullif(trim(t0.stp_pin), ''), 'PIN:'), '') as LOCATION_BK,
        nullif(nullif(trim(t0.pan_no), ''), '') as PARTY_BK,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        nullif(nullif(trim(t0.package_id), ''), '') as PRODUCT_BK,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null,
        1 as __LNK_PARTY_LOCATION,
        1 as __LNK_POLICY_LOCATION,
        1 as __LNK_POLICY_PARTY,
        1 as __LNK_POLICY_PRODUCT,
        null,
        1 as __LNK_PROPOSAL_PARTY,
        1 as __LNK_PROPOSAL_POLICY,
        1 as __LNK_PROPOSAL_PRODUCT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (coalesce(nullif(nullif('PIN:' || nullif(trim(t0.stp_pin), ''), 'PIN:'), ''), nullif(nullif(trim(t0.package_id), ''), ''), nullif(nullif(trim(t0.pan_no), ''), ''), nullif(nullif(trim(to_char(t0.contract_id)), ''), ''), nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), ''))) is not null

    union all

    -- branch 24: BJAZ_MOT_CLM_TRANS_EXTN | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=GSTIN
    select
        null, null,
        nullif(nullif(trim(to_char(t0.payee_ip_no)), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GSTIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null,
        t0.gstn_no as PARTY_IDENTIFICATION__GSTIN,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_clm_trans_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.payee_ip_no)), ''), '')) is not null

    union all

    -- branch 25: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null,
        nullif(nullif('APPLIANCE:' || nullif(trim(to_char(t0.serial_no)), ''), 'APPLIANCE:'), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.utgst_amt as AUG_POLICY_TAX_BREAKUP__UTGST_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cgst_amt as POLICY_TAX_BREAKUP__CGST_AMOUNT,
        t0.igst_amt as POLICY_TAX_BREAKUP__IGST_AMOUNT,
        t0.sgst_amt as POLICY_TAX_BREAKUP__SGST_AMOUNT,
        null, null, null, null, null,
        t0.brand_description as RISK_EXTENDED_WARRANTY__OEM_MAKE_REFERENCE,
        t0.model_no as RISK_EXTENDED_WARRANTY__OEM_MODEL_REFERENCE,
        t0.invoice_no as RISK_EXTENDED_WARRANTY__WARRANTY_INVOICE_NUMBER,
        t0.extended_warranty_plan as RISK_EXTENDED_WARRANTY__WARRANTY_PLAN_CODE,
        null,
        t0.sum_insured as RISK_EXTENDED_WARRANTY__WARRANTY_SUM_INSURED,
        t0.extended_warranty_period as RISK_EXTENDED_WARRANTY__WARRANTY_TERM_MONTHS,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (coalesce(nullif(nullif('APPLIANCE:' || nullif(trim(to_char(t0.serial_no)), ''), 'APPLIANCE:'), ''), nullif(nullif(trim(t0.policy_ref), ''), ''))) is not null

    union all

    -- branch 26: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PASSPORT
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null,
        t0.passport_no as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 27: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=EXTERNAL_USER_ID
    select
        null, null,
        nullif(nullif('USER:' || nullif(trim(t0.username), ''), 'USER:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EXTERNAL_USER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null,
        t0.ext_user_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif('USER:' || nullif(trim(t0.username), ''), 'USER:'), '')) is not null

    union all

    -- branch 28: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=TAX_ID
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TAX_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null,
        t0.tax_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 29: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.pan_number as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 30: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=GSTIN
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GSTIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null,
        t0.partner_gstn as PARTY_IDENTIFICATION__GSTIN,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 31: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AADHAAR
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.aadhaar_no as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 32: BJAZ_MOT_ONLINE_POL_DTLS_EXTN
    select
        nullif(nullif('IIB:' || nullif(trim(t0.iib_ref_no), ''), 'IIB:'), '') as ASSESSMENT_BK,
        nullif(md5(normalise(upper(nullif(coalesce(t0.loc_address_line1, '') || '|' || coalesce(t0.loc_address_line2, '') || '|' || coalesce(t0.loc_city, '') || '|' || coalesce(t0.loc_state, '') || '|' || coalesce(t0.loc_pincode, '') || '|' || coalesce(t0.loc_country, ''), '|||||')))), '') as LOCATION_BK,
        nullif(nullif(trim(t0.adhar_no), ''), '') as PARTY_BK,
        nullif(nullif(trim(t0.spca_policy_ref), ''), '') as POLICY_BK,
        null, null,
        nullif(nullif(trim(t0.trailer_chassis_no), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null,
        t0.iib_flag as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_CHECK_PERFORMED_INDICATOR,
        t0.iib_rule as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_DISCREPANCY_RULE_CODE,
        t0.iib_policy_status as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_POLICY_STATUS,
        t0.iib_prev_policy_exp_date as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_PREVIOUS_POLICY_EXPIRY_DATE,
        t0.iib_prev_policy_number as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_PREVIOUS_POLICY_NUMBER,
        t0.iib_prv_claim_ncb_flag as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_PRIOR_CLAIM_INDICATOR,
        t0.iib_pol_contineous_yn as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__CONTINUOUS_COVER_CONFIRMED_INDICATOR,
        t0.iib_pol_exp_above_90_days_yn as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__PREVIOUS_POLICY_EXPIRED_OVER_NINETY_DAYS_INDICATOR,
        t0.iib_pol_exp_within_90_days_yn as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__PREVIOUS_POLICY_EXPIRED_WITHIN_NINETY_DAYS_INDICATOR,
        t0.home_desc as AUG_LOCATION_PROFILE__DWELLING_DESCRIPTION,
        t0.home_years as AUG_LOCATION_PROFILE__YEARS_AT_LOCATION,
        null, null, null, null,
        t0.emp_company_code as AUG_PARTY_EMPLOYMENT__EMPLOYER_COMPANY_CODE,
        t0.emp_relation as AUG_PARTY_EMPLOYMENT__EMPLOYER_RELATIONSHIP_TYPE,
        null, null,
        t0.ucic_flag as AUG_PARTY_IDENTITY__UNIQUE_CUSTOMER_IDENTIFICATION_CODE_INDICATOR,
        t0.spca_prev_policy_expiry_date as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        null,
        t0.spca_utgst_amt as AUG_POLICY_TAX_BREAKUP__UTGST_AMOUNT,
        null,
        t0.spca_tax_id as AUG_POLICY_TAX_HEAD__TAX_HEAD_IDENTIFIER,
        null, null, null, null, null, null, null, null, null,
        t0.spca_prev_insurer_name as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        t0.spca_prev_policy_no as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        t0.spca_ncc_amt as POLICY_TAX_BREAKUP__CESS_AMOUNT,
        t0.spca_cgst_amt as POLICY_TAX_BREAKUP__CGST_AMOUNT,
        t0.spca_igst_amt as POLICY_TAX_BREAKUP__IGST_AMOUNT,
        t0.spca_sgst_amt as POLICY_TAX_BREAKUP__SGST_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.attached_trailer as RISK_TRAILER__ATTACHED_INDICATOR,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (coalesce(nullif(md5(normalise(upper(nullif(coalesce(t0.loc_address_line1, '') || '|' || coalesce(t0.loc_address_line2, '') || '|' || coalesce(t0.loc_city, '') || '|' || coalesce(t0.loc_state, '') || '|' || coalesce(t0.loc_pincode, '') || '|' || coalesce(t0.loc_country, ''), '|||||')))), ''), nullif(nullif('IIB:' || nullif(trim(t0.iib_ref_no), ''), 'IIB:'), ''), nullif(nullif(trim(t0.adhar_no), ''), ''), nullif(nullif(trim(t0.spca_policy_ref), ''), ''), nullif(nullif(trim(t0.trailer_chassis_no), ''), ''))) is not null

    union all

    -- branch 33: BJAZ_MOT_ONLINE_POL_DTLS_EXTN | child-key literal(s): AUG_PARTY_CORRESPONDENCE.Dispatch Channel=WHATSAPP
    select
        null, null,
        nullif(nullif(trim(t0.adhar_no), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'WHATSAPP' as AUG_PARTY_CORRESPONDENCE__DISPATCH_CHANNEL_CK,
        t0.whatsapp_req_date_time as AUG_PARTY_CORRESPONDENCE__COMMUNICATION_REQUEST_TIMESTAMP,
        t0.whatsapp_scheduler_flag as AUG_PARTY_CORRESPONDENCE__COMMUNICATION_SCHEDULED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(nullif(trim(t0.adhar_no), ''), '')) is not null

    union all

    -- branch 34: BJAZ_MOT_ONLINE_POL_DTLS_EXTN | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=AADHAAR
    select
        null, null,
        nullif(nullif(trim(t0.adhar_no), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        'AADHAAR' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.name_as_per_aadhar as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(nullif(trim(t0.adhar_no), ''), '')) is not null

    union all

    -- branch 35: BJAZ_MOT_ONLINE_POL_DTLS_EXTN | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AADHAAR
    select
        null, null,
        nullif(nullif(trim(t0.adhar_no), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.adhar_no as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        t0.aadhaar_status as PARTY_IDENTIFICATION__AADHAAR_VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(nullif(trim(t0.adhar_no), ''), '')) is not null

    union all

    -- branch 36: BJAZ_MOT_ONLINE_POL_DTLS_EXTN | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null,
        nullif(nullif(trim(t0.adhar_no), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null,
        t0.pan_status as PARTY_IDENTIFICATION__PAN_VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(nullif(trim(t0.adhar_no), ''), '')) is not null

    union all

    -- branch 37: BJAZ_MOT_WAR_CHILD_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=GSTIN
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GSTIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null,
        t0.gst_no as PARTY_IDENTIFICATION__GSTIN,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), '')) is not null

    union all

    -- branch 38: BJAZ_MOT_WAR_CHILD_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.pan_no as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), '')) is not null

    union all

    -- branch 39: BJAZ_MOT_WAR_CHILD_DTLS
    select
        null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.vehicle_reg_no), ''), nullif(trim(t0.equipment_serial_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.ext_warranty_end_date as RISK_EXTENDED_WARRANTY__EXTENDED_WARRANTY_END_DATE,
        t0.ext_warranty_start_date as RISK_EXTENDED_WARRANTY__EXTENDED_WARRANTY_START_DATE,
        null, null, null, null,
        t0.plan_desc as RISK_EXTENDED_WARRANTY__WARRANTY_PLAN_NAME,
        null,
        t0.extended_warranty_period as RISK_EXTENDED_WARRANTY__WARRANTY_TERM_MONTHS,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.vehicle_reg_no), ''), nullif(trim(t0.equipment_serial_no), '')), '')) is not null

    union all

    -- branch 40: BJAZ_MOT_WS_POL_DTLS
    select
        null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.tax_type2 as AUG_POLICY_TAX_BREAKUP__TAX_TYPE_2_CODE,
        t0.utgst_amt as AUG_POLICY_TAX_BREAKUP__UTGST_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cgst_amt as POLICY_TAX_BREAKUP__CGST_AMOUNT,
        t0.igst_amt as POLICY_TAX_BREAKUP__IGST_AMOUNT,
        t0.sgst_amt as POLICY_TAX_BREAKUP__SGST_AMOUNT,
        t0.stamp_duty_amt as POLICY_TAX_BREAKUP__STAMP_DUTY_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 41: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PASSPORT
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null,
        t0.passport_no as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 42: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=TAX_ID
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TAX_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null,
        t0.tax_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 43: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.pan_number as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 44: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=GSTIN
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GSTIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null,
        t0.partner_gstn as PARTY_IDENTIFICATION__GSTIN,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 45: BJAZ_WB_CLM_BASE_MOT_EXT | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=DRIVING_LICENCE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.driver_part_id)), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DRIVING_LICENCE' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null,
        t0.dl_verifation_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.driver_part_id)), ''), '')) is not null

)

select
    ASSESSMENT_BK,
    LOCATION_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    PROPOSAL_BK,
    RISK_OBJECT_BK,
    __LNK_PARTY_LOCATION,
    __LNK_POLICY_LOCATION,
    __LNK_POLICY_PARTY,
    __LNK_POLICY_PRODUCT,
    __LNK_PROPOSAL_ASSESSMENT,
    __LNK_PROPOSAL_PARTY,
    __LNK_PROPOSAL_POLICY,
    __LNK_PROPOSAL_PRODUCT,
    first_value(ASSESSMENT_PRE_INSPECTION__INSPECTION_AGENCY_CODE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_PRE_INSPECTION__INSPECTION_AGENCY_CODE,
    first_value(ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE,
    first_value(AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_CHECK_PERFORMED_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_CHECK_PERFORMED_INDICATOR,
    first_value(AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_DISCREPANCY_RULE_CODE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_DISCREPANCY_RULE_CODE,
    first_value(AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_POLICY_STATUS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_POLICY_STATUS,
    first_value(AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_PREVIOUS_POLICY_EXPIRY_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_PREVIOUS_POLICY_EXPIRY_DATE,
    first_value(AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_PREVIOUS_POLICY_NUMBER) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_PREVIOUS_POLICY_NUMBER,
    first_value(AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_PRIOR_CLAIM_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__BUREAU_REPORTED_PRIOR_CLAIM_INDICATOR,
    first_value(AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__CONTINUOUS_COVER_CONFIRMED_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__CONTINUOUS_COVER_CONFIRMED_INDICATOR,
    first_value(AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__PREVIOUS_POLICY_EXPIRED_OVER_NINETY_DAYS_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__PREVIOUS_POLICY_EXPIRED_OVER_NINETY_DAYS_INDICATOR,
    first_value(AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__PREVIOUS_POLICY_EXPIRED_WITHIN_NINETY_DAYS_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE__PREVIOUS_POLICY_EXPIRED_WITHIN_NINETY_DAYS_INDICATOR,
    first_value(AUG_LOCATION_PROFILE__DWELLING_DESCRIPTION) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_LOCATION_PROFILE__DWELLING_DESCRIPTION,
    first_value(AUG_LOCATION_PROFILE__YEARS_AT_LOCATION) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_LOCATION_PROFILE__YEARS_AT_LOCATION,
    AUG_PARTY_CORRESPONDENCE__DISPATCH_REFERENCE_CK,
    AUG_PARTY_CORRESPONDENCE__DISPATCH_CHANNEL_CK,
    first_value(AUG_PARTY_CORRESPONDENCE__COMMUNICATION_REQUEST_TIMESTAMP) ignore nulls over (partition by PARTY_BK, AUG_PARTY_CORRESPONDENCE__DISPATCH_REFERENCE_CK, AUG_PARTY_CORRESPONDENCE__DISPATCH_CHANNEL_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_CORRESPONDENCE__COMMUNICATION_REQUEST_TIMESTAMP,
    first_value(AUG_PARTY_CORRESPONDENCE__COMMUNICATION_SCHEDULED_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_CORRESPONDENCE__DISPATCH_REFERENCE_CK, AUG_PARTY_CORRESPONDENCE__DISPATCH_CHANNEL_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_CORRESPONDENCE__COMMUNICATION_SCHEDULED_INDICATOR,
    first_value(AUG_PARTY_EMPLOYMENT__EMPLOYER_COMPANY_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_EMPLOYMENT__EMPLOYER_COMPANY_CODE,
    first_value(AUG_PARTY_EMPLOYMENT__EMPLOYER_RELATIONSHIP_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_EMPLOYMENT__EMPLOYER_RELATIONSHIP_TYPE,
    AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
    first_value(AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
    first_value(AUG_PARTY_IDENTITY__UNIQUE_CUSTOMER_IDENTIFICATION_CODE_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTITY__UNIQUE_CUSTOMER_IDENTIFICATION_CODE_INDICATOR,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
    first_value(AUG_POLICY_TAX_BREAKUP__TAX_TYPE_2_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_BREAKUP__TAX_TYPE_2_CODE,
    first_value(AUG_POLICY_TAX_BREAKUP__UTGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_BREAKUP__UTGST_AMOUNT,
    AUG_POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
    first_value(AUG_POLICY_TAX_HEAD__TAX_HEAD_IDENTIFIER) ignore nulls over (partition by POLICY_BK, AUG_POLICY_TAX_HEAD__TAX_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_HEAD__TAX_HEAD_IDENTIFIER,
    PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
    first_value(PARTY_IDENTIFICATION__AADHAAR_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
    first_value(PARTY_IDENTIFICATION__AADHAAR_VERIFICATION_STATUS) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__AADHAAR_VERIFICATION_STATUS,
    first_value(PARTY_IDENTIFICATION__GSTIN) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__GSTIN,
    first_value(PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
    first_value(PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
    first_value(PARTY_IDENTIFICATION__PAN_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__PAN_NUMBER,
    first_value(PARTY_IDENTIFICATION__PAN_VERIFICATION_STATUS) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__PAN_VERIFICATION_STATUS,
    first_value(PARTY_IDENTIFICATION__PASSPORT_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
    first_value(POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
    first_value(POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
    first_value(POLICY_TAX_BREAKUP__CESS_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__CESS_AMOUNT,
    first_value(POLICY_TAX_BREAKUP__CGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__CGST_AMOUNT,
    first_value(POLICY_TAX_BREAKUP__IGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__IGST_AMOUNT,
    first_value(POLICY_TAX_BREAKUP__SGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__SGST_AMOUNT,
    first_value(POLICY_TAX_BREAKUP__STAMP_DUTY_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__STAMP_DUTY_AMOUNT,
    PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
    first_value(PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE) ignore nulls over (partition by PROPOSAL_BK, PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
    first_value(RISK_EXTENDED_WARRANTY__EXTENDED_WARRANTY_END_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_EXTENDED_WARRANTY__EXTENDED_WARRANTY_END_DATE,
    first_value(RISK_EXTENDED_WARRANTY__EXTENDED_WARRANTY_START_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_EXTENDED_WARRANTY__EXTENDED_WARRANTY_START_DATE,
    first_value(RISK_EXTENDED_WARRANTY__OEM_MAKE_REFERENCE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_EXTENDED_WARRANTY__OEM_MAKE_REFERENCE,
    first_value(RISK_EXTENDED_WARRANTY__OEM_MODEL_REFERENCE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_EXTENDED_WARRANTY__OEM_MODEL_REFERENCE,
    first_value(RISK_EXTENDED_WARRANTY__WARRANTY_INVOICE_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_EXTENDED_WARRANTY__WARRANTY_INVOICE_NUMBER,
    first_value(RISK_EXTENDED_WARRANTY__WARRANTY_PLAN_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_EXTENDED_WARRANTY__WARRANTY_PLAN_CODE,
    first_value(RISK_EXTENDED_WARRANTY__WARRANTY_PLAN_NAME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_EXTENDED_WARRANTY__WARRANTY_PLAN_NAME,
    first_value(RISK_EXTENDED_WARRANTY__WARRANTY_SUM_INSURED) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_EXTENDED_WARRANTY__WARRANTY_SUM_INSURED,
    first_value(RISK_EXTENDED_WARRANTY__WARRANTY_TERM_MONTHS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_EXTENDED_WARRANTY__WARRANTY_TERM_MONTHS,
    RISK_TRAILER__TRAILER_SEQUENCE_CK,
    first_value(RISK_TRAILER__ATTACHED_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK, RISK_TRAILER__TRAILER_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_TRAILER__ATTACHED_INDICATOR,
    first_value(RISK_TRAILER__TRAILER_IDV) ignore nulls over (partition by RISK_OBJECT_BK, RISK_TRAILER__TRAILER_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_TRAILER__TRAILER_IDV,
    first_value(RISK_TRAILER__TRAILER_REGISTRATION_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK, RISK_TRAILER__TRAILER_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_TRAILER__TRAILER_REGISTRATION_NUMBER,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on PARTY_BK (SAT_MOTOR_AUG_PARTY_CORRESPONDENCE, SAT_MOTOR_AUG_PARTY_IDENTIFICATION, SAT_PARTY_IDENTIFICATION):
    -- one load time per PARTY_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_PARTY_CORRESPONDENCE__COMMUNICATION_REQUEST_TIMESTAMP, m.AUG_PARTY_CORRESPONDENCE__COMMUNICATION_SCHEDULED_INDICATOR, m.AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT, m.PARTY_IDENTIFICATION__AADHAAR_NUMBER, m.PARTY_IDENTIFICATION__AADHAAR_VERIFICATION_STATUS, m.PARTY_IDENTIFICATION__GSTIN, m.PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER, m.PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR, m.PARTY_IDENTIFICATION__PAN_NUMBER, m.PARTY_IDENTIFICATION__PAN_VERIFICATION_STATUS, m.PARTY_IDENTIFICATION__PASSPORT_NUMBER) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.PARTY_BK) as PARTY_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on POLICY_BK (SAT_MOTOR_AUG_POLICY_TAX_HEAD):
    -- one load time per POLICY_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when m.AUG_POLICY_TAX_HEAD__TAX_HEAD_IDENTIFIER is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.POLICY_BK) as POLICY_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on PROPOSAL_BK (SAT_PROPOSAL_QUESTIONNAIRE):
    -- one load time per PROPOSAL_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when m.PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.PROPOSAL_BK) as PROPOSAL_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on RISK_OBJECT_BK (SAT_RISK_TRAILER):
    -- one load time per RISK_OBJECT_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.RISK_TRAILER__ATTACHED_INDICATOR, m.RISK_TRAILER__TRAILER_IDV, m.RISK_TRAILER__TRAILER_REGISTRATION_NUMBER) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.RISK_OBJECT_BK) as RISK_OBJECT_BK__MA_LOAD_DATETIME
from merged m
